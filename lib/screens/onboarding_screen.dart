import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: AppColors.background,
      pages: [
        _buildWelcomePage(context),
        _buildHealthTrackingPage(context),
        _buildPersonalizedPlansPage(context),
        _buildWellnessSessionsPage(context),
        _buildRemindersPage(context),
        _buildGetStartedPage(context),
      ],
      onDone: () => _onOnboardingComplete(context),
      onSkip: () => _onOnboardingComplete(context),
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      next: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 20,
        ),
      ),
      done: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          'Get Started',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      curve: Curves.easeInOut,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: DotsDecorator(
        size: const Size(8.0, 8.0),
        color: AppColors.outline,
        activeSize: const Size(16.0, 8.0),
        activeColor: AppColors.primary,
        spacing: const EdgeInsets.symmetric(horizontal: 4.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  PageViewModel _buildWelcomePage(BuildContext context) {
    return PageViewModel(
      title: "Welcome to SelfCoach",
      body: "Your personal wellness companion for a healthier, happier life. Take control of your health with personalized insights and guidance.",
      image: _buildPageImage(
        context,
        '🌟',
        AppColors.primaryGradient,
      ),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildHealthTrackingPage(BuildContext context) {
    return PageViewModel(
      title: "Track Your Health",
      body: "Monitor your daily steps, heart rate, sleep patterns, and nutrition. Connect with Google Health (Android) or HealthKit (iOS) for seamless tracking.",
      image: _buildPageImage(
        context,
        '📊',
        AppColors.secondaryGradient,
      ),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildPersonalizedPlansPage(BuildContext context) {
    return PageViewModel(
      title: "Personalized Health Plans",
      body: "Get customized recommendations based on your health conditions and cultural dietary preferences. ADHD, hypertension, sleep disorders - we've got you covered.",
      image: _buildPageImage(
        context,
        '🎯',
        AppColors.tertiaryGradient,
      ),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildWellnessSessionsPage(BuildContext context) {
    return PageViewModel(
      title: "Guided Wellness Sessions",
      body: "Access meditation, breathing exercises, yoga, and mindfulness sessions. Build healthy habits with expert-guided content tailored to your needs.",
      image: _buildPageImage(
        context,
        '🧘‍♀️',
        AppColors.forestGradient,
      ),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildRemindersPage(BuildContext context) {
    return PageViewModel(
      title: "Smart Reminders",
      body: "Never miss a dose, workout, or wellness break. Set personalized reminders for medications, activities, and self-care routines.",
      image: _buildPageImage(
        context,
        '⏰',
        AppColors.sunriseGradient,
      ),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildGetStartedPage(BuildContext context) {
    return PageViewModel(
      title: "Ready to Transform Your Health?",
      body: "Join thousands of users who have improved their wellness with SelfCoach. Start your journey to better health today!",
      image: _buildPageImage(
        context,
        '🚀',
        AppColors.oceansGradient,
      ),
      decoration: _getPageDecoration(),
    );
  }

  Widget _buildPageImage(BuildContext context, String emoji, List<Color> gradientColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(
                fontSize: 80,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
      ),
      bodyTextStyle: AppTypography.bodyLarge.copyWith(
        color: AppColors.onSurfaceVariant,
        height: 1.5,
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: AppColors.background,
      imagePadding: const EdgeInsets.only(top: 40, bottom: 24),
    );
  }

  Future<void> _onOnboardingComplete(BuildContext context) async {
    try {
      // Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      
      // Navigate to auth screen after onboarding
      if (context.mounted) {
        context.go('/auth');
      }
    } catch (e) {
      // If error saving, still navigate but user might see onboarding again
      if (context.mounted) {
        context.go('/auth');
      }
    }
  }
}