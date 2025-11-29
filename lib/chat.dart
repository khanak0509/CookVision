import 'dart:convert';
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
  
  // Simple session ID without SharedPreferences
  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    _controller.clear();

    final response = await get(
      Uri.parse('http://localhost:8000/food_query/$text?session_id=$_sessionId'),
    );

    String bottxt = "Invalid response from server";
    List products = [];

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);

      if (data['response'] is String) {
        bottxt = data['response'];
      } else if (data['response']['llm_ans'] != null) {
        bottxt = data['response']['llm_ans'].toString();
          print(bottxt);
        products =
            List<Map<String, dynamic>>.from(data['response']['product'] ?? []);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 35, 42),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 87, 99),
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                if (isUser) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        msg['text'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  final products = msg['products'] ?? [];
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'],
                            style: const TextStyle(color: Colors.black),
                          ),
                          if (products.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 150,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final product = products[i];
                                  return _buildProductCard(context, product);
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
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map product) {
    return GestureDetector(
      onTap: () => _showProductDialog(context, product),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                'assets/image.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text("₹${product['price'] ?? ''}"),
            Text("⭐ ${product['rating'] ?? ''}"),
          ],
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, Map product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 16, 163, 126),
        title: Text(product['name'] ?? ''),
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
            const SizedBox(height: 10),
            Text("Price: ₹${product['price'] ?? ''}"),
            Text("Rating: ⭐ ${product['rating'] ?? ''}"),
            const SizedBox(height: 20),
            Text(product['description'] ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to cart'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: Chat(), debugShowCheckedModeBanner: false));
}