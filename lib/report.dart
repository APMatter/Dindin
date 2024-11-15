import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_connection/pendingStatus.dart';

class ProblemsReport extends StatefulWidget {
  @override
  _ProblemsPageState createState() => _ProblemsPageState();
}
class _ProblemsPageState extends State<ProblemsReport> {
  String? selectedBuilding;
  String? selectedRoom;
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _requestController = TextEditingController();
  bool _isUploading = false;
  String? status = 'Inprogress';

  final Map<String, List<String>> buildingRooms = {
  'C1 Building': ['C1 111', 'C1 112', 'C1 203', 'C1 204', 'C1 205', 'C1 206', 
                  'C1 207', 'C1 208', 'C1 209', 'C1 210', 'C1 211', 'C1 212', 
                  'C1 213', 'C1 214', 'C1 215', 'C1 216', 'C1 217', 'C1 218', 
                  'C1 219', 'C1 220', 'C1 221', 'C1 305', 'C1 305/1', 'C1 306', 
                  'C1 307/2', 'C1 307/3', 'C1 310', 'C1 311', 'C1 312', 'C1 313', 
                  'C1 314'],
  'C2 Building': ['C2 203', 'C2 204', 'C2 205', 'C2 206', 'C2 207', 'C2 208', 
                  'C2 209', 'C2 210', 'C2 211', 'C2 212', 'C2 213', 'C2 214', 
                  'C2 215', 'C2 303', 'C2 304', 'C2 305', 'C2 306', 'C2 307', 
                  'C2 308', 'C2 309', 'C2 310', 'C2 311', 'C2 312', 'C2 313', 
                  'C2 314', 'C2 315', 'C2 402', 'C2 403', 'C2 406', 'C2 407', 
                  'C2 410', 'C2 411'],
  'C3 Building': ['C3 101', 'C3 102', 'C3 106', 'C3 107'],
  'C5 Building': ['C5 201', 'C5 202', 'C5 203', 'C5 204', 'C5 205', 'C5 206', 
                  'C5 207', 'C5 208', 'C5 223', 'C5 224', 'C5 225', 'C5 301', 
                  'C5 302', 'C5 318', 'C5 319', 'C5 320', 'C5 312', 'C5 322', 
                  'C5 412', 'C5 413', 'C5 416'],
  'D1 Building': ['D1 301', 'D1 306'],
  'E1 Building': ['E1 414', 'E1 444'],
  'E2 Building': ['E2 130', 'E2 BTS/1'],
  'E3 Building': ['E3-B 101', 'E3-B 102', 'E3-B 206', 'E3-B 208', 
                  'E3-B 209', 'E3-B 210'],
  'E4 Building': ['E4-A 607', 'E4-A 608', 'E4-A 609', 'E4-A 614', 
                  'E4-A 615', 'E4-A 617', 'E4-A 618', 'E4-A 707', 
                  'E4-A 709', 'E4-A 714', 'E4-A 715', 'E4-A 716', 
                  'E4-A 717', 'E4-A 718', 'E4-A 811', 'E4-A 812'],
  'Gymnasium': ['GM 115'],
  'M3 Building': ['M3 201', 'M3 203', 'M3 213', 'M3 311', 'M3 321', 'M3 321/1', 
                  'M3 321/2', 'M3 325', 'M3 332', 'M3 511', 'M3 532', 'M3 535', 
                  'M3 615'],
  'MD Building': ['MD 221', 'MD 222', 'MD 224', 'MD 226', 'MD 325', 'MD 423', 
                  'MD 424', 'MD 425', 'MD 815', 'MD 816'],
  'M Square Building': ['ME 317', 'ME 414', 'ME 415', 'ME 416', 'ME 423'],
  'S1 Building': ['S1 101', 'S1 102', 'S1 201', 'S1 202', 'S1 206', 'S1 301', 
                  'S1 302', 'S1 303', 'S1 304', 'S1 305', 'S1 314', 'S1 316'],
  'S2 Building': ['S2 111', 'S2 203', 'S2 205', 'S2 206', 'S2 301', 'S2 303', 
                  'S2 304', 'S2 305', 'S2 311', 'S2 401', 'S2 404'],
  'S3 Building': ['S3 105', 'S3 108', 'S3 111', 'S3 114', 'S3 201', 'S3 203', 
                  'S3 208', 'S3 213', 'S3 215', 'S3 217', 'S3 220', 'S3 301', 
                  'S3 303', 'S3 305', 'S3 310', 'S3 312', 'S3 314', 'S3 317', 
                  'S3 317/2', 'S3 401', 'S3 403', 'S3 415', 'S3 417', 'S3 419', 
                  'S3 422', 'S3 503', 'S3 505', 'S3 507', 'S3 508'],
  'S4 Building': ['S4 102', 'S4 103', 'S4 105', 'S4 106', 'S4 106/10', 
                  'S4 106/9', 'S4 107/1', 'S4 107/2', 'S4 114', 'S4 115', 
                  'S4 119', 'S4 120', 'S4 124'],
  'S7 Building': ['S7-A 202', 'S7-A 204', 'S7-A 211', 'S7-A 213', 'S7-A 301', 
                  'S7-A 302', 'S7-A 303', 'S7-A 304', 'S7-A 311', 'S7-A 312', 
                  'S7-A 313', 'S7-A 314', 'S7-A 401', 'S7-A 402', 'S7-A 409', 
                  'S7-A 410', 'S7-A 411', 'S7-A 412', 'S7-B 306', 'S7-B 333', 
                  'S7-B 335', 'S7-B 406', 'S7-B 413', 'S7-B 414', 'S7-B 415', 
                  'SALLC'],
  'SCL Building': ['SCL 101', 'SCL 102', 'SCL 103', 'SCL 104', 'SCL 106']
};


  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (await Permission.camera.request().isDenied) {
      print('Camera permission denied');
    }
    if (await Permission.storage.request().isDenied) {
      print('Storage permission denied');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is logged in');
      return;
    }

