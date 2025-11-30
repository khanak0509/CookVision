import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
              // Header
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
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Updated: November 30, 2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildSection(
                        '1. Information We Collect',
                        'We collect information you provide directly to us, including:\n\n'
                        '• Personal information (name, email, phone number)\n'
                        '• Account credentials\n'
                        '• Delivery addresses\n'
                        '• Payment information\n'
                        '• Order history and preferences\n'
                        '• Device information and usage data',
                      ),

                      _buildSection(
                        '2. How We Use Your Information',
                        'We use the information we collect to:\n\n'
                        '• Process and deliver your orders\n'
                        '• Provide customer support\n'
                        '• Send you updates about your orders\n'
                        '• Improve our services and user experience\n'
                        '• Personalize your recommendations\n'
                        '• Prevent fraud and ensure security',
                      ),

                      _buildSection(
                        '3. Information Sharing',
                        'We do not sell your personal information. We may share your information with:\n\n'
                        '• Restaurant partners for order fulfillment\n'
                        '• Delivery partners for order delivery\n'
                        '• Payment processors for transactions\n'
                        '• Service providers who assist our operations\n'
                        '• Law enforcement when required by law',
                      ),

                      _buildSection(
                        '4. Data Security',
                        'We implement appropriate security measures to protect your information, including:\n\n'
                        '• Encryption of sensitive data\n'
                        '• Secure server infrastructure\n'
                        '• Regular security audits\n'
                        '• Access controls and authentication\n'
                        '• Secure payment processing',
                      ),

                      _buildSection(
                        '5. Your Rights',
                        'You have the right to:\n\n'
                        '• Access your personal information\n'
                        '• Correct inaccurate data\n'
                        '• Request deletion of your data\n'
                        '• Opt-out of marketing communications\n'
                        '• Export your data\n'
                        '• Close your account',
                      ),

                      _buildSection(
                        '6. Cookies and Tracking',
                        'We use cookies and similar technologies to:\n\n'
                        '• Remember your preferences\n'
                        '• Analyze app usage patterns\n'
                        '• Improve functionality\n'
                        '• Provide personalized content\n\n'
                        'You can manage cookie preferences in your device settings.',
                      ),

                      _buildSection(
                        '7. Children\'s Privacy',
                        'Our service is not intended for children under 13 years of age. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
                      ),

                      _buildSection(
                        '8. Changes to This Policy',
                        'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date.',
                      ),

                      _buildSection(
                        '9. Contact Us',
                        'If you have questions about this privacy policy, please contact us at:\n\n'
                        'Email: privacy@cookvision.com\n'
                        'Phone: +1 (555) 123-4567\n'
                        'Address: 123 Food Street, San Francisco, CA 94102',
                      ),

                      const SizedBox(height: 30),

                      // Consent Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Text(
                          'I Understand',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.privacy_tip,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
