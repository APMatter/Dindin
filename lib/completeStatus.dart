import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompleteReportPage extends StatelessWidget {
  final String reportCode;

  CompleteReportPage({required this.reportCode});

  Future<Map<String, dynamic>?> fetchReportData() async {
    try {
      DocumentSnapshot reportSnapshot = await FirebaseFirestore.instance
          .collection('Reports')
          .doc(reportCode)
          .get();

      if (reportSnapshot.exists) {
        return reportSnapshot.data() as Map<String, dynamic>?;
      } else {
        print("No report found with this reportCode");
      }
    } catch (e) {
      print('Error fetching report data: $e');
    }
    return null;
  }

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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No data found"));
          }

          final data = snapshot.data!;
          final imageUrl = data['imageUrl'] ?? '';
          final status = data['status'] ?? 'Unknown';
          final request = data['request'] ?? 'No request provided';
          final building = data['building'] ?? 'Unknown';
          final room = data['room'] ?? 'Unknown';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status Section (Report, Inprogress, Complete)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
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
                            Image.asset('pic/complete.png', width: 30, height: 30),
                            SizedBox(height: 5),
                            Text(status, style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('pic/complete.png', width: 40, height: 40),
                            SizedBox(height: 5),
                            Text('Complete', style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Report Info Card
                Card(
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
                        _buildInfo('Building', building),
                        _buildInfo('Room', room),
                      ],
                    ),
                  ),
                ),
             
               
              ],
            ),
          );
        },
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