    if (_image == null || selectedBuilding == null || selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('reports/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_image!);
      final imageUrl = await ref.getDownloadURL();

      final reportId =
          FirebaseFirestore.instance.collection('Reports').doc().id;

      final reportData = {
        'building': selectedBuilding,
        'room': selectedRoom,
        'request': _requestController.text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'status': status,
      };

      final userReportsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .doc(reportId);

      final topReportsRef =
          FirebaseFirestore.instance.collection('Reports').doc(reportId);

      await userReportsRef.set(reportData);
      await topReportsRef.set(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report uploaded successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DependStatusPage(
            reportCode: reportId,
            status: status ?? 'pending',
            request: _requestController.text,
            building: selectedBuilding ?? 'Unknown',
          ),
        ),
      );
    } catch (e) {
      print('Failed to upload report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload report')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Problems Report",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status bar at the top
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Image.asset('pic/inprogress_blue.png', width: 40, height: 40),
                            SizedBox(height: 5),
                            Text('Report', style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('pic/inprogress.png', width: 30, height: 30),
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
                  ),
                ),
                SizedBox(height: 15),

                // Card with the form fields
                Card(
                  color: Colors.white, 
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isUploading) ...[
                          Center(child: CircularProgressIndicator()),
                          SizedBox(height: 10),
                          Center(
                            child: Text("Uploading...", style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                        ] else ...[
                          _buildImagePicker(),
                          SizedBox(height: 15),
                          Container(
                            
                            child: _buildTextField("Description", _requestController)),
                          SizedBox(height: 20),
                          _buildDropdown(
                              "Building", selectedBuilding, buildingRooms.keys.toList(),
                              (value) {
                            setState(() {
                              selectedBuilding = value;
                              selectedRoom = null;
                            });
                          }),
                          SizedBox(height: 20),
                          _buildDropdown(
                              "Room",
                              selectedRoom,
                              selectedBuilding != null
                                  ? buildingRooms[selectedBuilding]!
                                  : [],
                              (value) {
                            setState(() {
                              selectedRoom = value;
                            });
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
                // ปุ่ม Submit ที่อยู่ตรงกลาง
                SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: uploadReport,
                      child: Text('Submit Report', style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ปรับปุ่ม Gallery และ Camera ให้มีสีพื้นหลังเป็นน้ำเงิน
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Image:', style: GoogleFonts.poppins(fontSize: 16)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.image),
              label: Text("Gallery"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900], 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera),
              label: Text("Camera"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900], 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        // ไม่แสดงพื้นที่รูปภาพจนกว่าจะมีการเลือกภาพ
        if (_image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_image!, height: 100, fit: BoxFit.cover),
          )
        else
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          ),
      ],
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      style: GoogleFonts.poppins(fontSize: 14,),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16)),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text("Select $label"),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}
