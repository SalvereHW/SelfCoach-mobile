import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/health_data_service.dart';

class StepsCounterWidget extends StatefulWidget {
  const StepsCounterWidget({super.key});

  @override
  State<StepsCounterWidget> createState() => _StepsCounterWidgetState();
}

class _StepsCounterWidgetState extends State<StepsCounterWidget> {
  final HealthDataService _healthService = HealthDataService.instance;
  StreamSubscription<int>? _stepsSubscription;
  int _currentSteps = 0;
  Map<String, int> _weeklySteps = {};
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  @override
  void dispose() {
    _stepsSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize the health service if not already done
      if (!_healthService.isInitialized) {
        await _healthService.initialize();
      }
      
      if (_healthService.hasPermissions) {
        // Subscribe to steps stream
        _stepsSubscription = _healthService.stepsStream.listen((steps) {
          if (mounted) {
            setState(() {
              _currentSteps = steps;
            });
          }
        });
        
        // Load today's steps
        final todaySteps = await _healthService.getTodaySteps();
        setState(() {
          _currentSteps = todaySteps;
        });
        
        // Load weekly steps
        await _loadWeeklySteps();
        
        // Start continuous monitoring
        await _healthService.startMonitoring();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize health data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _loadWeeklySteps() async {
    try {
      final weeklyData = await _healthService.getWeeklySteps();
      if (mounted) {
        setState(() {
          _weeklySteps = weeklyData;
        });
      }
    } catch (e) {
      // Handle error silently for weekly data
    }
  }
  
  int get _weeklyTotal {
    return _weeklySteps.values.fold(0, (sum, steps) => sum + steps);
  }

  @override
  Widget build(BuildContext context) {
    const int dailyGoal = 10000; // Default step goal
    final double progress = (_currentSteps / dailyGoal).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _navigateToStepsDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_walk,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Steps',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$_currentSteps',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/ $dailyGoal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress >= 1.0 ? 'Goal achieved!' : '${(progress * 100).round()}% of goal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progress >= 1.0 ? Colors.green : Colors.grey[600],
                      fontWeight: progress >= 1.0 ? FontWeight.w600 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_weeklyTotal > 0) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Week: ${(_weeklyTotal / 1000).toStringAsFixed(1)}K',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (!_healthService.hasPermissions && !_isLoading) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap to enable health data access',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToStepsDetail(BuildContext context) {
    if (!_healthService.hasPermissions) {
      // Re-initialize to request permissions
      _initializeService();
      return;
    }
    
    // Navigate to detailed steps view
    context.push('/steps-detail');
  }
}