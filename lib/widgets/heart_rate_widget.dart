import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/health.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';
import '../screens/heart_rate_detail_screen.dart';
import '../widgets/hero_page_route.dart';

class HeartRateWidget extends StatelessWidget {
  const HeartRateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthState>(
      builder: (context, healthState, child) {
        final currentHeartRate = healthState.mostRecentAverageHeartRate;
        final heartRateZone = _getHeartRateZone(currentHeartRate);
        final zoneColor = _getHeartRateZoneColor(currentHeartRate);
        
        return GestureDetector(
          onTap: () {
            AnimatedNavigator.slideToPage(
              context,
              const HeartRateDetailScreen(),
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
                      Icons.favorite,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Heart Rate',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentHeartRate.toString(),
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'bpm',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: zoneColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: zoneColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: zoneColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        heartRateZone,
                        style: AppTypography.labelSmall.copyWith(
                          color: zoneColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentHeartRate == 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap to view trends',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getHeartRateZone(int heartRate) {
    if (heartRate == 0) return 'No Data';
    if (heartRate < 60) return 'Rest Zone';
    if (heartRate < 100) return 'Normal';
    if (heartRate < 140) return 'Fat Burn';
    if (heartRate < 170) return 'Cardio';
    return 'Peak Zone';
  }

  Color _getHeartRateZoneColor(int heartRate) {
    if (heartRate == 0) return AppColors.onSurfaceVariant;
    if (heartRate < 60) return AppColors.info;
    if (heartRate < 100) return AppColors.success;
    if (heartRate < 140) return AppColors.warning;
    if (heartRate < 170) return AppColors.error;
    return const Color(0xFF8B0000); // Dark red for peak
  }
}