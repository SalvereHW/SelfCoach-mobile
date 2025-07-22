import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/typography.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class SelfCoachButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const SelfCoachButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  });

  const SelfCoachButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  }) : type = ButtonType.primary;

  const SelfCoachButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  }) : type = ButtonType.secondary;

  const SelfCoachButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  }) : type = ButtonType.outline;

  const SelfCoachButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  }) : type = ButtonType.text;

  const SelfCoachButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
  }) : type = ButtonType.danger;

  @override
  State<SelfCoachButton> createState() => _SelfCoachButtonState();
}

class _SelfCoachButtonState extends State<SelfCoachButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final buttonStyle = _getButtonStyle(theme, colorScheme);
    
    Widget child = _buildButtonContent(theme);
    
    if (widget.fullWidth) {
      child = SizedBox(width: double.infinity, child: child);
    }

    Widget button;
    switch (widget.type) {
      case ButtonType.primary:
        button = FilledButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case ButtonType.secondary:
        button = FilledButton.tonal(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case ButtonType.danger:
        button = FilledButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(colorScheme.error),
            foregroundColor: WidgetStateProperty.all(colorScheme.onError),
          ),
          child: child,
        );
        break;
    }

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading ? _onTapDown : null,
      onTapUp: widget.onPressed != null && !widget.isLoading ? _onTapUp : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: button,
          );
        },
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (widget.isLoading) {
      return SizedBox(
        height: _getButtonHeight(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: _getIconSize(),
              height: _getIconSize(),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTextColor(theme.colorScheme),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.text, style: _getTextStyle(theme)),
          ],
        ),
      );
    }

    if (widget.icon != null) {
      return SizedBox(
        height: _getButtonHeight(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: _getIconSize()),
            const SizedBox(width: 6), // Reduced from 8 to 6
            Flexible(
              child: Text(
                widget.text, 
                style: _getTextStyle(theme),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: _getButtonHeight(),
      child: Center(
        child: Text(widget.text, style: _getTextStyle(theme)),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(
        widget.padding ?? _getDefaultPadding(),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      elevation: _getElevation(),
      shadowColor: WidgetStateProperty.all(AppColors.shadowMedium),
      backgroundColor: _getBackgroundColor(colorScheme),
      foregroundColor: _getForegroundColor(colorScheme),
      overlayColor: _getOverlayColor(colorScheme),
      minimumSize: WidgetStateProperty.all(Size(0, _getButtonHeight())),
    );
  }
  
  WidgetStateProperty<double> _getElevation() {
    return WidgetStateProperty.resolveWith<double>((states) {
      if (states.contains(WidgetState.pressed)) {
        return widget.type == ButtonType.primary ? 1 : 0;
      }
      if (states.contains(WidgetState.hovered)) {
        return widget.type == ButtonType.primary ? 4 : 2;
      }
      return widget.type == ButtonType.primary ? 2 : 0;
    });
  }
  
  WidgetStateProperty<Color?> _getOverlayColor(ColorScheme colorScheme) {
    return WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return widget.type == ButtonType.primary ? Colors.white.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.hovered)) {
        return widget.type == ButtonType.primary ? Colors.white.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.04);
      }
      return null;
    });
  }

  WidgetStateProperty<Color?> _getBackgroundColor(ColorScheme colorScheme) {
    return WidgetStateProperty.resolveWith<Color?>((states) {
      switch (widget.type) {
        case ButtonType.primary:
          if (states.contains(WidgetState.pressed)) return AppColors.primaryDark;
          if (states.contains(WidgetState.hovered)) return AppColors.primaryLight;
          return AppColors.primary;
        case ButtonType.secondary:
          if (states.contains(WidgetState.pressed)) return AppColors.secondaryDark;
          if (states.contains(WidgetState.hovered)) return AppColors.secondaryLight;
          return AppColors.secondary;
        case ButtonType.outline:
          if (states.contains(WidgetState.pressed)) return AppColors.primaryContainer;
          if (states.contains(WidgetState.hovered)) return AppColors.primaryContainer.withValues(alpha: 0.5);
          return Colors.transparent;
        case ButtonType.text:
          if (states.contains(WidgetState.pressed)) return AppColors.primaryContainer;
          if (states.contains(WidgetState.hovered)) return AppColors.primaryContainer.withValues(alpha: 0.5);
          return Colors.transparent;
        case ButtonType.danger:
          if (states.contains(WidgetState.pressed)) return AppColors.error.withValues(alpha: 0.8);
          if (states.contains(WidgetState.hovered)) return AppColors.error.withValues(alpha: 1.1);
          return AppColors.error;
      }
    });
  }

  WidgetStateProperty<Color?> _getForegroundColor(ColorScheme colorScheme) {
    return WidgetStateProperty.resolveWith<Color?>((states) {
      switch (widget.type) {
        case ButtonType.primary:
          return Colors.white;
        case ButtonType.secondary:
          return Colors.white;
        case ButtonType.outline:
          if (states.contains(WidgetState.pressed)) return AppColors.primaryDark;
          return AppColors.primary;
        case ButtonType.text:
          if (states.contains(WidgetState.pressed)) return AppColors.primaryDark;
          return AppColors.primary;
        case ButtonType.danger:
          return Colors.white;
      }
    });
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = switch (widget.size) {
      ButtonSize.small => AppTypography.buttonSmall,
      ButtonSize.medium => AppTypography.buttonMedium,
      ButtonSize.large => AppTypography.buttonLarge,
    };

    return baseStyle.copyWith(
      color: _getTextColor(theme.colorScheme),
    );
  }

  Color _getTextColor(ColorScheme colorScheme) {
    switch (widget.type) {
      case ButtonType.primary:
        return colorScheme.onPrimary;
      case ButtonType.secondary:
        return colorScheme.onSecondaryContainer;
      case ButtonType.outline:
        return colorScheme.primary;
      case ButtonType.text:
        return colorScheme.primary;
      case ButtonType.danger:
        return colorScheme.onError;
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md);
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36; // Minimum for accessibility
      case ButtonSize.medium:
        return 48; // Health app optimized - larger touch target
      case ButtonSize.large:
        return 56; // Primary actions - extra large for health apps
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

// Quick action button for floating actions
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;

  const QuickActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final fab = FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      mini: mini,
      child: Icon(icon),
    );

    return tooltip != null 
        ? Tooltip(message: tooltip!, child: fab)
        : fab;
  }
}

