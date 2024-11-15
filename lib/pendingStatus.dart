import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DependStatusPage extends StatelessWidget {
  final String reportCode;
  final String status;
  final String request;
  final String building;

  DependStatusPage({
    required this.reportCode,
    required this.status,
    required this.request,
    required this.building,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ตั้งค่าพื้นหลังของ Scaffold เป็นสีขาว
      appBar: AppBar(
        title: Text('Report Status', style: GoogleFonts.poppins(fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Section (Report, Inprogress, Complete)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Image.asset('pic/complete.png', width: 30, height: 30),
                            SizedBox(height: 5),
                            Text('Report', style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('pic/complete.png', width: 40, height: 40),
                            SizedBox(height: 5),
                            Text('Inprogress', style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('pic/inprogress.png', width: 30, height: 30),
                            SizedBox(height: 5),
                            Text('Complete', style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Report Info Card
            Container(
              width: 250,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfo('Report Code', reportCode),
                      _buildInfo('Status', status),
                      _buildInfo('Request', request),
                      _buildInfo('Place', building),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build info rows inside the card
  Widget _buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
