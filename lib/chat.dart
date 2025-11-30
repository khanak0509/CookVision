import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';



class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingHistory = true;
  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }


  Future<void> _loadChatHistory() async {
    if (userId == null) {
      print('⚠️ No user logged in');
      setState(() {
        _isLoadingHistory = false;
      });
      return;
    }

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chats')
          .orderBy('timestamp', descending: false)
          
          .get();

      final loadedMessages = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Add user message
        loadedMessages.add({
          'role': 'user',
          'text': data['user_message'] ?? '',
        });
        
        loadedMessages.add({
          'role': 'bot',
          'text': data['bot_response'] ?? '',
          'products': data['products'] ?? [],
        });
      }

      setState(() {
        _messages.clear();
        _messages.addAll(loadedMessages);
        _isLoadingHistory = false;
      });

      print('✅ Loaded ${snapshot.docs.length} previous chats');
    } catch (e) {
      print('❌ Error loading chat history: $e');
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await get(
        Uri.parse('http://localhost:8000/food_query/$text?session_id=$_sessionId'),
      );

      String bottxt = "Invalid response from server";
      List products = [];

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📡 API Response: $data');

        if (data['response'] is String) {
          bottxt = data['response'];
        } else if (data['response']['llm_ans'] != null) {
          bottxt = data['response']['llm_ans'].toString();
          print('🤖 Bot response: $bottxt');
          products = List<Map<String, dynamic>>.from(data['response']['product'] ?? []);
        }
      } else {
        bottxt = 'Error: Could not fetch response';
      }

      setState(() {
        _messages.add({
          'role': 'bot',
          'text': bottxt,
          'products': products,
        });
        _isLoading = false;
      });

      await _saveChatToFirestore(
        userMessage: text,
        botResponse: bottxt,
        products: products,
      );

    } catch (e) {
      print('❌ Error sending message: $e');
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': 'Error: Could not get response',
          'products': [],
        });
        _isLoading = false;
      });
    }
  }


  Future<void> _saveChatToFirestore({
    required String userMessage,
    required String botResponse,
    required List products,
  }) async {
    if (userId == null) {
      print('⚠️ Cannot save: User not logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chats')
          .add({
        'user_message': userMessage,
        'bot_response': botResponse,
        'products': products,
        'type': 'text',
        'timestamp': FieldValue.serverTimestamp(),
        'session_id': _sessionId,
      });

      print('✅ Chat saved to Firestore');
    } catch (e) {
      print('❌ Error saving chat: $e');
    }
  }
 void addtocart(String productId) async {
    if (userId == null) {
      print('⚠️ Cannot add to cart: User not logged in');
      return;
    }

    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('food_items')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        print('⚠️ Product not found in food_items collection');
        return;
      }

      final productData = productDoc.data()!;

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart_items');

      final existingItem = await cartRef.doc(productId).get();

      if (existingItem.exists) {
        await cartRef.doc(productId).update({
          'quantity': FieldValue.increment(1),
        });
        print('✅ Increased quantity of ${productData['name']} in cart');
      } 
      else {
        await cartRef.doc(productId).set({
          'id': productData['id'] ?? productId,
          'name': productData['name'] ?? '',
          'price': productData['price'] ?? 0,
          'image_url': productData['image_url'] ?? '',
          'description': productData['description'] ?? '',
          'category': productData['category'] ?? '',
          'cuisine': productData['cuisine'] ?? '',
          'dietary': productData['dietary'] ?? '',
          'spice_level': productData['spice_level'] ?? '',
          'rating': productData['rating'] ?? 0.0,
          'preparation_time': productData['preparation_time'] ?? 0,
          'available': productData['available'] ?? true,
          'tags': productData['tags'] ?? [],
          'quantity': 1, // Cart quantity starts at 1
        });
        print('✅ Added ${productData['name']} to cart');
      }

      // Show success message to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${productData['name']} added to cart!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF667eea),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to add to cart'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }


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
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Column(
                children: [
                  const Text(
                    'Food Chat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Show chat count
                  if (_messages.isNotEmpty)
                    Text(
                     '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                ],
              ),
              centerTitle: true,
              actions: [
                // History indicator icon
                IconButton(
                  icon: const Icon(Icons.history, color: Color(0xFF667eea)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          userId != null 
                            ? 'All chats are automatically saved!'
                            : 'Login to save chat history',
                        ),
                        backgroundColor: const Color(0xFF667eea),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: _isLoadingHistory
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF667eea),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading your chat history...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : _messages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 80,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Start a conversation!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ask me anything about food',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';

                  if (isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          msg['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  } else {
                    final products = msg['products'] ?? [];
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2d3a),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            if (products.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 180,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: products.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, i) {
                                    final product = products[i];
                                    return GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: const Color(0xFF2a2d3a),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            title: Text(
                                              product['name'] ?? '',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: Image.asset(
                                                    'assets/image.png',
                                                    height: 150,
                                                    width: 150,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  "Price: ₹${product['price'] ?? ''}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "Rating: ⭐ ${product['rating'] ?? ''}",
                                                  style: const TextStyle(color: Colors.white70),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  product['description'] ?? '',
                                                  style: const TextStyle(color: Colors.white70),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 20),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                                    ),
                                                    borderRadius: BorderRadius.circular(25),
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      addtocart(product['id']);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.transparent,
                                                      shadowColor: Colors.transparent,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Add to Cart',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text(
                                                  'Close',
                                                  style: TextStyle(color: Color(0xFF667eea)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 140,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF3a3d4a),
                                              Color(0xFF2a2d3a),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(15),
                                                ),
                                                child: Image.asset(
                                                  'assets/image.png',
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product['name'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "₹${product['price'] ?? ''}",
                                                    style: const TextStyle(
                                                      color: Color(0xFF667eea),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "⭐ ${product['rating'] ?? ''}",
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2d3a),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Message…",
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


