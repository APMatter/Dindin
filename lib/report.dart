import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProblemsPage extends StatefulWidget {
  @override
  _ProblemsPageState createState() => _ProblemsPageState();
}

class _ProblemsPageState extends State<ProblemsPage> {
  String? selectedBuilding;
  String? selectedRoom;
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _requestController = TextEditingController();
  bool _isReportUploaded = false;
  bool _isUploading = false; // สถานะการอัปโหลดข้อมูล

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
      print('Please complete all fields');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload the image to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('reports/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_image!);
      final imageUrl = await ref.getDownloadURL();

      // Reference the user's reports collection
      final reportsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reports');

      // Add report to Firestore
      final reportDoc = await reportsRef.add({
        'building': selectedBuilding,
        'room': selectedRoom,
        'request': _requestController.text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Report uploaded successfully! ID: ${reportDoc.id}')),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2a2a72), Color(0xFFb21f1f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Center(
                child: Container(
                  width: 350,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Problem Status',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StepIndicator(
                            stepNumber: 1,
                            title: 'Report problem',
                            isCompleted: _isReportUploaded,
                          ),
                          StepIndicator(stepNumber: 2, title: 'In progress'),
                          StepIndicator(stepNumber: 3, title: 'Completed'),
                        ],
                      ),
                      SizedBox(height: 20),
                      _isUploading // แสดงสถานะการอัปโหลด
                          ? Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 10),
                                Text("Uploading...",
                                    style: TextStyle(fontSize: 16)),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _pickImage(ImageSource.gallery),
                                      icon: Icon(Icons.image),
                                      label: Text("Upload"),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _pickImage(ImageSource.camera),
                                      icon: Icon(Icons.camera),
                                      label: Text("Take Photo"),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                _image != null
                                    ? Image.file(_image!,
                                        height: 100, fit: BoxFit.cover)
                                    : Container(
                                        height: 100,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(Icons.image,
                                              size: 50, color: Colors.grey),
                                        ),
                                      ),
                                SizedBox(height: 15),
                                TextField(
                                  controller: _requestController,
                                  decoration: InputDecoration(
                                    labelText: 'Request',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Building:',
                                        style: TextStyle(fontSize: 16)),
                                    DropdownButton<String>(
                                      value: selectedBuilding,
                                      hint: Text("Select building"),
                                      items: buildingRooms.keys.map((building) {
                                        return DropdownMenuItem<String>(
                                          value: building,
                                          child: Text(building),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedBuilding = newValue;
                                          selectedRoom = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Room:',
                                        style: TextStyle(fontSize: 16)),
                                    DropdownButton<String>(
                                      value: selectedRoom,
                                      hint: Text("Select room"),
                                      items: (selectedBuilding != null
                                              ? buildingRooms[selectedBuilding]!
                                              : [])
                                          .map<DropdownMenuItem<String>>(
                                              (room) {
                                        return DropdownMenuItem<String>(
                                          value: room,
                                          child: Text(room),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedRoom = newValue;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: uploadReport,
                                  child: Text('Submit Report'),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isCompleted;

  StepIndicator(
      {required this.stepNumber,
      required this.title,
      this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : Colors.blue,
          child: Text(
            '$stepNumber',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
