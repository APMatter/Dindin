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
    'C1 Building': ['C1 111', 'C1 112', 'C1 203'],
    'C2 Building': ['C2 203', 'C2 204', 'C2 205'],
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
      color: Colors.grey[600], // Icon color (change as needed)
    ),
    onPressed: () => Navigator.pop(context),
  ),
  title: Text(
    "Report Issue",
    style: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black, // Text color to stand out on white background
    ),
  ),
  centerTitle: true,
  backgroundColor: Colors.white, // Pure white background for AppBar
  elevation: 0, // Removes shadow for a clean look
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
                SizedBox(height: 20),
                
                // Card with the form fields
                Card(
                  color: Colors.white,  // Set the Card color to white
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
                            child: Text(
                              "Uploading...",
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ),
                        ] else ...[
                          _buildImagePicker(),
                          SizedBox(height: 15),
                          _buildTextField("Description", _requestController),
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
                                  : [], (value) {
                            setState(() {
                              selectedRoom = value;
                            });
                          }),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: uploadReport,
                            child: Text('Submit Report',
                                style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                        ],
                      ],
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
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera),
              label: Text("Camera"),
            ),
          ],
        ),
        SizedBox(height: 10),
        _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_image!, height: 150, fit: BoxFit.cover),
              )
            : Container(
                height: 150,
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
        fillColor: Colors.grey[200],
      ),
      style: GoogleFonts.poppins(fontSize: 14),
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
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }
}
