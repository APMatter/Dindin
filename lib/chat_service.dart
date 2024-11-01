import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> getChatbotResponse(String userMessage) async {
  final uri = Uri.parse('http://10.0.2.2:5000/chat'); // ใช้ 10.0.2.2 สำหรับ Android Emulator
  // หากใช้ iOS Simulator สามารถใช้ 'http://127.0.0.1:5000/chat' ได้
  // ถ้าใช้จริงต้องเปลี่ยนเป็น IP address ของเครื่องที่รัน Flask

  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": userMessage}),
    );

    // ตรวจสอบสถานะการตอบกลับ
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['response'] ?? 'No response from chatbot'; // แก้ไขคีย์จาก 'outputs' เป็น 'response'
    } else {
      return 'Error: ${response.statusCode} - ${response.reasonPhrase}'; // แสดงรหัสสถานะและเหตุผล
    }
  } catch (e) {
    return 'Failed to connect to the chatbot: $e'; // จัดการข้อผิดพลาดเมื่อไม่สามารถเชื่อมต่อได้
  }
}