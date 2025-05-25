import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../utils.dart';

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
    final result = await pickImageAndGetResult(_picker, fromCamera: fromCamera);
    if (result != null) {
      setState(() {
        _filePath = result['filePath'];
        _fileBytes =
            result['fileBytes']; // Reset bytes if a file path is selected
      });
      print("File Name: $_filePath");
      if (_fileBytes != null) {
        print("File Size: ${_fileBytes!.lengthInBytes} bytes");
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_filePath == null) {
        showErrorDialog(context, "Please select an image.");
        return;
      }

      final name = _nameController.text;

      try {
        final response = await _uploadData(name);
        if (response.statusCode == 200) {
          Navigator.pop(context, true);
          showSuccessDialog(context, "Data uploaded successfully!");
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
      request.files.add(
        http.MultipartFile.fromBytes('image', _fileBytes!, filename: _filePath),
      );
    } else {
      // For mobile, use file path
      request.files.add(await http.MultipartFile.fromBytes('image', _fileBytes!, filename: _filePath));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Form")),
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
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 16),
              if (_fileBytes != null)
                Center(
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Center(
                          child: Card(
                            elevation: 4,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Selected Image",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Image.memory(
                                    _fileBytes!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // const Spacer(),
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
