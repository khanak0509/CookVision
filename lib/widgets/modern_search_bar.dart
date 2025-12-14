import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../animations/animation_constants.dart';

/// 🔍 ModernSearchBar - Interactive search with smooth animations
/// 
/// Features:
/// - Focus animation
/// - Clear button with fade animation
/// - Voice search button (optional)
/// - Custom search icon
/// - Animated border
class ModernSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onVoiceSearch;
  final bool autofocus;
  final bool showVoiceButton;
  final EdgeInsets? padding;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search for food...',
    this.onChanged,
    this.onSearch,
    this.onVoiceSearch,
    this.autofocus = false,
    this.showVoiceButton = false,
    this.padding,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.normal,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.easeOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    });

    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasText = widget.controller.text.isNotEmpty;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: _isFocused
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        .withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: (_) => widget.onSearch?.call(),
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: _isFocused
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clear button
                AnimatedOpacity(
                  opacity: hasText ? 1.0 : 0.0,
                  duration: AnimationConstants.fast,
                  child: AnimatedScale(
                    scale: hasText ? 1.0 : 0.0,
                    duration: AnimationConstants.fast,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged?.call('');
                      },
                    ),
                  ),
                ),
                
                // Voice search button
                if (widget.showVoiceButton)
                  IconButton(
                    icon: Icon(
                      Icons.mic,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                    onPressed: widget.onVoiceSearch,
                  ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.padding?.horizontal ?? AppSpacing.lg,
              vertical: widget.padding?.vertical ?? AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🏷️ CategoryChip - Animated filter/category chip
/// 
/// Features:
/// - Selected/unselected states
/// - Scale animation on press
/// - Gradient for selected state
class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    _controller.forward();
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? (isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient)
                : null,
            color: !widget.isSelected
                ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: !widget.isSelected
                ? Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.5,
                  )
                : null,
            boxShadow: widget.isSelected
                ? [
                    AppColors.primaryShadow(isDark),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
