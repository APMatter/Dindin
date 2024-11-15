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
              'pic/bg2.png', // Ensure bg.png is in the assets folder
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  SizedBox(height: 20),
                  Text('Sign in with @lamduan.mfu.ac.th', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 20),
                  // Login button

                  Container(
  width: 150,
  height: 45,
  child: ElevatedButton(
    
    onPressed: () => _signInWithGoogle(context),
    child: Text(
      'Sign in',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white, // ตัวอักษรสีขาว
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[900],  // สีพื้นหลังของปุ่มเป็นสีน้ำเงิน
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // ปรับขอบโค้งของปุ่ม (ถ้าต้องการ)
      ),
    ),
  ),
),
                  SizedBox(height: 180),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}