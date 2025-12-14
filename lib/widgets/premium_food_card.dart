import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../animations/animation_constants.dart';

/// 🍽️ PremiumFoodCard - Beautiful, interactive food card
/// 
/// Features:
/// - Image with gradient overlay
/// - Hero animation support
/// - Scale animation on press
/// - Price badge
/// - Rating display
/// - Add to cart button
/// - Shimmer loading state
class PremiumFoodCard extends StatefulWidget {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String? rating;
  final String? calories;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final bool isGridView;

  const PremiumFoodCard({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.rating,
    this.calories,
    required this.onTap,
    this.onAddToCart,
    this.isGridView = true,
  });

  @override
  State<PremiumFoodCard> createState() => _PremiumFoodCardState();
}

class _PremiumFoodCardState extends State<PremiumFoodCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.fast,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
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

  Future<void> _handleAddToCart() async {
    if (widget.onAddToCart == null || _isAddingToCart) return;
    
    setState(() => _isAddingToCart = true);
    
    // Show animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    widget.onAddToCart!();
    
    if (mounted) {
      setState(() => _isAddingToCart = false);
    }
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
        child: widget.isGridView ? _buildGridCard(isDark) : _buildListCard(isDark),
      ),
    );
  }

  Widget _buildGridCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradientBlue : null,
        color: isDark ? null : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: isDark ? AppColors.darkShadow : AppColors.lightShadowMd,
        border: isDark
          ? Border.all(
              color: AppColors.darkPrimary.withOpacity(0.3),
              width: 1,
            )
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: _buildImageSection(isDark),
          ),
          
          // Info Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name
                  Text(
                    widget.name,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Metadata
                  if (widget.calories != null)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.calories!,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  
                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${widget.price}',
                        style: TextStyle(
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      if (widget.onAddToCart != null)
                        _buildAddButton(isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(bool isDark) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradientPurple : null,
        color: isDark ? null : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: isDark ? AppColors.darkShadow : AppColors.lightShadow,
        border: isDark
          ? Border.all(
              color: AppColors.darkSecondary.withOpacity(0.3),
              width: 1,
            )
          : null,
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusMd),
                bottomLeft: Radius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: _buildImageSection(isDark, isCompact: true),
          ),
          
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (widget.calories != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.calories!,
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${widget.price}',
                        style: TextStyle(
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      if (widget.onAddToCart != null)
                        _buildAddButton(isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(bool isDark, {bool isCompact = false}) {
    return Hero(
      tag: 'food_${widget.id}',
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCompact ? AppSpacing.radiusMd : AppSpacing.radiusLg),
              topRight: Radius.circular(isCompact ? 0 : AppSpacing.radiusLg),
              bottomLeft: Radius.circular(isCompact ? AppSpacing.radiusMd : 0),
            ),
            child: widget.imageUrl.isNotEmpty
              ? Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    child: Icon(
                      Icons.restaurant,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      size: 32,
                    ),
                  ),
                )
              : Container(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  child: Icon(
                    Icons.restaurant,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    size: 32,
                  ),
                ),
          ),
          
          // Gradient Overlay (bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isCompact ? AppSpacing.radiusMd : 0),
                ),
              ),
            ),
          ),
          
          // Rating Badge
          if (widget.rating != null)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.warning,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: _handleAddToCart,
      child: AnimatedContainer(
        duration: AnimationConstants.fast,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: _isAddingToCart 
            ? AppColors.lightSecondaryGradient
            : (isDark ? AppColors.darkPrimaryGradientVibrant : AppColors.lightPrimaryGradient),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isAddingToCart
          ? const SizedBox(
              width: 16,
              height: 16,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
      ),
    );
  }
}
