import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CustomCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool showShadow;
  final bool glassmorphism;
  final double? borderRadius;
  
  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.showShadow = true,
    this.glassmorphism = false,
    this.borderRadius,
  });
  
  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
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
    
    Color cardColor = widget.backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    
    Widget cardContent = Container(
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: widget.glassmorphism
            ? (isDark
                ? AppColors.darkSurface.withOpacity(0.7)
                : AppColors.lightSurface.withOpacity(0.7))
            : (widget.gradient == null ? cardColor : null),
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppSpacing.radiusLg),
        border: widget.glassmorphism
            ? Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              )
            : null,
        boxShadow: widget.showShadow && !widget.glassmorphism
            ? (isDark ? AppColors.darkShadow : AppColors.lightShadow)
            : null,
      ),
      child: widget.child,
    );
    
    if (widget.glassmorphism) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppSpacing.radiusLg),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.transparent,
            BlendMode.src,
          ),
          child: cardContent,
        ),
      );
    }
    
    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: cardContent,
        ),
      );
    }
    
    return cardContent;
  }
}
