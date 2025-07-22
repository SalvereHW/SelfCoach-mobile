import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/reminder.dart';
import '../state/auth.dart' as app_auth;
import '../models/reminder.dart';
import '../widgets/button.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminderState = context.read<ReminderState>();
      // Initialize API service with context
      reminderState.initializeApiService(context);
      
      // Wait for authentication to be ready before loading reminders
      _waitForAuthAndLoadReminders();
    });
  }

  Future<void> _waitForAuthAndLoadReminders() async {
    final authState = context.read<app_auth.AppAuthState>();
    final reminderState = context.read<ReminderState>();
    
    // Wait for auth state to be determined (not loading)
    int attempts = 0;
    while (authState.status == app_auth.AuthStatus.loading && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // Load reminders if authenticated
    if (authState.isAuthenticated) {
      reminderState.loadReminders();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Smart Reminders',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              labelStyle: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTypography.labelMedium,
              tabs: const [
                Tab(
                  icon: Icon(Icons.schedule_rounded, size: 18),
                  text: 'Upcoming',
                  height: 45,
                ),
                Tab(
                  icon: Icon(Icons.list_rounded, size: 18),
                  text: 'All',
                  height: 45,
                ),
                Tab(
                  icon: Icon(Icons.analytics_rounded, size: 18),
                  text: 'Stats',
                  height: 45,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: SelfCoachIconButton(
              icon: Icons.add_rounded,
              onPressed: () => _navigateToAddReminder(),
              tooltip: 'Add Reminder',
              backgroundColor: AppColors.primaryContainer,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: Consumer2<ReminderState, app_auth.AppAuthState>(
        builder: (context, reminderState, authState, child) {
          // Auto-reload reminders when user signs in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authState.isAuthenticated && 
                reminderState.reminders.isEmpty && 
                !reminderState.isLoading &&
                reminderState.errorMessage?.contains('Not authenticated') == true) {
              reminderState.loadReminders();
            }
          });
          if (reminderState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reminderState.errorMessage != null) {
            return _buildErrorState(reminderState.errorMessage!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingTab(reminderState),
              _buildAllRemindersTab(reminderState),
              _buildStatsTab(reminderState),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.tertiaryGradient,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.elevatedShadow,
        ),
        child: FloatingActionButton(
          onPressed: _navigateToAddReminder,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab(ReminderState reminderState) {
    final upcomingReminders = reminderState.upcomingReminders;
    final overdueReminders = reminderState.overdueReminders;

    if (upcomingReminders.isEmpty && overdueReminders.isEmpty) {
      return _buildEmptyState(
        'No upcoming reminders',
        'You\'re all caught up! Add some reminders to stay on track.',
        Icons.schedule,
      );
    }

    return RefreshIndicator(
      onRefresh: () => reminderState.loadReminders(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overdueReminders.isNotEmpty) ...[
              _buildSectionHeader('Overdue', Icons.warning, Colors.red),
              const SizedBox(height: 8),
              ...overdueReminders.map((reminder) => _buildReminderCard(reminder, isOverdue: true)),
              const SizedBox(height: AppSpacing.md),
            ],
            if (upcomingReminders.isNotEmpty) ...[
              _buildSectionHeader('Upcoming', Icons.schedule, Colors.blue),
              const SizedBox(height: 8),
              ...upcomingReminders.map((reminder) => _buildReminderCard(reminder)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllRemindersTab(ReminderState reminderState) {
    final reminders = reminderState.reminders;

    if (reminders.isEmpty) {
      return _buildEmptyState(
        'No reminders yet',
        'Create your first reminder to get started with staying on track.',
        Icons.add_alert,
      );
    }

    return RefreshIndicator(
      onRefresh: () => reminderState.loadReminders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderCard(reminder, showActions: true);
        },
      ),
    );
  }

  Widget _buildStatsTab(ReminderState reminderState) {
    final stats = reminderState.getReminderStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Reminders', '${stats['totalReminders']}', Icons.notifications, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Active', '${stats['activeReminders']}', Icons.check_circle, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Upcoming', '${stats['upcomingReminders']}', Icons.schedule, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Overdue', '${stats['overdueReminders']}', Icons.warning, Colors.red)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Performance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${stats['completionRate']}%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Completion Rate'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${stats['weeklyCompletion']}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Completed'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${stats['weeklyDismissed']}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Dismissed'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(Reminder reminder, {bool isOverdue = false, bool showActions = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isOverdue ? 4 : 1,
      color: isOverdue ? AppColors.errorContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getReminderTypeColor(reminder.type),
          child: Icon(
            _getReminderTypeIcon(reminder.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isOverdue ? Colors.red[700] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null) ...[
              Text(reminder.description!),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _formatReminderTime(reminder),
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: isOverdue ? FontWeight.w500 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    reminder.frequencyLabel,
                    style: TextStyle(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: showActions ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelfCoachToggleButton(
              value: reminder.isEnabled,
              onChanged: (value) => _toggleReminder(reminder.id),
              size: ButtonSize.small,
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            SelfCoachIconButton(
              icon: Icons.more_vert_rounded,
              onPressed: () => _showReminderMenu(context, reminder),
              size: ButtonSize.small,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ) : isOverdue ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _completeReminder(reminder.id),
            ),
            IconButton(
              icon: const Icon(Icons.snooze, color: Colors.orange),
              onPressed: () => _snoozeReminder(reminder.id),
            ),
          ],
        ) : null,
        onTap: isOverdue ? () => _showReminderActions(reminder) : null,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
        Row(
          children: [
            Expanded(
              child: SelfCoachButton.outline(
                text: 'Add Medication',
                icon: Icons.medication,
                onPressed: () => _navigateToAddReminder(type: ReminderType.medication),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelfCoachButton.outline(
                text: 'Water Reminder',
                icon: Icons.water_drop,
                onPressed: () => _navigateToAddReminder(type: ReminderType.hydration),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SelfCoachButton.outline(
                text: 'Exercise',
                icon: Icons.fitness_center,
                onPressed: () => _navigateToAddReminder(type: ReminderType.exercise),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelfCoachButton.outline(
                text: 'Sleep',
                icon: Icons.bedtime,
                onPressed: () => _navigateToAddReminder(type: ReminderType.sleep),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            SelfCoachButton(
              text: 'Add Reminder',
              icon: Icons.add,
              onPressed: _navigateToAddReminder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Error loading reminders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            SelfCoachButton(
              text: 'Retry',
              onPressed: () => context.read<ReminderState>().loadReminders(),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddReminder({ReminderType? type}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(initialType: type),
      ),
    );
  }


  void _toggleReminder(String reminderId) {
    context.read<ReminderState>().toggleReminder(reminderId);
  }

  void _completeReminder(String reminderId) {
    context.read<ReminderState>().completeReminder(reminderId);
  }

  void _snoozeReminder(String reminderId) {
    context.read<ReminderState>().snoozeReminder(reminderId, const Duration(minutes: 15));
  }

  void _showReminderMenu(BuildContext context, Reminder reminder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              reminder.title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildMenuOption(
              icon: Icons.edit_rounded,
              title: 'Edit Reminder',
              onTap: () {
                Navigator.pop(context);
                _navigateToEditReminder(reminder);
              },
            ),
            _buildMenuOption(
              icon: Icons.check_circle_rounded,
              title: 'Mark Complete',
              onTap: () {
                Navigator.pop(context);
                _completeReminder(reminder.id);
              },
            ),
            _buildMenuOption(
              icon: Icons.delete_rounded,
              title: 'Delete',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _deleteReminder(reminder);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppColors.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: color ?? AppColors.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  void _navigateToEditReminder(Reminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(existingReminder: reminder),
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReminderState>().deleteReminder(reminder.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReminderActions(Reminder reminder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reminder.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: SelfCoachButton(
                    text: 'Complete',
                    icon: Icons.check,
                    onPressed: () {
                      _completeReminder(reminder.id);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelfCoachButton.secondary(
                    text: 'Snooze 15m',
                    icon: Icons.snooze,
                    onPressed: () {
                      _snoozeReminder(reminder.id);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelfCoachButton.outline(
              text: 'Dismiss',
              fullWidth: true,
              onPressed: () {
                context.read<ReminderState>().dismissReminder(reminder.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getReminderTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return AppColors.error;
      case ReminderType.hydration:
        return AppColors.info;
      case ReminderType.exercise:
        return AppColors.success;
      case ReminderType.meditation:
        return AppColors.meditation;
      case ReminderType.sleep:
        return AppColors.sleep;
      case ReminderType.meal:
        return AppColors.warning;
      case ReminderType.custom:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.hydration:
        return Icons.water_drop;
      case ReminderType.exercise:
        return Icons.fitness_center;
      case ReminderType.meditation:
        return Icons.self_improvement;
      case ReminderType.sleep:
        return Icons.bedtime;
      case ReminderType.meal:
        return Icons.restaurant;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  String _formatReminderTime(Reminder reminder) {
    final next = reminder.nextScheduledTime;
    if (next == null) return 'No upcoming';
    
    final now = DateTime.now();
    final difference = next.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    }
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }
    
    if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    }
    
    if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
    
    return 'Now';
  }
}