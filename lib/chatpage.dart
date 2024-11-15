import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_connection/report.dart'; // Ensure this is the correct import for your ProblemsReport page

import 'chat_service.dart'; // Import the API file where `getChatbotResponse` is defined

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

    final response = await getChatbotResponse(userMessage);

    if (response['action'] == 'navigate' && response['target'] == 'ProblemsPage') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProblemsReport()),
      );
    } else {
      setState(() {
        messages.add({"sender": "bot", "message": response['response'] ?? 'No response from chatbot'});
        isLoading = false;
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, // ลูกศรสามเหลี่ยมทันสมัย
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "DinDin",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
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
                      padding: EdgeInsets.all(12.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blue[400] : Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(isUserMessage ? 12 : 0),
                          bottomRight: Radius.circular(isUserMessage ? 0 : 12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message['message'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          color: isUserMessage ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoading) CircularProgressIndicator(),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left :15.0,bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Ask DinDin',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal:20.0),
                          hintStyle: GoogleFonts.poppins(fontSize: 14),
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.grey[600], size: 25,),
                      onPressed: isLoading ? null : _sendMessage,
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
