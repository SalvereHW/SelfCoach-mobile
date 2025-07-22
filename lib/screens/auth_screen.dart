import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/auth.dart' as app_auth;
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';
import '../widgets/button.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  
  const AuthScreen({super.key, this.isSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isSignUp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = Provider.of<app_auth.AppAuthState>(context, listen: false);
      bool success;

      if (_isSignUp) {
        success = await authState.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await authState.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        if (success) {
          // Let the auth state change listener handle navigation automatically
          // Don't manually navigate here to avoid conflicts
          if (kDebugMode) {
            print('Authentication successful, waiting for auth state change...');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage ?? 'Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // App Title
                Text(
                  'SelfCoach',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // const Text(
                //   'Your Holistic Wellness Journey',
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.white,
                //     fontWeight: FontWeight.w300,
                //   ),
                // ),
                // const SizedBox(height: 30),
                
                // Authentication Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Icon(
                            Icons.health_and_safety,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          _isSignUp ? 'Create Account' : 'Welcome Back',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          _isSignUp 
                            ? 'Join us and start your wellness journey'
                            : 'Sign in to continue your wellness journey',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        SelfCoachButton(
                          text: _isSignUp ? 'Sign Up' : 'Sign In',
                          onPressed: _isLoading ? null : _handleAuth,
                          isLoading: _isLoading,
                          fullWidth: true,
                          size: ButtonSize.small,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Toggle Sign Up/Sign In
                        SelfCoachButton.text(
                          text: _isSignUp
                              ? 'Already have an account? Sign In'
                              : 'Don\'t have an account? Sign Up',
                          onPressed: () {
                            setState(() => _isSignUp = !_isSignUp);
                          },
                          size: ButtonSize.medium,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        
                        // Back to Welcome Button
                        SelfCoachButton.text(
                          text: 'Back to Welcome',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          size: ButtonSize.medium,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Footer
                Text(
                  'Your privacy and health data are secure',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
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