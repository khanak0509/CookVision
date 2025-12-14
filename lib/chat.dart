import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';
import 'widgets/custom_button.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isLoadingHistory = true;
  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;
  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    if (userId == null) {
      setState(() => _isLoadingHistory = false);
      return;
    }

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
        loadedMessages.add({'role': 'user', 'text': data['user_message'] ?? ''});
        loadedMessages.add({
          'role': 'bot',
          'text': data['bot_response'] ?? '',
          'products': data['products'] ?? [],
        });
      }

      setState(() {
        _messages.addAll(loadedMessages);
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => _isLoadingHistory = false);
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
    _scrollToBottom();

    try {
      final response = await get(
        Uri.parse('http://localhost:8000/food_query/$text?session_id=$_sessionId'),
      );

      String bottxt = "Invalid response from server";
      List products = [];

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] is String) {
          bottxt = data['response'];
        } else if (data['response']['llm_ans'] != null) {
          bottxt = data['response']['llm_ans'].toString();
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

      _scrollToBottom();

      await _saveChatToFirestore(
        userMessage: text,
        botResponse: bottxt,
        products: products,
      );
    } catch (e) {
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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveChatToFirestore({
    required String userMessage,
    required String botResponse,
    required List products,
  }) async {
    if (userId == null) return;

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
    } catch (e) {
      // Silent fail
    }
  }

  void addtocart(String productId) async {
    if (userId == null) return;

    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('food_items')
          .doc(productId)
          .get();

      if (!productDoc.exists) return;

      final productData = productDoc.data()!;
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart_items');

      final existingItem = await cartRef.doc(productId).get();

      if (existingItem.exists) {
        await cartRef.doc(productId).update({'quantity': FieldValue.increment(1)});
      } else {
        await cartRef.doc(productId).set({
          'id': productData['id'] ?? productId,
          'name': productData['name'] ?? '',
          'price': productData['price'] ?? 0,
          'image_url': productData['image_url'] ?? '',
          'rating': productData['rating'] ?? 0.0,
          'calories': productData['calories'] ?? 0,
          'quantity': 1,
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${productData['name']} added to cart!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? AppColors.darkBackgroundGradient
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
              ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Clean Modern Header
              _buildCleanHeader(isDark),
              
              // Messages Area
              Expanded(
                child: _isLoadingHistory
                    ? _buildLoadingState(isDark)
                    : _messages.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              return _buildModernMessageBubble(msg, isDark);
                            },
                          ),
              ),
              
              // Typing Indicator
              if (_isLoading) _buildTypingIndicator(isDark),
              
              // Clean Input Bar
              _buildModernInputBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Clean, modern header
  Widget _buildCleanHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark 
              ? AppColors.darkBorder.withOpacity(0.5)
              : AppColors.lightBorder.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food AI Assistant',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading chat history...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Start a conversation!',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ask about recipes, ingredients, or recommendations',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Modern clean message bubbles
  Widget _buildModernMessageBubble(Map<String, dynamic> msg, bool isDark) {
    final isUser = msg['role'] == 'user';
    final text = msg['text'] ?? '';
    final products = msg['products'] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.lightPrimaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser 
                      ? (isDark ? AppColors.darkPrimaryGradientVibrant : AppColors.lightPrimaryGradient)
                      : null,
                    color: isUser 
                      ? null 
                      : (isDark ? AppColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? AppSpacing.radiusLg : AppSpacing.radiusSm),
                      topRight: Radius.circular(isUser ? AppSpacing.radiusSm : AppSpacing.radiusLg),
                      bottomLeft: const Radius.circular(AppSpacing.radiusLg),
                      bottomRight: const Radius.circular(AppSpacing.radiusLg),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUser 
                        ? Colors.white 
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.darkSecondaryGradient : AppColors.lightSecondaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ],
            ],
          ),
          // Product cards if any
          if (products.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 200,
              margin: EdgeInsets.only(left: isUser ? 0 : 40),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) => _buildProductCard(products[i], isDark),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    return GestureDetector(
      onTap: () => _showProductDetails(product, isDark),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2a2d3a) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.foodGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
              ),
              child: const Center(
                child: Icon(Icons.restaurant, size: 40, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product['price'] ?? '0'}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.add_shopping_cart,
                        size: 18,
                        color: AppColors.lightPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> product, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2a2d3a) : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Header
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppColors.foodGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.restaurant, size: 80, color: Colors.white),
                    ),
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown Dish',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product['price'] ?? '0'}',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.lightPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product['rating'] != null)
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                product['rating'].toString(),
                                style: AppTextStyles.titleMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomButton(
                      text: 'Add to Cart',
                      onPressed: () {
                        addtocart(product['id']);
                        Navigator.pop(context);
                      },
                      variant: ButtonVariant.gradient,
                      size: ButtonSize.large,
                      fullWidth: true,
                      icon: Icons.shopping_cart,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2a2d3a) : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern clean input bar
  Widget _buildModernInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark 
              ? AppColors.darkBorder.withOpacity(0.5)
              : AppColors.lightBorder.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about food...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkPrimaryGradientVibrant : AppColors.lightPrimaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _controller.text.trim().isEmpty ? null : sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: Icon(
                  _controller.text.trim().isEmpty ? Icons.mic : Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
