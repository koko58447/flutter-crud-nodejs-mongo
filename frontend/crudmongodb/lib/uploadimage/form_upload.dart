import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class FormUpload extends StatefulWidget {
  const FormUpload({super.key});

  @override
  _FormUploadState createState() => _FormUploadState();
}

class _FormUploadState extends State<FormUpload> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _filePath;
  Uint8List? _fileBytes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool fromCamera) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, read the file as bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _fileBytes = bytes;
            _filePath = pickedFile.name;
          });
        } else {
          // For mobile, use the file path
          setState(() {
            _filePath = pickedFile.path;
          });
        }
      }
    } catch (e) {
      _showErrorDialog("Failed to pick image: $e");
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_filePath == null) {
        _showErrorDialog("Please select an image.");
        return;
      }

      final name = _nameController.text;

      try {
        final response = await _uploadData(name);
        if (response.statusCode == 200) {
          Navigator.pop(context, true);
          _showSuccessDialog("Data uploaded successfully!");
        } else {
          Navigator.pop(context, true);
          print("Failed to upload data: ${response.body}");
        }
      } catch (e) {
        print("An error occurred: $e");
      }
    }
  }

  Future<http.Response> _uploadData(String name) async {
    final uri = Uri.parse('$apiBaseUrl/api/uploads/upload');
    final request = http.MultipartRequest("POST", uri)..fields['name'] = name;

    if (kIsWeb) {
      // For web, use file bytes
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _fileBytes!,
        filename: _filePath,
      ));
    } else {
      // For mobile, use file path
      request.files.add(await http.MultipartFile.fromPath('image', _filePath!));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Form"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(true),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(false),
                    icon: const Icon(Icons.folder),
                    label: const Text("Browse"),
                  ),
                ],
              ),
              if (_filePath != null) ...[
                const SizedBox(height: 16),
                Text("Selected Path: $_filePath"),
              ],
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
