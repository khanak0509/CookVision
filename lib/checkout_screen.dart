import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'razorpay_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _cartItems = [];
  double _totalAmount = 0.0;
  late RazorpayService _razorpayService;
  
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _loadCartItems();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCartItems() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart_items')
          .get();

      double total = 0;
      final items = cartSnapshot.docs.map((doc) {
        final data = doc.data();
        final quantity = data['quantity'] ?? 1;
        final price = (data['price'] ?? 0).toDouble();
        total += price * quantity;
        return {...data, 'doc_id': doc.id};
      }).toList();

      setState(() {
        _cartItems = items;
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading cart: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Create order in Firebase
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final orderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId);

      await orderRef.set({
        'order_id': orderId,
        'items': _cartItems.map((item) => {
          'name': item['name'],
          'quantity': item['quantity'],
          'price': item['price'],
          'image_url': item['image_url'] ?? '',
        }).toList(),
        'total_amount': _totalAmount,
        'delivery_address': _addressController.text.trim(),
        'payment_status': 'pending',
        'order_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });

      // Open Razorpay checkout
      await _razorpayService.openCheckout(
        context: context,
        amount: _totalAmount,
        orderId: orderId,
        orderDetails: {
          'items': _cartItems,
          'address': _addressController.text.trim(),
        },
        onSuccess: (paymentId) async {
          print('✅ Payment successful: $paymentId');
          
          // Update order with payment info
          await orderRef.update({
            'payment_status': 'paid',
            'payment_id': paymentId,
            'order_status': 'confirmed',
          });

          // Clear cart
          final batch = FirebaseFirestore.instance.batch();
          for (var item in _cartItems) {
            final docRef = FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('cart_items')
                .doc(item['doc_id']);
            batch.delete(docRef);
          }
          await batch.commit();

          // Navigate to success screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OrderSuccessScreen(
                  orderId: orderId,
                  paymentId: paymentId,
                ),
              ),
            );
          }
        },
        onFailure: (error) {
          print('❌ Payment failed: $error');
          setState(() => _isLoading = false);
          
          // Update order status
          orderRef.update({
            'payment_status': 'failed',
            'order_status': 'cancelled',
            'error': error,
          });
        },
      );

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error placing order: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Items
                    _buildSectionTitle('Order Items'),
                    const SizedBox(height: 12),
                    ..._cartItems.map((item) => _buildCartItem(item)),
                    
                    const SizedBox(height: 24),
                    
                    // Delivery Address
                    _buildSectionTitle('Delivery Address'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2d3a),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _addressController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your delivery address',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Price Summary
                    _buildSectionTitle('Price Summary'),
                    const SizedBox(height: 12),
                    _buildPriceSummary(),
                    
                    const SizedBox(height: 32),
                    
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Pay ₹${_totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Secure payment badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Secure payment powered by Razorpay',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2d3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                item['emoji'] ?? '🍽️',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Item',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item['quantity'] ?? 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF667eea),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final deliveryFee = 40.0;
    final tax = _totalAmount * 0.05; // 5% tax
    final finalTotal = _totalAmount + deliveryFee + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2d3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', _totalAmount),
          const SizedBox(height: 8),
          _buildPriceRow('Delivery Fee', deliveryFee),
          const SizedBox(height: 8),
          _buildPriceRow('Tax (5%)', tax),
          const Divider(color: Colors.white24, height: 24),
          _buildPriceRow('Total', finalTotal, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isBold ? const Color(0xFF667eea) : Colors.white,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// Order Success Screen
class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final String paymentId;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Order ID: $orderId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment ID: $paymentId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
