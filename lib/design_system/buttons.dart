import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';

/// World-class button system for SelfCoach wellness app
/// Optimized for health apps with proper sizing and accessibility
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  });

  // Factory constructors for common button patterns
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : type = ButtonType.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : type = ButtonType.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : type = ButtonType.outline;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : type = ButtonType.text;

  const AppButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : type = ButtonType.success;

  @override
  Widget build(BuildContext context) {
    final buttonSpec = _getButtonSpec();
    final isEnabled = onPressed != null && !isLoading;

    Widget child = _buildButtonContent();

    if (isLoading) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: buttonSpec.iconSize,
            height: buttonSpec.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: buttonSpec.textStyle),
        ],
      );
    }

    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(buttonSpec, child, isEnabled);
      case ButtonType.secondary:
        return _buildFilledTonalButton(buttonSpec, child, isEnabled);
      case ButtonType.outline:
        return _buildOutlinedButton(buttonSpec, child, isEnabled);
      case ButtonType.text:
        return _buildTextButton(buttonSpec, child, isEnabled);
      case ButtonType.success:
        return _buildSuccessButton(buttonSpec, child, isEnabled);
    }
  }

  Widget _buildButtonContent() {
    if (icon != null && !isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }

  Widget _buildElevatedButton(ButtonSpec spec, Widget child, bool isEnabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: spec.height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.outline,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.borderRadius),
          ),
          padding: padding ?? spec.padding,
          textStyle: spec.textStyle,
          minimumSize: Size(spec.minWidth, spec.height),
        ),
        child: child,
      ),
    );
  }

  Widget _buildFilledTonalButton(ButtonSpec spec, Widget child, bool isEnabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: spec.height,
      child: FilledButton.tonal(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.secondary,
          disabledBackgroundColor: AppColors.outline,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.borderRadius),
          ),
          padding: padding ?? spec.padding,
          textStyle: spec.textStyle,
          minimumSize: Size(spec.minWidth, spec.height),
        ),
        child: child,
      ),
    );
  }

  Widget _buildOutlinedButton(ButtonSpec spec, Widget child, bool isEnabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: spec.height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          side: BorderSide(
            color: isEnabled ? AppColors.primary : AppColors.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.borderRadius),
          ),
          padding: padding ?? spec.padding,
          textStyle: spec.textStyle,
          minimumSize: Size(spec.minWidth, spec.height),
        ),
        child: child,
      ),
    );
  }

  Widget _buildTextButton(ButtonSpec spec, Widget child, bool isEnabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: spec.height,
      child: TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.borderRadius),
          ),
          padding: padding ?? spec.padding,
          textStyle: spec.textStyle,
          minimumSize: Size(spec.minWidth, spec.height),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSuccessButton(ButtonSpec spec, Widget child, bool isEnabled) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: spec.height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.outline,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.borderRadius),
          ),
          padding: padding ?? spec.padding,
          textStyle: spec.textStyle,
          minimumSize: Size(spec.minWidth, spec.height),
        ),
        child: child,
      ),
    );
  }

  ButtonSpec _getButtonSpec() {
    switch (size) {
      case ButtonSize.small:
        return ButtonSpec(
          height: 36.0,
          minWidth: 88.0,
          borderRadius: 8.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          textStyle: AppTypography.buttonSmall,
          iconSize: 16.0,
        );
      case ButtonSize.medium:
        return ButtonSpec(
          height: 48.0, // Optimized for health apps - larger touch target
          minWidth: 120.0,
          borderRadius: 12.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          textStyle: AppTypography.buttonMedium,
          iconSize: 20.0,
        );
      case ButtonSize.large:
        return ButtonSpec(
          height: 56.0, // Extra large for primary actions
          minWidth: 140.0,
          borderRadius: 16.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          textStyle: AppTypography.buttonLarge,
          iconSize: 24.0,
        );
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
      case ButtonType.text:
        return AppColors.primary;
    }
  }
}

/// Button types for different use cases
enum ButtonType {
  primary,   // Main call-to-action buttons
  secondary, // Secondary actions
  outline,   // Outline style for less emphasis
  text,      // Text-only buttons for minimal actions
  success,   // Success/completion actions
}

/// Button sizes optimized for health apps
enum ButtonSize {
  small,   // 36dp height - for secondary actions
  medium,  // 48dp height - standard size for health apps
  large,   // 56dp height - for primary CTAs
}

/// Button specifications for consistent sizing
class ButtonSpec {
  final double height;
  final double minWidth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final double iconSize;

  const ButtonSpec({
    required this.height,
    required this.minWidth,
    required this.borderRadius,
    required this.padding,
    required this.textStyle,
    required this.iconSize,
  });
}

/// Floating Action Button for primary wellness actions
class WellnessFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? backgroundColor;

  const WellnessFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: icon,
    );
  }
}

/// Icon button for wellness actions
class WellnessIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? color;
  final double size;

  const WellnessIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
      color: color ?? AppColors.onSurface,
      iconSize: size,
      constraints: BoxConstraints(
        minWidth: size + 24, // 48dp minimum touch target
        minHeight: size + 24,
      ),
    );
  }
}

/// Chip button for tags and filters
class WellnessChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? avatar;
  final Color? backgroundColor;
  final Color? selectedColor;

  const WellnessChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.avatar,
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      avatar: avatar,
      backgroundColor: backgroundColor ?? AppColors.surface,
      selectedColor: selectedColor ?? AppColors.primaryContainer,
      checkmarkColor: AppColors.primary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.outline,
        ),
      ),
    );
  }
}