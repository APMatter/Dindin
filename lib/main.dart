import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_connection/chatpage.dart';
import 'package:test_connection/homepage.dart';
import 'package:test_connection/login_page.dart';
import 'package:test_connection/newspage.dart';
import 'package:test_connection/report.dart';
import 'package:test_connection/reportHistory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homepage',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      routes: {
  '/chat': (context) => ChatPage(),
  '/news' : (context) => NewsPage(),

  '/login': (context) => LoginScreen(),
  '/report': (context) => ProblemsReport(), // Ensure this line is correct
  '/history': (context) =>  HistoryReport (), // Ensure this line is correct
},
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          final username = user.displayName ?? 'User';
          final profileImagePath = 'pic/default_profile.png';
          return HomePage(username: username, profileImagePath: profileImagePath);
        } else {
          return LoginScreen();
        }
      },
    );
  }
}