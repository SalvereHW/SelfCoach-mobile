import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/health_data_service.dart';
import '../design_system/app_colors.dart';

enum StepsViewType { daily, weekly, monthly }

class StepsDetailScreen extends StatefulWidget {
  const StepsDetailScreen({super.key});

  @override
  State<StepsDetailScreen> createState() => _StepsDetailScreenState();
}

class _StepsDetailScreenState extends State<StepsDetailScreen> {
  final HealthDataService _healthService = HealthDataService.instance;
  StepsViewType _currentView = StepsViewType.daily;
  bool _isLoading = true;
  bool _disposed = false;
  int _todaySteps = 0;
  Map<String, int> _weeklyData = {};
  Map<String, int> _monthlyData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_disposed) return;
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final todaySteps = await _healthService.getTodaySteps();
      final weeklyData = await _healthService.getWeeklySteps();
      final monthlyData = await _healthService.getMonthlySteps();

      if (!_disposed && mounted) {
        setState(() {
          _todaySteps = todaySteps;
          _weeklyData = weeklyData;
          _monthlyData = monthlyData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_disposed && mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading steps data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Steps Progress'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.onBackground,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
        children: [
          // View selector tabs
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: StepsViewType.values.map((type) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentView = type),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentView == type 
                            ? AppColors.primary 
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _currentView == type 
                              ? AppColors.primary 
                              : AppColors.outline,
                          ),
                        ),
                        child: Text(
                          type.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _currentView == type 
                              ? Colors.white 
                              : AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentView) {
      case StepsViewType.daily:
        return _buildDailyView();
      case StepsViewType.weekly:
        return _buildWeeklyView();
      case StepsViewType.monthly:
        return _buildMonthlyView();
    }
  }

  Widget _buildDailyView() {
    const int dailyGoal = 10000;
    final double progress = (_todaySteps / dailyGoal).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's stats card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Circular progress indicator
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: AppColors.outline,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : AppColors.primary,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_todaySteps',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'steps',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress * 100).round()}% of goal',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: progress >= 1.0 ? Colors.green : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Goal',
                        '$dailyGoal',
                        Icons.flag,
                        AppColors.secondary,
                      ),
                      _buildStatItem(
                        'Distance',
                        '${(_todaySteps * 0.75 / 1000).toStringAsFixed(1)} km',
                        Icons.straighten,
                        AppColors.tertiary,
                      ),
                      _buildStatItem(
                        'Calories',
                        '${(_todaySteps * 0.04).round()}',
                        Icons.local_fire_department,
                        AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Motivational message
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    progress >= 1.0 ? Icons.celebration : Icons.trending_up,
                    color: progress >= 1.0 ? Colors.green : AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      progress >= 1.0
                        ? 'Congratulations! You\'ve reached your daily goal!'
                        : 'Keep going! You need ${dailyGoal - _todaySteps} more steps to reach your goal.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    final chartData = _weeklyData.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      return StepChartData(dayName, entry.value);
    }).toList();

    final totalWeeklySteps = _weeklyData.values.fold(0, (sum, steps) => sum + steps);
    final averageSteps = totalWeeklySteps / 7;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Total',
                        '${(totalWeeklySteps / 1000).toStringAsFixed(1)}K',
                        Icons.directions_walk,
                        AppColors.primary,
                      ),
                      _buildStatItem(
                        'Daily Avg',
                        '${averageSteps.round()}',
                        Icons.show_chart,
                        AppColors.secondary,
                      ),
                      _buildStatItem(
                        'Best Day',
                        '${_weeklyData.values.reduce((a, b) => a > b ? a : b)}',
                        Icons.star,
                        AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Weekly chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Steps'),
                      ),
                      series: <ColumnSeries<StepChartData, String>>[
                        ColumnSeries<StepChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (StepChartData data, _) => data.day,
                          yValueMapper: (StepChartData data, _) => data.steps,
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    final chartData = <StepChartData>[];
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    // Group days into weeks for the chart
    for (int week = 1; week <= 4; week++) {
      int weeklyTotal = 0;
      // ignore: unused_local_variable
      int daysInWeek = 0;
      
      for (int day = ((week - 1) * 7) + 1; day <= (week * 7) && day <= daysInMonth; day++) {
        final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        weeklyTotal += _monthlyData[dateKey] ?? 0;
        daysInWeek++;
      }
      
      chartData.add(StepChartData('Week $week', weeklyTotal));
    }

    final totalMonthlySteps = _monthlyData.values.fold(0, (sum, steps) => sum + steps);
    final averageSteps = totalMonthlySteps / daysInMonth;
    final bestDay = _monthlyData.values.isNotEmpty 
      ? _monthlyData.values.reduce((a, b) => a > b ? a : b) 
      : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'This Month',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Total',
                        '${(totalMonthlySteps / 1000).toStringAsFixed(0)}K',
                        Icons.directions_walk,
                        AppColors.primary,
                      ),
                      _buildStatItem(
                        'Daily Avg',
                        '${averageSteps.round()}',
                        Icons.show_chart,
                        AppColors.secondary,
                      ),
                      _buildStatItem(
                        'Best Day',
                        '$bestDay',
                        Icons.star,
                        AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Monthly chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Progress (Weekly Totals)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Steps'),
                      ),
                      series: <LineSeries<StepChartData, String>>[
                        LineSeries<StepChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (StepChartData data, _) => data.day,
                          yValueMapper: (StepChartData data, _) => data.steps,
                          color: AppColors.primary,
                          width: 3,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            height: 6,
                            width: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class StepChartData {
  StepChartData(this.day, this.steps);
  final String day;
  final int steps;
}