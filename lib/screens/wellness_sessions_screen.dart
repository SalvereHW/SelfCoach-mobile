import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selfcoach_mobile/design_system/app_spacing.dart';
import '../state/wellness.dart';
import '../models/wellness_session.dart';
import '../widgets/button.dart';
import 'session_player_screen.dart';

class WellnessSessionsScreen extends StatefulWidget {
  const WellnessSessionsScreen({super.key});

  @override
  State<WellnessSessionsScreen> createState() => _WellnessSessionsScreenState();
}

class _WellnessSessionsScreenState extends State<WellnessSessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WellnessState>().loadSessions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Sessions'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Featured'),
            Tab(icon: Icon(Icons.self_improvement), text: 'Meditation'),
            Tab(icon: Icon(Icons.air), text: 'Breathing'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Workout'),
            Tab(icon: Icon(Icons.accessibility_new), text: 'Stretching'),
            Tab(icon: Icon(Icons.spa), text: 'Relaxation'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatsDialog(),
          ),
        ],
      ),
      body: Consumer<WellnessState>(
        builder: (context, wellnessState, child) {
          if (wellnessState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wellnessState.errorMessage != null) {
            return _buildErrorState(wellnessState.errorMessage!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFeaturedTab(wellnessState),
              _buildTypeTab(wellnessState, WellnessSessionType.meditation),
              _buildTypeTab(wellnessState, WellnessSessionType.breathing),
              _buildTypeTab(wellnessState, WellnessSessionType.workout),
              _buildTypeTab(wellnessState, WellnessSessionType.stretching),
              _buildTypeTab(wellnessState, WellnessSessionType.relaxation),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeaturedTab(WellnessState wellnessState) {
    return RefreshIndicator(
      onRefresh: () => wellnessState.loadSessions(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStatsCard(wellnessState),
            const SizedBox(height: AppSpacing.md),
            _buildSectionHeader('Featured Sessions', Icons.star),
            const SizedBox(height: AppSpacing.xs),
            ...wellnessState.featuredSessions.map((session) => 
              _buildSessionCard(session, isHighlighted: true)),
            const SizedBox(height: AppSpacing.md),
            _buildSectionHeader('Recent Additions', Icons.new_releases),
            const SizedBox(height: AppSpacing.xs),
            ...wellnessState.recentSessions.map((session) => 
              _buildSessionCard(session)),
            const SizedBox(height: AppSpacing.md),
            _buildSectionHeader('Quick Sessions', Icons.flash_on),
            const SizedBox(height: AppSpacing.xs),
            ...wellnessState.quickSessions.take(3).map((session) => 
              _buildSessionCard(session)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(WellnessState wellnessState, WellnessSessionType type) {
    final sessions = wellnessState.getSessionsByType(type);
    
    if (sessions.isEmpty) {
      return _buildEmptyState(
        'No ${type.name} sessions available',
        'Check back later for new content!',
        _getTypeIcon(type),
      );
    }

    return RefreshIndicator(
      onRefresh: () => wellnessState.loadSessions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return _buildSessionCard(sessions[index]);
        },
      ),
    );
  }

  Widget _buildQuickStatsCard(WellnessState wellnessState) {
    final stats = wellnessState.getSessionStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem('Sessions', '${stats['totalSessions']}', Icons.play_circle, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatItem('Streak', '${stats['streak']} days', Icons.local_fire_department, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatItem('This Week', '${stats['thisWeekSessions']}', Icons.calendar_today, Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(WellnessSession session, {bool isHighlighted = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isHighlighted ? 4 : 1,
      child: InkWell(
        onTap: () => _navigateToSession(session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getTypeColor(session.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(session.type),
                      color: _getTypeColor(session.type),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  _buildSessionChip(session.typeLabel, _getTypeColor(session.type)),
                  const SizedBox(width: 8),
                  _buildSessionChip(session.durationFormatted, Colors.grey),
                  const SizedBox(width: 8),
                  _buildSessionChip(session.difficultyLabel, _getDifficultyColor(session.difficulty)),
                  const Spacer(),
                  SelfCoachButton.outline(
                    text: 'Start',
                    onPressed: () => _navigateToSession(session),
                    icon: Icons.play_arrow,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
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
              'Error loading sessions',
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
              onPressed: () => context.read<WellnessState>().loadSessions(),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSession(WellnessSession session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionPlayerScreen(session: session),
      ),
    );
  }

  void _showStatsDialog() {
    final stats = context.read<WellnessState>().getSessionStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Wellness Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Sessions:', '${stats['totalSessions']}'),
            _buildStatRow('Total Time:', _formatDuration(stats['totalTime'])),
            _buildStatRow('Average Rating:', '${(stats['averageRating'] as double).toStringAsFixed(1)} ⭐'),
            _buildStatRow('Current Streak:', '${stats['streak']} days'),
            _buildStatRow('This Week:', '${stats['thisWeekSessions']} sessions'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Color _getTypeColor(WellnessSessionType type) {
    switch (type) {
      case WellnessSessionType.meditation: return Colors.purple;
      case WellnessSessionType.breathing: return Colors.blue;
      case WellnessSessionType.workout: return Colors.red;
      case WellnessSessionType.stretching: return Colors.green;
      case WellnessSessionType.mindfulness: return Colors.indigo;
      case WellnessSessionType.relaxation: return Colors.teal;
      case WellnessSessionType.yoga: return Colors.orange;
      case WellnessSessionType.pilates: return Colors.pink;
      case WellnessSessionType.cardio: return Colors.deepOrange;
      case WellnessSessionType.strength: return Colors.brown;
      case WellnessSessionType.mobility: return Colors.cyan;
      case WellnessSessionType.recovery: return Colors.lightGreen;
      case WellnessSessionType.sleep: return Colors.deepPurple;
      case WellnessSessionType.focus: return Colors.amber;
      case WellnessSessionType.creativity: return Colors.lime;
      case WellnessSessionType.gratitude: return Colors.yellow;
    }
  }

  IconData _getTypeIcon(WellnessSessionType type) {
    switch (type) {
      case WellnessSessionType.meditation: return Icons.self_improvement;
      case WellnessSessionType.breathing: return Icons.air;
      case WellnessSessionType.workout: return Icons.fitness_center;
      case WellnessSessionType.stretching: return Icons.accessibility_new;
      case WellnessSessionType.mindfulness: return Icons.psychology;
      case WellnessSessionType.relaxation: return Icons.spa;
      case WellnessSessionType.yoga: return Icons.sports_gymnastics;
      case WellnessSessionType.pilates: return Icons.sports_handball;
      case WellnessSessionType.cardio: return Icons.directions_run;
      case WellnessSessionType.strength: return Icons.sports_mma;
      case WellnessSessionType.mobility: return Icons.accessibility;
      case WellnessSessionType.recovery: return Icons.healing;
      case WellnessSessionType.sleep: return Icons.bedtime;
      case WellnessSessionType.focus: return Icons.center_focus_strong;
      case WellnessSessionType.creativity: return Icons.palette;
      case WellnessSessionType.gratitude: return Icons.favorite;
    }
  }

  Color _getDifficultyColor(SessionDifficulty difficulty) {
    switch (difficulty) {
      case SessionDifficulty.beginner: return Colors.green;
      case SessionDifficulty.intermediate: return Colors.orange;
      case SessionDifficulty.advanced: return Colors.red;
    }
  }
}