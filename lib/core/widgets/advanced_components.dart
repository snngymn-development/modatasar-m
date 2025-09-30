import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Advanced UI components for modern design
///
/// Usage:
/// ```dart
/// AdvancedCard(
///   child: Text('Content'),
///   onTap: () => print('Tapped'),
/// )
/// ```

/// Advanced card with animations and effects
class AdvancedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool enableHover;
  final bool enableRipple;
  final Duration animationDuration;

  const AdvancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.enableHover = true,
    this.enableRipple = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AdvancedCard> createState() => _AdvancedCardState();
}

class _AdvancedCardState extends State<AdvancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) + 4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            elevation: _elevationAnimation.value,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            color: widget.backgroundColor ?? Theme.of(context).cardColor,
            child: InkWell(
              onTap: widget.onTap != null
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.onTap!();
                    }
                  : null,
              onLongPress: widget.onLongPress != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      widget.onLongPress!();
                    }
                  : null,
              onTapDown: widget.enableRipple
                  ? (_) => _controller.forward()
                  : null,
              onTapUp: widget.enableRipple
                  ? (_) => _controller.reverse()
                  : null,
              onTapCancel: widget.enableRipple
                  ? () => _controller.reverse()
                  : null,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              child: Container(
                padding: widget.padding ?? const EdgeInsets.all(16),
                margin: widget.margin,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Advanced button with multiple styles
class AdvancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle? style;
  final bool isLoading;
  final bool isFullWidth;
  final AdvancedButtonType type;
  final AdvancedButtonSize size;

  const AdvancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style,
    this.isLoading = false,
    this.isFullWidth = false,
    this.type = AdvancedButtonType.primary,
    this.size = AdvancedButtonSize.medium,
  });

  @override
  State<AdvancedButton> createState() => _AdvancedButtonState();
}

class _AdvancedButtonState extends State<AdvancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;

    switch (widget.type) {
      case AdvancedButtonType.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case AdvancedButtonType.secondary:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        break;
      case AdvancedButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        break;
      case AdvancedButtonType.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        break;
    }

    double height;
    double fontSize;
    EdgeInsets padding;

    switch (widget.size) {
      case AdvancedButtonSize.small:
        height = 32;
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
      case AdvancedButtonSize.medium:
        height = 40;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        break;
      case AdvancedButtonSize.large:
        height = 48;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.isFullWidth ? double.infinity : null,
            height: height,
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      _controller.forward().then((_) => _controller.reverse());
                      widget.onPressed?.call();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                padding: padding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: widget.type == AdvancedButtonType.outline
                      ? BorderSide(color: colorScheme.primary)
                      : BorderSide.none,
                ),
                elevation: widget.type == AdvancedButtonType.outline ? 0 : 2,
              ).merge(widget.style),
              child: widget.isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foregroundColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: fontSize + 2),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// Advanced input field with validation and animations
class AdvancedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final AdvancedTextFieldType type;

  const AdvancedTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.type = AdvancedTextFieldType.outlined,
  });

  @override
  State<AdvancedTextField> createState() => _AdvancedTextFieldState();
}

class _AdvancedTextFieldState extends State<AdvancedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _isFocused
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              validator: widget.validator,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              onTap: () {
                setState(() => _isFocused = true);
                _controller.forward();
              },
              onTapOutside: (_) {
                setState(() => _isFocused = false);
                _controller.reverse();
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                errorText: widget.errorText,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                filled: widget.type == AdvancedTextFieldType.filled,
                border: widget.type == AdvancedTextFieldType.outlined
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isFocused
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: _isFocused ? 2.0 : 1.0,
                        ),
                      )
                    : null,
                enabledBorder: widget.type == AdvancedTextFieldType.outlined
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outline),
                      )
                    : null,
                focusedBorder: widget.type == AdvancedTextFieldType.outlined
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2.0,
                        ),
                      )
                    : null,
                errorBorder: widget.type == AdvancedTextFieldType.outlined
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.error),
                      )
                    : null,
                focusedErrorBorder:
                    widget.type == AdvancedTextFieldType.outlined
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.error,
                          width: 2.0,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Advanced loading indicator
class AdvancedLoadingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;
  final bool showMessage;

  const AdvancedLoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 24.0,
    this.showMessage = true,
  });

  @override
  State<AdvancedLoadingIndicator> createState() =>
      _AdvancedLoadingIndicatorState();
}

class _AdvancedLoadingIndicatorState extends State<AdvancedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 2 * 3.14159,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Advanced empty state widget
class AdvancedEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final Color? iconColor;

  const AdvancedEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: iconColor ?? colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Button types
enum AdvancedButtonType { primary, secondary, outline, ghost }

/// Button sizes
enum AdvancedButtonSize { small, medium, large }

/// Text field types
enum AdvancedTextFieldType { outlined, filled, underlined }
