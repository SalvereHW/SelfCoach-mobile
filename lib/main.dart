// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'state/auth.dart' as app_auth;
import 'state/health.dart';
import 'state/reminder.dart';
import 'state/wellness.dart';
import 'state/ai_insights.dart';
import 'screens/dashboard.dart';
import 'screens/auth_screen.dart';
import 'screens/steps_detail_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_system/app_theme.dart';
import 'design_system/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI overlays to prevent elements from being hidden
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize services (they will be initialized when first accessed)
  // StepsCounterService uses singleton pattern

  
  // Add additional error handling for web compatibility
  if (kIsWeb) {
    if (kDebugMode) {
      print('Running in web mode - some features may be limited');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AppAuthState()),
        ChangeNotifierProvider(create: (_) => HealthState()),
        ChangeNotifierProvider(create: (_) => ReminderState()),
        ChangeNotifierProvider(create: (_) => WellnessState()),
        ChangeNotifierProvider(create: (_) => AiInsightsState()),
      ],
      child: MaterialApp.router(
        title: 'SelfCoach - Holistic Wellness',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}

// Router refresh stream to handle auth state changes
class _RouterRefreshStream extends ChangeNotifier {
  static final _instance = _RouterRefreshStream._internal();
  factory _RouterRefreshStream() => _instance;
  _RouterRefreshStream._internal();

  void refresh() {
    notifyListeners();
  }
}

// Define the GoRouter configuration
final _router = GoRouter(
  refreshListenable: _RouterRefreshStream(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return Consumer<app_auth.AppAuthState>(
          builder: (context, authState, child) {

            if (kDebugMode) {
              print('Auth status: ${authState.status}');
              print('Is authenticated: ${authState.isAuthenticated}');
              print('User ID: ${authState.userId}');
            }
            
            if (authState.status == app_auth.AuthStatus.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Check if user has seen onboarding
            return FutureBuilder<bool>(
              future: _hasSeenOnboarding(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final hasSeenOnboarding = snapshot.data ?? false;
                
                // If user hasn't seen onboarding, show it first
                if (!hasSeenOnboarding) {
                  return const OnboardingScreen();
                }
                
                // Otherwise, follow normal auth flow
                if (authState.isAuthenticated) {
                  return const DashboardScreen();
                } else {
                  return const WelcomeScreen();
                }
              },
            );
          },
        );
      },
      routes: [
        GoRoute(
          path: 'home',
          name: 'home',
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: 'welcome',
          name: 'welcome',
          builder: (_, __) => const WelcomeScreen(),
        ),
        GoRoute(
          path: 'auth',
          name: 'auth',
          builder: (_, __) => const AuthScreen(),
        ),
        GoRoute(
          path: 'steps-detail',
          name: 'steps-detail',
          builder: (_, __) => const StepsDetailScreen(),
        ),
        GoRoute(
          path: 'onboarding',
          name: 'onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
      ],
    ),
  ],
);

// Check if user has seen onboarding
Future<bool> _hasSeenOnboarding() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  } catch (e) {
    if (kDebugMode) {
      print('Error checking onboarding status: $e');
    }
    return false;
  }
}


// Welcome Screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon Section
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 60,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // App Title
                  const Text(
                    'SelfCoach',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Tagline
                  const Text(
                    'Your Holistic Wellness Journey',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Feature highlights
                  // Container(
                  //   padding: const EdgeInsets.all(24),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withValues(alpha: 0.9),
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withValues(alpha: 0.1),
                  //         blurRadius: 20,
                  //         offset: const Offset(0, 10),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       _buildFeatureItem(Icons.bedtime, 'Track Sleep', 'Monitor your sleep patterns and quality'),
                  //       const SizedBox(height: 16),
                  //       _buildFeatureItem(Icons.restaurant, 'Log Nutrition', 'Record meals and track your nutrition'),
                  //       const SizedBox(height: 16),
                  //       _buildFeatureItem(Icons.fitness_center, 'Track Activity', 'Monitor your physical activities'),
                  //       const SizedBox(height: 16),
                  //       _buildFeatureItem(Icons.analytics, 'View Progress', 'Visualize your health trends'),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 48),
                  
                  // Authentication Section using Supabase
                  Column(
                    children: [
                      // Google Sign In Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton.icon(
                      //     onPressed: () async {
                      //       final authState = Provider.of<app_auth.AppAuthState>(context, listen: false);
                      //       final success = await authState.signInWithGoogle();
                      //       if (success && context.mounted) {
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(content: Text('Signed in successfully!')),
                      //         );
                      //       }
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.white,
                      //       foregroundColor: Colors.black87,
                      //       side: const BorderSide(color: Colors.grey),
                      //       padding: const EdgeInsets.symmetric(vertical: 12),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     icon: const Icon(Icons.login, color: Colors.red),
                      //     label: const Text(
                      //       'Continue with Google',
                      //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      //     ),
                      //   ),
                      // ),
                      
                      // const SizedBox(height: 16),
                      
                      // // Divider
                      // Row(
                      //   children: [
                      //     const Expanded(child: Divider(color: Colors.white54)),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16),
                      //       child: Text(
                      //         'or',
                      //         style: TextStyle(
                      //           color: Colors.white.withValues(alpha: 0.8),
                      //           fontSize: 14,
                      //         ),
                      //       ),
                      //     ),
                      //     const Expanded(child: Divider(color: Colors.white54)),
                      //   ],
                      // ),
                      
                      // const SizedBox(height: 16),
                      
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(isSignUp: true),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(isSignUp: false),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Clear Session Button (for troubleshooting)
                      Consumer<app_auth.AppAuthState>(
                        builder: (context, authState, child) {
                          return TextButton(
                            onPressed: () async {
                              await authState.clearExistingSession();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Session cleared.'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Clear Session',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign in prompt
                  const Text(
                    'Sign in to start your wellness journey',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

// Helper function to safely get user display name
String _getUserDisplayName(User? user) {
  if (user == null) return 'User';
  
  try {
    final name = user.userMetadata?['full_name'] ?? 
                user.userMetadata?['name'];
    if (name != null && name.isNotEmpty) {
      return name;
    }
  } catch (e) {
    // name not available or accessible
  }
  
  try {
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      // Return first part of email before @
      return email.split('@').first;
    }
  } catch (e) {
    // email not available or accessible
  }
  
  return 'User';
}

// Home Screen
class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout() async {
    if (mounted) {
      await context.read<app_auth.AppAuthState>().signOut();
      context.pushReplacementNamed('welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AppAuthState>(
      builder: (context, authState, child) {
        if (authState.isAuthenticated) {
          final user = authState.supabaseUser;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (String choice) async {
                    if (choice == 'logout') {
                      await _logout();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Log out'),
                      ),
                    ];
                  },
                  child: CircleAvatar(
                    child: Text(
                      _getUserDisplayName(user)[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Hi, ${_getUserDisplayName(user)}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Log out'),
                  )
                ],
              ),
            ),
          );
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}