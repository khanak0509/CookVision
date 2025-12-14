import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class FoodRecognitionService {
  // CHANGE THIS TO YOUR BACKEND URL
  static const String baseUrl = 'http://localhost:8000';
  
  /// Recognize food from image file
  /// Returns food name, confidence, and top predictions
  static Future<Map<String, dynamic>> recognizeFood(File imageFile) async {
    try {
      print('📸 Recognizing food from image: ${imageFile.path}');
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/recognize-food'),
      );
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );
      
      print('🚀 Sending image to backend...');
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Recognition successful: ${data['food_name']} (${data['confidence']}%)');
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Recognition failed');
      }
    } catch (e) {
      print('❌ Error recognizing food: $e');
      rethrow;
    }
  }
  
  /// Show recognition result in a dialog
  static void showRecognitionResult(
    BuildContext context,
    Map<String, dynamic> result,
  ) {
    final foodName = result['food_name'] ?? 'Unknown';
    final confidence = result['confidence'] ?? 0.0;
    final topPredictions = result['top_predictions'] as List<dynamic>? ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍽️ Food Recognized!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main prediction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      foodName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${confidence.toStringAsFixed(1)}% confident',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Top predictions
              if (topPredictions.length > 1) ...[
                const Text(
                  'Other Possibilities:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...topPredictions.skip(1).map((pred) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pred['food_name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '${pred['confidence'].toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to food details or add to cart
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}
