import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../animations/animation_constants.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  gradient,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final Gradient? gradient;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.gradient,
  });
  
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Size configurations
    double horizontalPadding;
    double verticalPadding;
    double fontSize;
    double iconSize;
    
    switch (widget.size) {
      case ButtonSize.small:
        horizontalPadding = AppSpacing.lg;
        verticalPadding = AppSpacing.sm;
        fontSize = 12;
        iconSize = 16;
        break;
      case ButtonSize.medium:
        horizontalPadding = AppSpacing.xxl;
        verticalPadding = AppSpacing.md;
        fontSize = 14;
        iconSize = 18;
        break;
      case ButtonSize.large:
        horizontalPadding = AppSpacing.xxxl;
        verticalPadding = AppSpacing.lg;
        fontSize = 16;
        iconSize = 20;
        break;
    }
    
    // Color configurations
    Color? backgroundColor;
    Color? textColor;
    Color? borderColor;
    BoxBorder? border;
    Gradient? gradient;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        backgroundColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        textColor = isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;
        break;
      case ButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case ButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        textColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        borderColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        border = Border.all(color: borderColor, width: 2);
        break;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        textColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        break;
      case ButtonVariant.gradient:
        gradient = widget.gradient ?? (isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient);
        textColor = Colors.white;
        break;
    }
    
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: AnimationConstants.fast,
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: gradient,
              border: border,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: widget.variant == ButtonVariant.primary ||
                      widget.variant == ButtonVariant.gradient
                  ? [
                      BoxShadow(
                        color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: fontSize + 4,
                    width: fontSize + 4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor!),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: iconSize,
                          color: textColor,
                        ),
                        SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
