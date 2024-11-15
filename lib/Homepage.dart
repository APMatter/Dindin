import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final String username; 
  final String profileImagePath; 

  const HomePage({
    Key? key, 
    required this.username, 
    required this.profileImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              
              image: DecorationImage( 
                image: AssetImage('pic/background.png'),
                fit: BoxFit.cover,
              )
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
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'How can I assist you right now?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 54, 119, 240), 
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Text(
                              'Goto Chat',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Text('DinDin Chatbot'),
                          ],
                        ),
                        ),
                        
                        
                        Image.asset('pic/chat.png', width: 80, height: 80),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Other buttons
                Row(
                  
                  children: [
                    // Report Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/report');
                      },
                      child: Container(
                        height: 150,
                        width: 200,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 105, 173, 173),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [ 
                              Container( 
                                padding: EdgeInsets.only(top:60),
                                child: Text(
                              'Report',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                              ),
                              Text('Report a problem')
                              
                            ],),
                            
                            Container(padding: EdgeInsets.only(bottom: 70),
                              child: Image.asset('pic/status.png', width: 40, height: 40)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

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
                              color: const Color.fromARGB(255, 224, 88, 88),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'MFU NEWS',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                                const Icon(Icons.newspaper, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          child: Container(
                            height: 70,
                            width: 150,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 238, 161, 74),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'History',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,fontWeight: FontWeight.w600
                                  ),
                                ),
                                const Icon(Icons.history, color: Colors.white),
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
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}
