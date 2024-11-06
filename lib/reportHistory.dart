import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryReport extends StatefulWidget {
  @override
  _ReportHistoryState createState() => _ReportHistoryState();
}

class _ReportHistoryState extends State<HistoryReport> {
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
        title: Text('Your Reports'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userReports.length,
              itemBuilder: (context, index) {
                final report = userReports[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: report['imageUrl'] != null
                        ? Image.network(
                            report['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Container(width: 50, height: 50, color: Colors.grey),
                    title: Text(report['request']),
                    subtitle: Text('Building: ${report['building']}, Room: ${report['room']}'),
                    onTap: () async {
                      // Fetch report details and show them in a new screen
                      final reportData = await fetchReportDetails(report['id']);
                      if (reportData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetail(reportData: reportData, reportId: report['id']),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

class ReportDetail extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final String reportId;

  ReportDetail({required this.reportData, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Code: $reportId',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Building: ${reportData['building']}'),
            Text('Room: ${reportData['room']}'),
            Text('Request: ${reportData['request']}'),
            SizedBox(height: 10),
            Text('Status: ${reportData['status']}'),
            SizedBox(height: 20),
            reportData['imageUrl'] != null
                ? Image.network(reportData['imageUrl'])
                : Container(color: Colors.grey, height: 200, width: double.infinity),
          ],
        ),
      ),
    );
  }
}