import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {}
  }

  // Method to upload file
  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/upload_csv'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Name of the field on the server
        _selectedFile!.path,
      ),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      if (mounted) {
        // Check if the widget is still mounted before navigating
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      print('File uploaded successfully');
    } else {
      print('File upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Upload')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Select File'),
            ),
            SizedBox(height: 20),
            _selectedFile != null
                ? Text('Selected File: ${_selectedFile!.path}')
                : Text('No file selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}
