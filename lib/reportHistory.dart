import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_connection/pendingStatus.dart';

import 'completeStatus.dart'; // Ensure this imports CompleteReportPage

class HistoryReport extends StatefulWidget {
  @override
  _HistoryReportState createState() => _HistoryReportState();
}

class _HistoryReportState extends State<HistoryReport> {
  List<Map<String, dynamic>> userReports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserReports();
  }

  Future<void> fetchUserReports() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final reportsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .get();

      setState(() {
        userReports = reportsSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user reports: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchReportDetails(String reportId) async {
    final reportDoc = await FirebaseFirestore.instance.collection('Reports').doc(reportId).get();
    return reportDoc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.grey[600], // Icon color
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "History",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color on white background
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Pure white background for AppBar
        elevation: 0, // Removes shadow for a clean look
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: userReports.length,
                itemBuilder: (context, index) {
                  final report = userReports[index];
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: report['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                report['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(width: 50, height: 50, color: Colors.grey),
                      title: Text(
                        report['request'] ?? 'Unknown Request',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Building: ${report['building']}, Room: ${report['room']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      onTap: () async {
                        final reportData = await fetchReportDetails(report['id']);
                        if (reportData != null) {
                          final status = reportData['status'] ?? 'Inprogress';
                          if (status == 'Complete') {
                            // Navigate to CompleteReportPage if status is Complete
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompleteReportPage(reportCode: report['id']),
                              ),
                            );
                          } else {
                            // Navigate to DependStatusPage if status is Inprogress
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DependStatusPage(
                                  reportCode: report['id'],
                                  status: status,
                                  request: reportData['request'] ?? 'No request provided',
                                  building: reportData['building'] ?? 'Unknown',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
