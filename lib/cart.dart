import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app/upi.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2d3a),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'My Cart',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (userId != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('cart_items')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          final cartItems = snapshot.data!.docs;
                          
                          return GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF2a2d3a),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    'Clear Cart?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Remove all items from your cart?',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Clear',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                for (var doc in cartItems) {
                                  await doc.reference.delete();
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cart cleared'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a2d3a),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              if (userId == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Please log in to view cart',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('cart_items')
                        .snapshots(),
                    builder: (context, snapshot) {
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF667eea),
                            strokeWidth: 3,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final cartItems = snapshot.data!.docs;
                      
                      print(cartItems);

                      if (cartItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2a2d3a),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Add some delicious items!',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
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
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final cartitem = cartItems[index];
                                final item = cartitem.data() as Map<String, dynamic>;

                                return _buildCartItem(
                                  documentId: cartitem.id,
                                  name: item['name'] ?? 'Unknown',
                                  price: (item['price'] ?? 0).toDouble(),
                                  imageUrl: item['image_url'] ?? '',
                                  quantity: item['quantity'] ?? 1,
                                  rating: item['rating']?.toString() ?? '0',
                                  calories: item['calories']?.toString() ?? '0',
                                );
                              },
                            ),
                          ),

                          // Checkout section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a2d3a),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Items and Price summary
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Total Items',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '$totalQuantity items',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Total Amount',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '₹${total.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Including taxes and charges',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Checkout button
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Checkout feature coming soon!'),
                                        backgroundColor: Color(0xFF667eea),
                                      ),
                                    );
                                  },
                                  child: GestureDetector(
                                    
                                    onTap: () => {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => UpiPaymentIntent()))
                                    },
                                    child: Container(
                                      
                                      width: double.infinity,
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 18),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF667eea),
                                            Color(0xFF764ba2)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667eea)
                                                .withOpacity(0.5),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.shopping_bag,
                                              color: Colors.white, size: 22),
                                          SizedBox(width: 10),
                                          Text(
                                            'Proceed to Checkout',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String documentId,
    required String name,
    required double price,
    required String imageUrl,
    required int quantity,
    required String rating,
    required String calories,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2d3a),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: imageUrl.isNotEmpty
                ? Image.asset(
                    "assets/image.png",
                    width: 110,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 110,
                        height: 130,
                        color: const Color(0xFF1a1a2e),
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.white54,
                          size: 40,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 110,
                    height: 130,
                    color: const Color(0xFF1a1a2e),
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
          ),

          // Item details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Info badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                color: Color(0xFF667eea), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$calories Cal',
                              style: const TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA500).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Color(0xFFFFA500), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: const TextStyle(
                                color: Color(0xFFFFA500),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price and quantity controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹$price',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total: ₹${(price * quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF667eea),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF667eea).withOpacity(0.2),
                              const Color(0xFF764ba2).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (quantity > 1) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('cart_items')
                                      .doc(documentId)
                                      .update({'quantity': quantity - 1});
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('cart_items')
                                      .doc(documentId)
                                      .delete();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  quantity > 1 ? Icons.remove : Icons.delete,
                                  color:
                                      quantity > 1 ? Colors.white : Colors.red,
                                  size: 18,
                                ),
                              ),
                            ),

                            // Quantity display
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('cart_items')
                                    .doc(documentId)
                                    .update({'quantity': quantity + 1});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
