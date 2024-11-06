import 'dart:convert';

import 'package:http/http.dart' as http;

// Function to get chatbot response
// Function to get chatbot response
Future<Map<String, dynamic>> getChatbotResponse(String userMessage) async {
  final uri = Uri.parse('http://10.0.2.2:5000/chat'); // Use 10.0.2.2 for Android Emulator

  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": userMessage}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return the decoded JSON response
    } else {
      return {
        'response': 'Error: ${response.statusCode} - ${response.reasonPhrase}'
      };
    }
  } catch (e) {
    return {'response': 'Failed to connect to the chatbot: $e'};
  }
}