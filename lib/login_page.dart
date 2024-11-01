import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'HomePage.dart'; // Import the HomePage

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // User cancelled the sign-in
      }

      if (!googleUser.email.endsWith('@lamduan.mfu.ac.th')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลงชื่อเข้าใช้ได้เฉพาะบัญชี @lamduan.mfu.ac.th เท่านั้น')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save user data in Firestore
      await _saveUserData(userCredential.user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลงชื่อเข้าใช้สำเร็จ')),
      );

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: userCredential.user!.displayName ?? '', profileImagePath: userCredential.user!.photoURL ?? '')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _saveUserData(User? user) async {
    if (user == null) return;

    // Prepare user data to save
    final userData = {
      'uid': user.uid,
      'name': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    };

    // Save data into "users" collection using uid as key
    await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'pic/bg.png', // Ensure bg.png is in the assets folder
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image above the login button
                  Image.asset(
                    'pic/ai.png', // Ensure ai.png is in the assets folder
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text('Sign in with @lamduan.mfu.ac.th', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 20),
                  // Login button
                  Container(
                    width: 150,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => _signInWithGoogle(context),
                      child: Text('Sign in', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}