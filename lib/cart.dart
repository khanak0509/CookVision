import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';
import 'widgets/custom_button.dart';
import 'checkout_screen.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _updateQuantity(String docId, int newQuantity) async {
    if (newQuantity < 1) {
      // Delete item if quantity is 0
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart_items')
          .doc(docId)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart_items')
          .doc(docId)
          .update({'quantity': newQuantity});
    }
  }

  Future<void> _proceedToCheckout() async {
    if (userId == null) return;

    try {
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart_items')
          .get();

      if (cartSnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cart is empty!'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          );
        }
        return;
      }

      // Navigate to checkout screen with Razorpay payment
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckoutScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Text(
                    'My Cart',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child: userId == null
                  ? _buildEmptyState('Please log in to view cart', isDark)
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('cart_items')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            ),
                          );
                        }

                        final cartItems = snapshot.data?.docs ?? [];
                        
                        if (cartItems.isEmpty) {
                          return _buildEmptyState('Your cart is empty', isDark);
                        }

                        double total = 0;
                        int totalQuantity = 0;
                        for (var doc in cartItems) {
                          final data = doc.data() as Map<String, dynamic>;
                          final price = (data['price'] ?? 0).toDouble();
                          final quantity = data['quantity'] ?? 1;
                          total += price * quantity;
                          totalQuantity += quantity as int;
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final doc = cartItems[index];
                                  final item = doc.data() as Map<String, dynamic>;
                                  return _buildCartItem(
                                    doc.id,
                                    item['name'] ?? 'Unknown',
                                    (item['price'] ?? 0).toDouble(),
                                    item['quantity'] ?? 1,
                                    isDark,
                                  );
                                },
                              ),
                            ),
                            _buildCheckoutSection(total, totalQuantity, isDark),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            message,
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(String docId, String name, double price, int quantity, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.foodGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.restaurant, size: 32, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                // Minus Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _updateQuantity(docId, quantity - 1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: quantity > 1
                            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                            : AppColors.error,
                      ),
                    ),
                  ),
                ),
                
                // Quantity Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    quantity.toString(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Plus Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _updateQuantity(docId, quantity + 1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(double total, int totalQuantity, bool isDark) {
    final deliveryCharge = 40.0;
    final tax = total * 0.05;
    final grandTotal = total + deliveryCharge + tax;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXxl),
          topRight: Radius.circular(AppSpacing.radiusXxl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriceRow('Subtotal', '₹${total.toStringAsFixed(2)}', isDark, false),
          const SizedBox(height: AppSpacing.sm),
          _buildPriceRow('Delivery', '₹${deliveryCharge.toStringAsFixed(2)}', isDark, false),
          const SizedBox(height: AppSpacing.sm),
          _buildPriceRow('Tax (5%)', '₹${tax.toStringAsFixed(2)}', isDark, false),
          
          Divider(
            height: AppSpacing.xxl,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          
          _buildPriceRow('Total', '₹${grandTotal.toStringAsFixed(2)}', isDark, true),
          
          const SizedBox(height: AppSpacing.lg),
          
          CustomButton(
            text: 'Checkout ($totalQuantity items)',
            onPressed: _proceedToCheckout,
            variant: ButtonVariant.gradient,
            size: ButtonSize.large,
            fullWidth: true,
            icon: Icons.shopping_bag,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal ? AppTextStyles.headlineSmall : AppTextStyles.bodyMedium).copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        Text(
          value,
          style: (isTotal ? AppTextStyles.headlineMedium : AppTextStyles.titleMedium).copyWith(
            color: isTotal
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
