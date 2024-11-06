import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_connection/report.dart';  // Ensure this is the correct import for your ProblemsReport page

import 'chat_service.dart'; // Import the API file where `getChatbotResponse` is defined

// Chat page
class ChatPage extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  void _sendMessage() async {
    final userMessage = _controller.text;
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "message": userMessage});
      isLoading = true;
    });

    // Call API to get chatbot response
    final response = await getChatbotResponse(userMessage);

    // Check for navigation action
    if (response['action'] == 'navigate' && response['target'] == 'ProblemsPage') {
      // Navigate to ProblemsPage if the response action is "navigate"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProblemsReport()),
      );
    } else {
      // Show the chatbot response in the chat interface
      setState(() {
        messages.add({"sender": "bot", "message": response['response'] ?? 'No response from chatbot'});
        isLoading = false;
      });
    }

    _controller.clear(); // Clear the input field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DinDin"),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 100.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('pic/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - index - 1];
                  final isUserMessage = message['sender'] == 'user';

                  return Align(
                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      padding: EdgeInsets.all(10.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        message['message'] ?? '',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoading) CircularProgressIndicator(),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextField(
                        controller: _controller,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Enter your message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: isLoading ? null : _sendMessage,
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