import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RazorpayService {
  late Razorpay _razorpay;
  BuildContext? _context;
  Function(String)? _onSuccess;
  Function(String)? _onFailure;

  // Backend URL - update as needed
  static const String baseUrl = 'http://localhost:8000';

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// Initialize payment and open Razorpay checkout
  Future<void> openCheckout({
    required BuildContext context,
    required double amount,
    required String orderId,
    required Map<String, dynamic> orderDetails,
    Function(String paymentId)? onSuccess,
    Function(String error)? onFailure,
  }) async {
    _context = context;
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    try {
      // Get user details
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError(context, 'Please login to continue payment');
        return;
      }

      // Fetch user data from Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String name = userData.data()?['name'] ?? 'User';
      final String email = user.email ?? 'user@example.com';
      final String phone = userData.data()?['phone'] ?? '';

      // Create Razorpay order
      final razorpayOrderId = await _createRazorpayOrder(
        amount: amount,
        orderId: orderId,
      );

      if (razorpayOrderId == null) {
        _showError(context, 'Failed to create payment order');
        return;
      }

      // Razorpay checkout options
      var options = {
        'key': await _getRazorpayKey(), // Your Razorpay key from backend
        'amount': (amount * 100).toInt(), // Amount in paise
        'name': 'CookVision Food App',
        'order_id': razorpayOrderId,
        'description': 'Order #$orderId',
        'prefill': {
          'contact': phone,
          'email': email,
          'name': name,
        },
        'theme': {
          'color': '#667eea',
        },
        'modal': {
          'ondismiss': () {
            print('Payment cancelled by user');
          }
        }
      };

      _razorpay.open(options);
    } catch (e) {
      print('❌ Error opening Razorpay: $e');
      _showError(context, 'Payment initialization failed: $e');
      if (_onFailure != null) _onFailure!('Payment initialization failed');
    }
  }

  /// Get Razorpay Key from backend
  Future<String> _getRazorpayKey() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/razorpay/key'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['key_id'];
      }
    } catch (e) {
      print('❌ Error fetching Razorpay key: $e');
    }
    // Fallback - replace with your actual key in production
    return 'rzp_test_xxxxxxxxxxx';
  }

  /// Create Razorpay order via backend
  Future<String?> _createRazorpayOrder({
    required double amount,
    required String orderId,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final response = await http.post(
        Uri.parse('$baseUrl/api/razorpay/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'order_id': orderId,
          'user_id': userId,
        }),
      );

      print('📥 Create order response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['razorpay_order_id'];
      } else {
        print('❌ Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating Razorpay order: $e');
    }
    return null;
  }

  /// Verify payment on backend
  Future<bool> _verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/razorpay/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
        }),
      );

      print('📥 Verify payment response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['verified'] == true;
      }
    } catch (e) {
      print('❌ Error verifying payment: $e');
    }
    return false;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('✅ Payment Success: ${response.paymentId}');

    if (_context != null) {
      // Verify payment with backend
      final verified = await _verifyPayment(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );

      if (verified) {
        _showSuccess(_context!, 'Payment successful!');
        if (_onSuccess != null) {
          _onSuccess!(response.paymentId ?? '');
        }
      } else {
        _showError(_context!, 'Payment verification failed');
        if (_onFailure != null) {
          _onFailure!('Payment verification failed');
        }
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ Payment Error: ${response.code} - ${response.message}');

    if (_context != null) {
      _showError(
        _context!,
        'Payment failed: ${response.message ?? "Unknown error"}',
      );
    }

    if (_onFailure != null) {
      _onFailure!(response.message ?? 'Payment failed');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('💼 External Wallet: ${response.walletName}');

    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('External wallet: ${response.walletName ?? "Selected"}'),
        ),
      );
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
