import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../animations/animation_constants.dart';

class FoodCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String rating;
  final String? calories;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  
  const FoodCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.rating,
    this.calories,
    required this.onTap,
    this.onAddToCart,
  });
  
  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isAddingToCart = false;
  
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
    _controller.forward();
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  Future<void> _handleAddToCart() async {
    if (widget.onAddToCart != null && !_isAddingToCart) {
      setState(() => _isAddingToCart = true);
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onAddToCart!();
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          splashColor: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.2),
          highlightColor: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.1),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              border: Border.all(
                color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.1),
                width: 1,
              ),
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusLg),
                      topRight: Radius.circular(AppSpacing.radiusLg),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: widget.imageUrl.startsWith('http')
                          ? Image.network(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.lightSurfaceVariant,
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 48,
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.lightSurfaceVariant,
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 48,
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.imageOverlayGradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSpacing.radiusLg),
                          topRight: Radius.circular(AppSpacing.radiusLg),
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.rating,
                            style: AppTextStyles.captionSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${widget.price.toStringAsFixed(0)}',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.calories != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.lightSurfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              '${widget.calories} cal',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (widget.onAddToCart != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAddingToCart ? null : _handleAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                          child: _isAddingToCart
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add_shopping_cart,
                                        size: 16),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Add',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
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