// Modern toggle button with beautiful animations
class SelfCoachToggleButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final ButtonSize size;
  final Color? activeColor;
  final Color? inactiveColor;

  const SelfCoachToggleButton({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.activeIcon,
    this.inactiveIcon,
    this.size = ButtonSize.medium,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<SelfCoachToggleButton> createState() => _SelfCoachToggleButtonState();
}

class _SelfCoachToggleButtonState extends State<SelfCoachToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (widget.value) _controller.forward();
  }

  @override
  void didUpdateWidget(SelfCoachToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _toggleHeight {
    switch (widget.size) {
      case ButtonSize.small:
        return 24;
      case ButtonSize.medium:
        return 28;
      case ButtonSize.large:
        return 32;
    }
  }

  double get _toggleWidth => _toggleHeight * 1.8;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.primary;
    final inactiveColor = widget.inactiveColor ?? AppColors.outline;

    return GestureDetector(
      onTap: widget.onChanged != null ? () => widget.onChanged!(!widget.value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: _toggleWidth,
                height: _toggleHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_toggleHeight / 2),
                  color: Color.lerp(inactiveColor, activeColor, _animation.value),
                  boxShadow: AppColors.subtleShadow,
                ),
                padding: const EdgeInsets.all(2),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: widget.value ? _toggleWidth - _toggleHeight : 0,
                      top: 0,
                      child: Container(
                        width: _toggleHeight - 4,
                        height: _toggleHeight - 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.value
                              ? (widget.activeIcon ?? Icons.check)
                              : (widget.inactiveIcon ?? Icons.close),
                          size: (_toggleHeight - 4) * 0.6,
                          color: widget.value ? activeColor : inactiveColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.label != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.label!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Icon button with consistent styling
class SelfCoachIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final ButtonSize size;
  final Color? color;
  final Color? backgroundColor;

  const SelfCoachIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = ButtonSize.medium,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = switch (size) {
      ButtonSize.small => 18.0,
      ButtonSize.medium => 22.0,
      ButtonSize.large => 26.0,
    };

    final buttonSize = switch (size) {
      ButtonSize.small => 36.0,
      ButtonSize.medium => 48.0, // Updated to match button heights
      ButtonSize.large => 56.0,
    };

    final button = Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: backgroundColor != null ? AppColors.subtleShadow : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
        color: color ?? AppColors.onSurface,
        padding: EdgeInsets.zero,
      ),
    );

    return tooltip != null
        ? Tooltip(message: tooltip!, child: button)
        : button;
  }
}