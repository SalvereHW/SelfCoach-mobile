import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../state/health.dart';
import '../models/health_metrics.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart' hide AppSpacing;
import '../design_system/app_spacing.dart';

class HealthChartsScreen extends StatefulWidget {
  const HealthChartsScreen({super.key});

  @override
  State<HealthChartsScreen> createState() => _HealthChartsScreenState();
}

class _HealthChartsScreenState extends State<HealthChartsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeRange = 7; // Days

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Health Charts', style: AppTypography.headlineSmall),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
              const PopupMenuItem(value: 90, child: Text('Last 3 months')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: AppTypography.labelMedium,
          tabs: const [
            Tab(icon: Icon(Icons.bedtime), text: 'Sleep'),
            Tab(icon: Icon(Icons.restaurant), text: 'Nutrition'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Activity'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<HealthState>(
        builder: (context, healthState, child) {
          if (healthState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSleepCharts(healthState),
              _buildNutritionCharts(healthState),
              _buildActivityCharts(healthState),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _buildSleepCharts(HealthState healthState) {
    final sleepData = _getFilteredSleepData(healthState);
    
    if (sleepData.isEmpty) {
      return _buildEmptyState('No sleep data available', 'Start logging your sleep to see charts');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSleepDurationChart(sleepData),
          const SizedBox(height: AppSpacing.md),
          _buildSleepQualityChart(sleepData),
          const SizedBox(height: AppSpacing.md),
          _buildSleepTimeChart(sleepData),
        ],
      ),
    );
  }

  Widget _buildNutritionCharts(HealthState healthState) {
    final nutritionData = _getFilteredNutritionData(healthState);
    
    if (nutritionData.isEmpty) {
      return _buildEmptyState('No nutrition data available', 'Start logging your meals to see charts');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCaloriesChart(nutritionData),
          const SizedBox(height: AppSpacing.md),
          _buildMacronutrientsChart(nutritionData),
          const SizedBox(height: AppSpacing.md),
          _buildWaterIntakeChart(nutritionData),
        ],
      ),
    );
  }

  Widget _buildActivityCharts(HealthState healthState) {
    final activityData = _getFilteredActivityData(healthState);
    
    if (activityData.isEmpty) {
      return _buildEmptyState('No activity data available', 'Start logging your activities to see charts');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCaloriesBurnedChart(activityData),
          const SizedBox(height: AppSpacing.md),
          _buildActivityDurationChart(activityData),
          const SizedBox(height: AppSpacing.md),
          _buildStepsChart(activityData),
        ],
      ),
    );
  }

  Widget _buildSleepDurationChart(List<SleepMetrics> data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Duration',
              style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Hours'),
                  minimum: 0,
                  maximum: 12,
                ),
                series: <CartesianSeries>[
                  LineSeries<SleepMetrics, DateTime>(
                    dataSource: data,
                    xValueMapper: (SleepMetrics sleep, _) => sleep.date,
                    yValueMapper: (SleepMetrics sleep, _) => sleep.duration?.inHours.toDouble() ?? 0,
                    color: AppColors.sleepMetrics,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualityChart(List<SleepMetrics> data) {
    final qualityData = _aggregateSleepQuality(data);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Quality Distribution',
              style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<_QualityData, String>(
                    dataSource: qualityData,
                    xValueMapper: (_QualityData data, _) => data.quality,
                    yValueMapper: (_QualityData data, _) => data.count,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    pointColorMapper: (_QualityData data, _) => _getSleepQualityColor(data.quality),
                  ),
                ],
                legend: const Legend(isVisible: true, position: LegendPosition.bottom),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTimeChart(List<SleepMetrics> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Hour'),
                  minimum: 0,
                  maximum: 24,
                ),
                series: <CartesianSeries>[
                  LineSeries<SleepMetrics, DateTime>(
                    name: 'Bedtime',
                    dataSource: data,
                    xValueMapper: (SleepMetrics sleep, _) => sleep.date,
                    yValueMapper: (SleepMetrics sleep, _) => sleep.bedTime?.hour.toDouble() ?? 0,
                    color: AppColors.primary,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<SleepMetrics, DateTime>(
                    name: 'Wake time',
                    dataSource: data,
                    xValueMapper: (SleepMetrics sleep, _) => sleep.date,
                    yValueMapper: (SleepMetrics sleep, _) => sleep.wakeTime?.hour.toDouble() ?? 0,
                    color: AppColors.secondary,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
                legend: const Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(List<NutritionMetrics> data) {
    final dailyCalories = _aggregateDailyCalories(data);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Calories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Calories'),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<_DailyCalories, DateTime>(
                    dataSource: dailyCalories,
                    xValueMapper: (_DailyCalories data, _) => data.date,
                    yValueMapper: (_DailyCalories data, _) => data.calories,
                    color: Colors.orange,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacronutrientsChart(List<NutritionMetrics> data) {
    final macroData = _aggregateMacronutrients(data);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<_MacroData, String>(
                    dataSource: macroData,
                    xValueMapper: (_MacroData data, _) => data.type,
                    yValueMapper: (_MacroData data, _) => data.grams,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    pointColorMapper: (_MacroData data, _) => _getMacroColor(data.type),
                  ),
                ],
                legend: const Legend(isVisible: true, position: LegendPosition.bottom),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntakeChart(List<NutritionMetrics> data) {
    final dailyWater = _aggregateDailyWater(data);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Water Intake',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'ml'),
                ),
                series: <CartesianSeries>[
                  SplineAreaSeries<_DailyWater, DateTime>(
                    dataSource: dailyWater,
                    xValueMapper: (_DailyWater data, _) => data.date,
                    yValueMapper: (_DailyWater data, _) => data.water,
                    color: Colors.blue.withValues(alpha: 0.3),
                    borderColor: Colors.blue,
                    borderWidth: 2,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesBurnedChart(List<ActivityMetrics> data) {
    final dailyBurned = _aggregateDailyCaloriesBurned(data);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calories Burned',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Calories'),
                ),
                series: <CartesianSeries>[
                  AreaSeries<_DailyCaloriesBurned, DateTime>(
                    dataSource: dailyBurned,
                    xValueMapper: (_DailyCaloriesBurned data, _) => data.date,
                    yValueMapper: (_DailyCaloriesBurned data, _) => data.calories,
                    color: Colors.red.withValues(alpha: 0.3),
                    borderColor: Colors.red,
                    borderWidth: 2,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDurationChart(List<ActivityMetrics> data) {
    final dailyDuration = _aggregateDailyActivityDuration(data);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Duration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Minutes'),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<_DailyDuration, DateTime>(
                    dataSource: dailyDuration,
                    xValueMapper: (_DailyDuration data, _) => data.date,
                    yValueMapper: (_DailyDuration data, _) => data.minutes,
                    color: Colors.green,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsChart(List<ActivityMetrics> data) {
    final dailySteps = _aggregateDailySteps(data);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Steps'),
                ),
                series: <CartesianSeries>[
                  LineSeries<_DailySteps, DateTime>(
                    dataSource: dailySteps,
                    xValueMapper: (_DailySteps data, _) => data.date,
                    yValueMapper: (_DailySteps data, _) => data.steps,
                    color: Colors.purple,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<SleepMetrics> _getFilteredSleepData(HealthState healthState) {
    final cutoffDate = DateTime.now().subtract(Duration(days: _selectedTimeRange));
    return healthState.sleepData
        .where((sleep) => sleep.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<NutritionMetrics> _getFilteredNutritionData(HealthState healthState) {
    final cutoffDate = DateTime.now().subtract(Duration(days: _selectedTimeRange));
    return healthState.nutritionData
        .where((nutrition) => nutrition.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<ActivityMetrics> _getFilteredActivityData(HealthState healthState) {
    final cutoffDate = DateTime.now().subtract(Duration(days: _selectedTimeRange));
    return healthState.activityData
        .where((activity) => activity.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_QualityData> _aggregateSleepQuality(List<SleepMetrics> data) {
    final qualityCount = <SleepQuality, int>{};
    for (final sleep in data) {
      qualityCount[sleep.quality] = (qualityCount[sleep.quality] ?? 0) + 1;
    }
    
    return qualityCount.entries
        .map((entry) => _QualityData(_getSleepQualityLabel(entry.key), entry.value))
        .toList();
  }

  List<_DailyCalories> _aggregateDailyCalories(List<NutritionMetrics> data) {
    final dailyMap = <DateTime, int>{};
    for (final nutrition in data) {
      final date = DateTime(nutrition.date.year, nutrition.date.month, nutrition.date.day);
      dailyMap[date] = (dailyMap[date] ?? 0) + (nutrition.calories ?? 0);
    }
    
    return dailyMap.entries
        .map((entry) => _DailyCalories(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_MacroData> _aggregateMacronutrients(List<NutritionMetrics> data) {
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    
    for (final nutrition in data) {
      totalProtein += nutrition.protein ?? 0;
      totalCarbs += nutrition.carbs ?? 0;
      totalFats += nutrition.fats ?? 0;
    }
    
    return [
      _MacroData('Protein', totalProtein),
      _MacroData('Carbs', totalCarbs),
      _MacroData('Fats', totalFats),
    ];
  }

  List<_DailyWater> _aggregateDailyWater(List<NutritionMetrics> data) {
    final dailyMap = <DateTime, int>{};
    for (final nutrition in data) {
      final date = DateTime(nutrition.date.year, nutrition.date.month, nutrition.date.day);
      dailyMap[date] = (dailyMap[date] ?? 0) + (nutrition.waterIntake ?? 0);
    }
    
    return dailyMap.entries
        .map((entry) => _DailyWater(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_DailyCaloriesBurned> _aggregateDailyCaloriesBurned(List<ActivityMetrics> data) {
    final dailyMap = <DateTime, int>{};
    for (final activity in data) {
      final date = DateTime(activity.date.year, activity.date.month, activity.date.day);
      dailyMap[date] = (dailyMap[date] ?? 0) + (activity.caloriesBurned ?? 0);
    }
    
    return dailyMap.entries
        .map((entry) => _DailyCaloriesBurned(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_DailyDuration> _aggregateDailyActivityDuration(List<ActivityMetrics> data) {
    final dailyMap = <DateTime, int>{};
    for (final activity in data) {
      final date = DateTime(activity.date.year, activity.date.month, activity.date.day);
      dailyMap[date] = (dailyMap[date] ?? 0) + (activity.duration?.inMinutes ?? 0);
    }
    
    return dailyMap.entries
        .map((entry) => _DailyDuration(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_DailySteps> _aggregateDailySteps(List<ActivityMetrics> data) {
    final dailyMap = <DateTime, int>{};
    for (final activity in data) {
      final date = DateTime(activity.date.year, activity.date.month, activity.date.day);
      dailyMap[date] = (dailyMap[date] ?? 0) + (activity.steps ?? 0);
    }
    
    return dailyMap.entries
        .map((entry) => _DailySteps(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _getSleepQualityLabel(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.excellent:
        return 'Excellent';
    }
  }

  Color _getSleepQualityColor(String quality) {
    switch (quality) {
      case 'Poor':
        return Colors.red;
      case 'Fair':
        return Colors.orange;
      case 'Good':
        return Colors.blue;
      case 'Excellent':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getMacroColor(String macro) {
    switch (macro) {
      case 'Protein':
        return Colors.red;
      case 'Carbs':
        return Colors.orange;
      case 'Fats':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

// Helper classes for chart data
class _QualityData {
  final String quality;
  final int count;
  _QualityData(this.quality, this.count);
}

class _DailyCalories {
  final DateTime date;
  final int calories;
  _DailyCalories(this.date, this.calories);
}

class _MacroData {
  final String type;
  final double grams;
  _MacroData(this.type, this.grams);
}

class _DailyWater {
  final DateTime date;
  final int water;
  _DailyWater(this.date, this.water);
}

class _DailyCaloriesBurned {
  final DateTime date;
  final int calories;
  _DailyCaloriesBurned(this.date, this.calories);
}

class _DailyDuration {
  final DateTime date;
  final int minutes;
  _DailyDuration(this.date, this.minutes);
}

class _DailySteps {
  final DateTime date;
  final int steps;
  _DailySteps(this.date, this.steps);
}