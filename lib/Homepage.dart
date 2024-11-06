import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final String username; // Pass the username dynamically
  final String profileImagePath; // Path to the profile image (this will not be used now)


  const HomePage({Key? key, required this.username, required this.profileImagePath, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage("pic/bg.png"), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Greeting and Robot Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'pic/ai.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello $username',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'How can I assist you right now?',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // CHAT with DINN Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  child: Container(
                    height: 150,
                    width: 500,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E4EA5), // Purple color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CHAT with DINN',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        Image.asset('pic/chat.png', width: 80, height: 80)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Other buttons
                Row(
                  children: [
                    // Problem Status Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/report');
                      },
                      child: Container(
                        height: 150,
                        width: 200,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Report',
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Image.asset('pic/status.png', width: 50, height: 50)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // MFU News and History buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/news');
                          },
                          child: Container(
                            width: 150,
                            height: 70,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 134, 15, 15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'MFU NEWS',
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                ),
                                Icon(Icons.newspaper, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          child: Container(
                            height: 70,
                            width: 150,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFD17D1B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'History',
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                Icon(Icons.history, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logout button in the top-right corner
          Positioned(
            top: 30,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                // Navigate to the login page
                Navigator.pushReplacementNamed(context, '/login'); // Change to your login route
              },
            ),
          ),
        ],
      ),
    );
  }
}





