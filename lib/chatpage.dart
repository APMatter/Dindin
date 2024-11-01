import 'dart:ui'; // For BackdropFilter

import 'package:flutter/material.dart';

import 'chat_service.dart'; // Import the API file where `getChatbotResponse` is defined

class ChatPage extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = []; // List to hold messages
  bool isLoading = false; // State to track loading status

  void _sendMessage() async {
    final userMessage = _controller.text;
    if (userMessage.isEmpty) return; // Do nothing if message is empty

    setState(() {
      messages.add({"sender": "user", "message": userMessage});
      isLoading = true; // Set loading state to true
    });

    // Call API to get chatbot response
    final response = await getChatbotResponse(userMessage);

    setState(() {
      messages.add({"sender": "bot", "message": response});
      isLoading = false; // Reset loading state
    });

    _controller.clear(); // Clear the input field
  }

  void _reportProblem() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Problem Report"),
          content: Text("This feature will allow you to report a problem."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _problemStatus() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Problem Status"),
          content: Text(
              "This feature will show the status of your reported problems."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _viewHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("History"),
          content: Text("This feature will show your chat history."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DinDin"),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 100.0), // Apply blur
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1), // Transparent background
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _viewHistory,
          ),
        ],
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
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Arrange buttons evenly
              children: [
                ElevatedButton(
                  onPressed: _problemStatus,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // ให้ปุ่มมีขนาดตามเนื้อหา
                    children: [
                      Icon(Icons.warning, size: 16.0), // เพิ่มไอคอน Warning
                      SizedBox(width: 8.0), // ช่องว่างระหว่างไอคอนและข้อความ
                      Text('Problem Status'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _reportProblem,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // ให้ปุ่มมีขนาดตามเนื้อหา
                    children: [
                      Icon(Icons.report, size: 16.0), // เพิ่มไอคอน Report
                      SizedBox(width: 8.0), // ช่องว่างระหว่างไอคอนและข้อความ
                      Text('Problem Report'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0), // Button size
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                reverse: true, // Show the latest messages at the bottom
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - index - 1];
                  final isUserMessage = message['sender'] == 'user';

                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      padding: EdgeInsets.all(10.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *
                            0.7, // Limit width
                      ),
                      decoration: BoxDecoration(
                        color:
                            isUserMessage ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: isUserMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isUserMessage) // Only show the profile picture for the bot
                            CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 11, 72, 121),
                              radius: 20, // Set radius for circle
                              child: Image(image: AssetImage('pic/ai.png')),
                            ),
                          SizedBox(height: 5),
                          Text(
                            message['message'] ?? '',
                            style: TextStyle(fontSize: 16.0),
                            maxLines: 3, // Limit the number of lines
                            overflow: TextOverflow
                                .ellipsis, // Show ellipsis if overflow
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoading) CircularProgressIndicator(),
            SizedBox(height: 15), // Add spacing between the input field and the send button
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        Container(
                          width: 310, // กำหนดความกว้างเฉพาะสำหรับกล่องข้อความ
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.0), // ขอบมน
                          ),
                          child: TextField(
                            controller: _controller,
                            enabled: !isLoading, // Disable input when loading
                            decoration: InputDecoration(
                              hintText: 'Enter your message',
                              border: InputBorder.none, // ไม่มีขอบ
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0), // Padding ภายใน
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 3.0), // ช่องว่างระหว่างกล่องข้อความและปุ่ม
                        IconButton(
                          icon: Icon(Icons.send,
                              color: Colors.white), // เปลี่ยนสีของไอคอนที่นี่
                          onPressed: isLoading
                              ? null
                              : _sendMessage, // Disable send button when loading
                        ),
                      ],
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
