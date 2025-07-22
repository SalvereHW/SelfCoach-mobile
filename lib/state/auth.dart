import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as models;

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AppAuthState extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _supabaseUser;
  models.UserProfile? _userProfile;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get supabaseUser => _supabaseUser;
  models.UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _supabaseUser != null;

  // Get current session token for API calls
  String? get sessionToken => Supabase.instance.client.auth.currentSession?.accessToken;

  // Get current user ID for API calls
  String? get userId => _supabaseUser?.id;

  AppAuthState() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      // Check if user is already authenticated with Supabase
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        _supabaseUser = session.user;
        await _loadUserProfile();
        _setStatus(AuthStatus.authenticated);
        _onAuthenticationChanged(); // Handle authentication state change
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }

      // Listen to auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        if (event == AuthChangeEvent.signedIn && session != null) {
          // Add a small delay to prevent navigation conflicts
          Future.delayed(const Duration(milliseconds: 100), () {
            _supabaseUser = session.user;
            _loadUserProfile();
            _setStatus(AuthStatus.authenticated);
            _onAuthenticationChanged();
          });
        } else if (event == AuthChangeEvent.signedOut) {
          _supabaseUser = null;
          _userProfile = null;
          _setStatus(AuthStatus.unauthenticated);
          _onAuthenticationChanged();
        }
      });
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserProfile() async {
    if (_supabaseUser == null) return;

    try {
      // Create UserProfile from Supabase user data
      final email = _supabaseUser!.email ?? '';
      final name = _supabaseUser!.userMetadata?['full_name'] ?? 
                  _supabaseUser!.userMetadata?['name'] ?? 
                  _supabaseUser!.email?.split('@').first ?? 
                  'User';

      _userProfile = models.UserProfile(
        id: _supabaseUser!.id,
        name: name,
        email: email,
        createdAt: DateTime.parse(_supabaseUser!.createdAt),
        updatedAt: DateTime.parse(_supabaseUser!.updatedAt ?? _supabaseUser!.createdAt),
      );
      
      // TODO: Load additional profile data from backend API
      // This would include health conditions, preferences, etc.
      
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }
      // Continue with basic profile from Supabase
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.selfcoach.app://login-callback',
      );

      if (response) {
        return true;
      } else {
        _setError('Google sign in cancelled');
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return true;
      } else {
        _setError('Sign in failed');
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return true;
      } else {
        _setError('Sign up failed');
        return false;
      }
    } catch (e) {
      _setError('Sign up failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await Supabase.instance.client.auth.signOut();
      _supabaseUser = null;
      _userProfile = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refreshSession() async {
    try {
      // Supabase handles automatic token refresh
      final session = await Supabase.instance.client.auth.refreshSession();
      if (session.session != null) {
        return true;
      } else {
        await signOut();
        return false;
      }
    } catch (e) {
      _setError('Session refresh failed: $e');
      await signOut();
      return false;
    }
  }

  Future<bool> updateUserProfile(models.UserProfile updatedProfile) async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement API call to update user profile on backend
      // For now, just update locally
      _userProfile = updatedProfile;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearExistingSession() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _supabaseUser = null;
      _userProfile = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing existing session: $e');
      }
    }
  }

  void onUserSignedIn(User user) {
    _supabaseUser = user;
    _loadUserProfile();
    _setStatus(AuthStatus.authenticated);
  }

  void onUserSignedOut() {
    _supabaseUser = null;
    _userProfile = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _supabaseUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Handle authentication state changes
  void _onAuthenticationChanged() {
    if (kDebugMode) {
      print('Authentication state changed. Authenticated: $isAuthenticated');
      print('User ID: $userId');
      print('Session token available: ${sessionToken != null}');
    }
  }
}