import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../animations/animation_constants.dart';

/// 🎯 PremiumButton - Animated, interactive, production-ready button
/// 
/// Features:
/// - Smooth press animation (scale effect)
/// - Haptic feedback
/// - Loading state
/// - Multiple variants (primary, secondary, outlined, text)
/// - Gradient support
/// - Icon support
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final IconData? suffixIcon;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool enableHaptic;
  final EdgeInsets? padding;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.suffixIcon,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.radiusMd,
    this.enableHaptic = true,
    this.padding,
  });

  /// Primary button (filled with primary color)
  factory PremiumButton.primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? suffixIcon,
    double? width,
    double? height,
  }) {
    return PremiumButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ButtonVariant.primary,
      icon: icon,
      suffixIcon: suffixIcon,
      width: width,
      height: height,
    );
  }

  /// Secondary button (outlined)
  factory PremiumButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    IconData? suffixIcon,
    double? width,
    double? height,
  }) {
    return PremiumButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ButtonVariant.secondary,
      icon: icon,
      suffixIcon: suffixIcon,
      width: width,
      height: height,
    );
  }

  /// Gradient button
  factory PremiumButton.gradient({
    required String text,
    required VoidCallback? onPressed,
    required Gradient gradient,
    bool isLoading = false,
    IconData? icon,
    IconData? suffixIcon,
    double? width,
    double? height,
  }) {
    return PremiumButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ButtonVariant.gradient,
      gradient: gradient,
      icon: icon,
      suffixIcon: suffixIcon,
      width: width,
      height: height,
    );
  }

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.fast,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.5 : 1.0,
          duration: AnimationConstants.fast,
          child: Container(
            width: widget.width,
            height: widget.height ?? 56,
            padding: widget.padding ?? const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: _getDecoration(isDark, isDisabled),
            child: _buildContent(isDark),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isDark, bool isDisabled) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          color: isDisabled 
            ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
            : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled ? [] : [
            AppColors.primaryShadow(isDark),
          ],
        );
      
      case ButtonVariant.secondary:
        return BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      
      case ButtonVariant.gradient:
        return BoxDecoration(
          gradient: widget.gradient ?? (isDark 
            ? AppColors.darkPrimaryGradient 
            : AppColors.lightPrimaryGradient),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled ? [] : [
            AppColors.primaryShadow(isDark),
          ],
        );
      
      case ButtonVariant.text:
        return BoxDecoration(
          color: _isPressed 
            ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
    }
  }

  Widget _buildContent(bool isDark) {
    final textColor = _getTextColor(isDark);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.isLoading) ...[
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
        ],
        
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else
          Flexible(
            child: Text(
              widget.text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        
        if (widget.suffixIcon != null && !widget.isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(widget.suffixIcon, color: textColor, size: 20),
        ],
      ],
    );
  }

  Color _getTextColor(bool isDark) {
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.gradient:
        return Colors.white;
      
      case ButtonVariant.secondary:
      case ButtonVariant.text:
        return isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    }
  }
}

enum ButtonVariant {
  primary,
  secondary,
  gradient,
  text,
}
