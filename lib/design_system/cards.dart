import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';

/// Modern card component system for SelfCoach health app
/// Optimized for health data visualization and user engagement
class HealthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool elevated;
  final Color? backgroundColor;
  final Border? border;
  final List<Color>? gradientColors;
  final bool isInteractive;

  const HealthCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.elevated = false,
    this.backgroundColor,
    this.border,
    this.gradientColors,
    this.isInteractive = true,
  });

  // Factory constructors for common health card patterns
  const HealthCard.metric({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.elevated = true,
    this.backgroundColor,
    this.border,
    this.gradientColors,
    this.isInteractive = true,
  });

  const HealthCard.progress({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.elevated = false,
    this.backgroundColor,
    this.border,
    this.gradientColors,
    this.isInteractive = true,
  });

  const HealthCard.wellness({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.elevated = true,
    this.backgroundColor,
    this.border,
    this.gradientColors,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasGradient = gradientColors != null && gradientColors!.length >= 2;
    final cardColor = backgroundColor ?? AppColors.surface;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: hasGradient ? null : cardColor,
        gradient: hasGradient 
          ? LinearGradient(
              colors: gradientColors!,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
        border: border,
        borderRadius: BorderRadius.circular(16), // Health app standard
        boxShadow: elevated 
          ? _getCardShadow()
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );

    if (isInteractive && (onTap != null || onLongPress != null)) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }

    return card;
  }

  List<BoxShadow> _getCardShadow() {
    return [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// Metric display card for health data
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? subtitle;
  final Widget? icon;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double? progress;
  final Color? progressColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    this.trailing,
    this.progress,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final metricColor = color ?? AppColors.primary;
    
    return HealthCard.metric(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and icon
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: metricColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: metricColor,
                      size: 20,
                    ),
                    child: icon!,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Main metric value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.metric.copyWith(
                  color: metricColor,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: AppTypography.metricLabel.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          
          // Progress indicator
          if (progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress!.clamp(0.0, 1.0),
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? metricColor,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
    );
  }
}

/// Activity card for wellness sessions and activities
class ActivityCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Duration? duration;
  final Widget icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? status;
  final bool completed;

  const ActivityCard({
    super.key,
    required this.title,
    this.subtitle,
    this.duration,
    required this.icon,
    this.color,
    this.onTap,
    this.status,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final activityColor = color ?? AppColors.secondary;
    
    return HealthCard.wellness(
      onTap: onTap,
      gradientColors: [
        activityColor.withValues(alpha: 0.05),
        activityColor.withValues(alpha: 0.1),
      ],
      child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: activityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconTheme(
              data: IconThemeData(
                color: activityColor,
                size: 28,
              ),
              child: icon,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Status row
                Row(
                  children: [
                    if (duration != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(duration!),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    
                    if (status != null) ...[
                      if (duration != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        status!,
                        style: AppTypography.bodySmall.copyWith(
                          color: completed ? AppColors.success : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Trailing action indicator
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = duration.inHours;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
  }
}

/// Progress summary card
class ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String progressText;
  final Color? color;
  final Widget? icon;
  final List<ProgressItem>? details;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.progressText,
    this.color,
    this.icon,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppColors.primary;
    
    return HealthCard.progress(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: progressColor,
                    size: 24,
                  ),
                  child: icon!,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                progressText,
                style: AppTypography.titleSmall.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.outline,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          
          // Details
          if (details != null && details!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...details!.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.color ?? progressColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  Text(
                    item.value,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

/// Supporting class for progress details
class ProgressItem {
  final String label;
  final String value;
  final Color? color;

  const ProgressItem({
    required this.label,
    required this.value,
    this.color,
  });
}

/// Insight card for health tips and recommendations
class InsightCard extends StatelessWidget {
  final String title;
  final String message;
  final InsightType type;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const InsightCard({
    super.key,
    required this.title,
    required this.message,
    this.type = InsightType.info,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final insightData = _getInsightData(type);
    
    return HealthCard(
      onTap: onTap,
      gradientColors: [
        insightData.color.withValues(alpha: 0.05),
        insightData.color.withValues(alpha: 0.1),
      ],
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insightData.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insightData.icon,
              color: insightData.color,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: insightData.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }

  _InsightData _getInsightData(InsightType type) {
    switch (type) {
      case InsightType.success:
        return _InsightData(
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case InsightType.warning:
        return _InsightData(
          color: AppColors.warning,
          icon: Icons.warning,
        );
      case InsightType.error:
        return _InsightData(
          color: AppColors.error,
          icon: Icons.error,
        );
      case InsightType.info:
        return _InsightData(
          color: AppColors.info,
          icon: Icons.lightbulb,
        );
    }
  }
}

enum InsightType { success, warning, error, info }

class _InsightData {
  final Color color;
  final IconData icon;

  _InsightData({
    required this.color,
    required this.icon,
  });
}