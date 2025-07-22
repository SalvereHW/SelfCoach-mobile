import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../state/health.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';

enum HeartRateViewType { daily, weekly, monthly }

class HeartRateDetailScreen extends StatefulWidget {
  const HeartRateDetailScreen({super.key});

  @override
  State<HeartRateDetailScreen> createState() => _HeartRateDetailScreenState();
}

class _HeartRateDetailScreenState extends State<HeartRateDetailScreen> {
  HeartRateViewType _currentView = HeartRateViewType.daily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Heart Rate Trends'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface),
        actions: [
          Consumer<HealthState>(
            builder: (context, healthState, child) {
              return IconButton(
                onPressed: () => healthState.loadHealthData(),
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: Column(
          children: [
            // View selector tabs
            Container(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: HeartRateViewType.values.map((type) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentView = type;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentView == type 
                                ? AppColors.primary 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getViewTypeLabel(type),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _currentView == type 
                                  ? Colors.white 
                                  : AppColors.onSurface,
                              fontWeight: _currentView == type 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: Consumer<HealthState>(
                builder: (context, healthState, child) {
                  if (healthState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryCard(healthState),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildChart(healthState),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getViewTypeLabel(HeartRateViewType type) {
    switch (type) {
      case HeartRateViewType.daily:
        return 'Daily';
      case HeartRateViewType.weekly:
        return 'Weekly';
      case HeartRateViewType.monthly:
        return 'Monthly';
    }
  }

  Widget _buildSummaryCard(HealthState healthState) {
    final currentHeartRate = healthState.mostRecentAverageHeartRate;
    final avgHeartRate = _getAverageHeartRate(healthState);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Current',
                '$currentHeartRate bpm',
                Icons.favorite,
                AppColors.error,
              ),
              _buildStatItem(
                'Average',
                '$avgHeartRate bpm',
                Icons.analytics,
                AppColors.primary,
              ),
              _buildStatItem(
                'Zone',
                _getHeartRateZone(currentHeartRate),
                Icons.circle,
                _getHeartRateZoneColor(currentHeartRate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(HealthState healthState) {
    final chartData = _getChartData(healthState);
    
    if (chartData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No heart rate data available',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging activities to see your heart rate trends',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Heart Rate Trends',
          textStyle: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        primaryXAxis: DateTimeAxis(
          dateFormat: _getDateFormat(),
          intervalType: _getIntervalType(),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Heart Rate (bpm)'),
          minimum: 50,
          maximum: 200,
        ),
        series: <CartesianSeries>[
          LineSeries<_HeartRateData, DateTime>(
            dataSource: chartData,
            xValueMapper: (_HeartRateData data, _) => data.date,
            yValueMapper: (_HeartRateData data, _) => data.heartRate,
            color: AppColors.error,
            markerSettings: const MarkerSettings(isVisible: true),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
      ),
    );
  }

  List<_HeartRateData> _getChartData(HealthState healthState) {
    final now = DateTime.now();
    final activities = healthState.activityData
        .where((activity) => activity.averageHeartRate != null);

    switch (_currentView) {
      case HeartRateViewType.daily:
        // Last 7 days
        final startDate = now.subtract(const Duration(days: 6));
        return activities
            .where((activity) => activity.date.isAfter(startDate.subtract(const Duration(days: 1))))
            .map((activity) => _HeartRateData(activity.date, activity.averageHeartRate!))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

      case HeartRateViewType.weekly:
        // Last 4 weeks
        final startDate = now.subtract(const Duration(days: 28));
        final weeklyData = <DateTime, List<int>>{};
        
        for (final activity in activities) {
          if (activity.date.isAfter(startDate.subtract(const Duration(days: 1)))) {
            final weekStart = activity.date.subtract(Duration(days: activity.date.weekday - 1));
            final weekKey = DateTime(weekStart.year, weekStart.month, weekStart.day);
            
            weeklyData[weekKey] ??= [];
            weeklyData[weekKey]!.add(activity.averageHeartRate!);
          }
        }
        
        return weeklyData.entries
            .map((entry) {
              final avgHeartRate = entry.value.reduce((a, b) => a + b) / entry.value.length;
              return _HeartRateData(entry.key, avgHeartRate.round());
            })
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

      case HeartRateViewType.monthly:
        // Last 6 months
        final startDate = DateTime(now.year, now.month - 5, 1);
        final monthlyData = <DateTime, List<int>>{};
        
        for (final activity in activities) {
          if (activity.date.isAfter(startDate.subtract(const Duration(days: 1)))) {
            final monthKey = DateTime(activity.date.year, activity.date.month, 1);
            
            monthlyData[monthKey] ??= [];
            monthlyData[monthKey]!.add(activity.averageHeartRate!);
          }
        }
        
        return monthlyData.entries
            .map((entry) {
              final avgHeartRate = entry.value.reduce((a, b) => a + b) / entry.value.length;
              return _HeartRateData(entry.key, avgHeartRate.round());
            })
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    }
  }

  int _getAverageHeartRate(HealthState healthState) {
    final activities = healthState.activityData
        .where((activity) => activity.averageHeartRate != null);
    
    if (activities.isEmpty) return 0;
    
    final total = activities.fold(0, (sum, activity) => sum + activity.averageHeartRate!);
    return (total / activities.length).round();
  }

  String _getHeartRateZone(int heartRate) {
    if (heartRate == 0) return 'N/A';
    if (heartRate < 60) return 'Rest';
    if (heartRate < 100) return 'Normal';
    if (heartRate < 140) return 'Fat Burn';
    if (heartRate < 170) return 'Cardio';
    return 'Peak';
  }

  Color _getHeartRateZoneColor(int heartRate) {
    if (heartRate == 0) return AppColors.onSurfaceVariant;
    if (heartRate < 60) return AppColors.info;
    if (heartRate < 100) return AppColors.success;
    if (heartRate < 140) return AppColors.warning;
    if (heartRate < 170) return AppColors.error;
    return const Color(0xFF8B0000); // Dark red for peak
  }

  dynamic _getDateFormat() {
    switch (_currentView) {
      case HeartRateViewType.daily:
        return 'MMM dd';
      case HeartRateViewType.weekly:
        return 'MMM dd';
      case HeartRateViewType.monthly:
        return 'MMM yyyy';
    }
  }

  DateTimeIntervalType _getIntervalType() {
    switch (_currentView) {
      case HeartRateViewType.daily:
        return DateTimeIntervalType.days;
      case HeartRateViewType.weekly:
        return DateTimeIntervalType.days;
      case HeartRateViewType.monthly:
        return DateTimeIntervalType.months;
    }
  }
}

class _HeartRateData {
  final DateTime date;
  final int heartRate;

  _HeartRateData(this.date, this.heartRate);
}