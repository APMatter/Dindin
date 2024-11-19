import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:flutter/material.dart';
import 'package:test_connection/chatpage.dart';
import 'package:test_connection/homepage.dart';
import 'package:test_connection/login_page.dart';
import 'package:test_connection/newspage.dart';
import 'package:test_connection/report.dart';
import 'package:test_connection/reportHistory.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
        '/news': (context) => NewsPage(),
        '/login': (context) => LoginScreen(),
        '/report': (context) => ProblemsReport(),
        '/history': (context) => HistoryReport(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();


    // Get the FCM Token
    messaging.getToken().then((token) {
      print('FCM Token: $token');
      // คุณสามารถส่ง token นี้ไปยัง backend ของคุณ เพื่อใช้ในการส่ง notification
    });

    // ฟังก์ชันในการรับข้อความ Push Notification ขณะแอปทำงานอยู่
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Message Title: ${message.notification?.title}");
        print("Message Body: ${message.notification?.body}");
        // คุณสามารถแสดง UI หรือใช้วิธีอื่นๆ ในการจัดการข้อความที่รับมา
      }
    });

    // ฟังก์ชันในการรับข้อความ Push Notification ขณะแอปใน background หรือ terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

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
