import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../animations/animation_constants.dart';

/// 🌓 ThemeToggleButton - Animated theme switcher
/// 
/// Features:
/// - Smooth icon transition
/// - Color animation
/// - Shows current theme mode
/// - Cycles through: Light → Dark → System
class ThemeToggleButton extends StatefulWidget {
  final bool isCompact;

  const ThemeToggleButton({
    super.key,
    this.isCompact = false,
  });

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.normal,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
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

  void _toggleTheme() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    
    context.read<ThemeProvider>().toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isCompact) {
      return _buildCompactButton(themeProvider, isDark);
    } else {
      return _buildFullButton(themeProvider, isDark);
    }
  }

  Widget _buildCompactButton(ThemeProvider themeProvider, bool isDark) {
    return GestureDetector(
      onTap: _toggleTheme,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            themeProvider.getThemeIcon(),
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildFullButton(ThemeProvider themeProvider, bool isDark) {
    return GestureDetector(
      onTap: _toggleTheme,
      child: AnimatedContainer(
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                themeProvider.getThemeIcon(),
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              themeProvider.getThemeLabel(),
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
