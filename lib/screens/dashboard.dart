import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth.dart' as app_auth;
import '../state/health.dart';
import '../state/ai_insights.dart';
import '../widgets/button.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';
import '../design_system/breakpoints.dart';
import 'sleep_entry_screen.dart';
import 'nutrition_entry_screen.dart';
import 'activity_entry_screen.dart';
import 'health_charts_screen.dart';
import 'health_plans_screen.dart';
import 'reminders_screen.dart';
import 'wellness_sessions_screen.dart';
import '../widgets/steps_counter_widget.dart';
import '../widgets/heart_rate_widget.dart';
import '../widgets/animated_card.dart';
import '../widgets/hero_page_route.dart';
import 'ai_insights_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final healthState = context.read<HealthState>();
      final aiInsightsState = context.read<AiInsightsState>();
      
      // Initialize API services with context
      healthState.initializeApiService(context);
      aiInsightsState.initializeApiService(context);
      
      // Load data
      healthState.loadHealthData();
      aiInsightsState.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'SelfCoach',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<app_auth.AppAuthState>(
            builder: (context, authState, child) {
              return Container(
                margin: const EdgeInsets.only(right: AppSpacing.md),
                child: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await authState.signOut();
                    } else if (value == 'health_plans') {
                      _navigateToHealthPlans(context);
                    }
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.subtleShadow,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            authState.userProfile?.name ?? 'Profile',
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'health_plans',
                      child: Row(
                        children: [
                          Icon(Icons.health_and_safety, color: AppColors.secondary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Health Plans', style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Logout', style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<app_auth.AppAuthState, HealthState>(
        builder: (context, authState, healthState, child) {
          if (healthState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthState.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading health data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    healthState.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SelfCoachButton(
                    text: 'Retry',
                    onPressed: () => healthState.loadHealthData(),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backgroundGradient,
              ),
            ),
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () => healthState.loadHealthData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StaggeredAnimationCard(
                      index: 0,
                      child: _buildWelcomeSection(authState),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StaggeredAnimationCard(
                      index: 1,
                      child: _buildQuickStats(healthState),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StaggeredAnimationCard(
                      index: 2,
                      child: _buildQuickActions(),
                    ),
                    const SizedBox(height: AppSpacing.md), // Bottom space
                  ],
                ),
              ),
            ),
          );
        },
        ),
      ),
      floatingActionButton: AnimatedCard(
        delay: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 800),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.secondaryGradient,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppColors.elevatedShadow,
          ),
          child: FloatingActionButton(
            onPressed: () => _showAddDataBottomSheet(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(app_auth.AppAuthState authState) {
    final now = DateTime.now();
    final hour = now.hour;
    
    String greeting;
    String timeMessage;
    IconData timeIcon;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      timeMessage = 'Start your day with intention';
      timeIcon = Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      timeMessage = 'Keep the momentum going';
      timeIcon = Icons.wb_sunny;
    } else {
      greeting = 'Good Evening';
      timeMessage = 'Wind down and reflect';
      timeIcon = Icons.nights_stay_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Stack(
        children: [
          // Background gradient card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        timeIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authState.userProfile?.name ?? 'Welcome back',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  timeMessage,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          'Let\'s focus on your wellness today',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Decorative circles for visual interest
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: 40,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(HealthState healthState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (Breakpoints.isSmallPhone(context)) {
              // Single column layout for very small screens
              return Column(
                children: [
                  _buildEnhancedSleepCard(healthState),
                ],
              );
            } else {
              // Default two-row layout
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedSleepCard(healthState),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveSpacing.getCardSpacing(context)),
                  Row(
                    children: [
                      const Expanded(
                        child: HeartRateWidget(),
                      ),
                      SizedBox(width: ResponsiveSpacing.getCardSpacing(context)),
                      const Expanded(
                        child: StepsCounterWidget(),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveSpacing.getCardSpacing(context)),
                  Row(
                    children: [
                      SizedBox(width: ResponsiveSpacing.getCardSpacing(context)),
                      Expanded(
                        child: Consumer<AiInsightsState>(
                          builder: (context, aiInsightsState, child) {
                            return GestureDetector(
                              onTap: () async {
                                // Always navigate to AI insights screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AiInsightsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.insights,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'AI Insights',
                                          style: AppTypography.labelLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (aiInsightsState.unreadCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.error,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${aiInsightsState.unreadCount}',
                                              style: AppTypography.labelSmall.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (aiInsightsState.isLoading)
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    else if (aiInsightsState.unreadInsights.isNotEmpty)
                                      Text(
                                        aiInsightsState.unreadInsights.first.title,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    else
                                      Row(
                                        children: [
                                          Text(
                                            'Generate insights',
                                            style: AppTypography.bodyMedium.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }


  Widget _buildEnhancedSleepCard(HealthState healthState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sleep.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bedtime,
                  color: AppColors.sleep,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      healthState.mostRecentSleep != null 
                          ? '${(healthState.mostRecentSleep!.duration?.inHours ?? 0)}h ${(healthState.mostRecentSleep!.duration?.inMinutes ?? 0) % 60}m'
                          : 'No data',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.sleep,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      healthState.mostRecentSleep?.quality.name.toUpperCase() ?? 'N/A',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (Breakpoints.isSmallPhone(context)) {
              // Single column layout for very small screens
              return Column(
                children: [
                  SelfCoachButton.outline(
                    text: 'Log Sleep',
                    icon: Icons.bedtime,
                    fullWidth: true,
                    size: ButtonSize.medium,
                    onPressed: () => _navigateToSleepEntry(context),
                  ),
                  SizedBox(height: ResponsiveSpacing.getCardSpacing(context)),
                  SelfCoachButton.outline(
                    text: 'Add Meal',
                    icon: Icons.restaurant,
                    fullWidth: true,
                    size: ButtonSize.medium,
                    onPressed: () => _navigateToNutritionEntry(context),
                  ),
                  SizedBox(height: ResponsiveSpacing.getCardSpacing(context)),
                  SelfCoachButton.outline(
                    text: 'Log Activity',
                    icon: Icons.fitness_center,
                    fullWidth: true,
                    size: ButtonSize.medium,
                    onPressed: () => _navigateToActivityEntry(context),
                  ),
                  SizedBox(height: ResponsiveSpacing.getCardSpacing(context)),
                  Row(
                    children: [
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'Charts',
                          icon: Icons.analytics,
                          size: ButtonSize.small,
                          onPressed: () => _navigateToHealthCharts(context),
                        ),
                      ),
                      SizedBox(width: ResponsiveSpacing.getCardSpacing(context)),
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'Wellness',
                          icon: Icons.self_improvement,
                          size: ButtonSize.small,
                          onPressed: () => _navigateToWellnessSessions(context),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // Default two-column layout
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'Log Sleep',
                          icon: Icons.bedtime,
                          onPressed: () => _navigateToSleepEntry(context),
                        ),
                      ),
                      SizedBox(width: ResponsiveSpacing.getCardSpacing(context)),
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'Add Meal',
                          icon: Icons.restaurant,
                          onPressed: () => _navigateToNutritionEntry(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveSpacing.getCardSpacing(context)),
                  Row(
                    children: [
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'Log Activity',
                          icon: Icons.fitness_center,
                          onPressed: () => _navigateToActivityEntry(context),
                        ),
                      ),
                      SizedBox(width: ResponsiveSpacing.getCardSpacing(context)),
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'View Charts',
                          icon: Icons.analytics,
                          onPressed: () => _navigateToHealthCharts(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveSpacing.getCardSpacing(context)),
                  Row(
                    children: [
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'Smart Reminders',
                          icon: Icons.notifications_active,
                          onPressed: () => _navigateToReminders(context),
                        ),
                      ),
                      SizedBox(width: ResponsiveSpacing.getCardSpacing(context)),
                      Expanded(
                        child: SelfCoachButton.outline(
                          text: 'Wellness Sessions',
                          icon: Icons.self_improvement,
                          onPressed: () => _navigateToWellnessSessions(context),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  void _showAddDataBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Health Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SelfCoachButton(
              text: 'Log Sleep',
              icon: Icons.bedtime,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                _navigateToSleepEntry(context);
              },
            ),
            const SizedBox(height: 8),
            SelfCoachButton.secondary(
              text: 'Add Meal',
              icon: Icons.restaurant,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                _navigateToNutritionEntry(context);
              },
            ),
            const SizedBox(height: 8),
            SelfCoachButton.secondary(
              text: 'Log Activity',
              icon: Icons.fitness_center,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                _navigateToActivityEntry(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSleepEntry(BuildContext context) {
    AnimatedNavigator.slideToPage(context, const SleepEntryScreen());
  }

  void _navigateToNutritionEntry(BuildContext context) {
    AnimatedNavigator.slideToPage(context, const NutritionEntryScreen());
  }

  void _navigateToActivityEntry(BuildContext context) {
    AnimatedNavigator.slideToPage(context, const ActivityEntryScreen());
  }

  void _navigateToHealthCharts(BuildContext context) {
    AnimatedNavigator.scaleToPage(context, const HealthChartsScreen());
  }

  void _navigateToHealthPlans(BuildContext context) {
    AnimatedNavigator.scaleToPage(context, const HealthPlansScreen());
  }

  void _navigateToReminders(BuildContext context) {
    AnimatedNavigator.slideToPage(context, const RemindersScreen());
  }

  void _navigateToWellnessSessions(BuildContext context) {
    AnimatedNavigator.slideToPage(context, const WellnessSessionsScreen());
  }

}