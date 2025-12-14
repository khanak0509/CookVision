import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../animations/animation_constants.dart';

/// 🎯 AnimatedBottomNav - Modern, interactive bottom navigation
/// 
/// Features:
/// - Smooth indicator animation
/// - Scale animation on tap
/// - Floating active indicator
/// - Icon and label transitions
/// - Support for 3-5 items
class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : assert(items.length >= 3 && items.length <= 5,
            'Items must be between 3 and 5');

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.normal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavItem(
                widget.items[index],
                index,
                isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BottomNavItem item, int index, bool isDark) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated background
              AnimatedContainer(
                duration: AnimationConstants.normal,
                curve: AnimationConstants.easeOut,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? (isDark
                          ? AppColors.darkPrimaryGradient
                          : AppColors.lightPrimaryGradient)
                      : null,
                  color: !isSelected
                      ? (isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant).withOpacity(0.5)
                      : null,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  boxShadow: isSelected
                      ? [AppColors.primaryShadow(isDark)]
                      : [],
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                  size: 24,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Label with fade animation
              AnimatedDefaultTextStyle(
                duration: AnimationConstants.normal,
                curve: AnimationConstants.easeOut,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item model
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}

/// 🎨 Modern Bottom Navigation (Alternative - Floating Style)
/// 
/// Features:
/// - Floating bar with margin
/// - Pill-shaped active indicator
/// - More compact design
class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          items.length,
          (index) => _buildNavItem(items[index], index, isDark),
        ),
      ),
    );
  }

  Widget _buildNavItem(BottomNavItem item, int index, bool isDark) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? (isDark
                    ? AppColors.darkPrimaryGradient
                    : AppColors.lightPrimaryGradient)
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: isSelected
                ? [AppColors.primaryShadow(isDark)]
                : [],
          ),
          child: Center(
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
