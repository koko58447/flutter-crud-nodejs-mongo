import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../constants.dart';
import '../utils.dart';
import 'package:http_parser/http_parser.dart'; // For content-type

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  XFile? _video;
  String? _videoPath;
   List<String> videoUrls = [];
 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _video = pickedVideo;
      _videoPath = pickedVideo?.name;
    });
  }

  Future<void> _uploadVideo() async {
    if (_video == null) return;

    final url = Uri.parse('$apiBaseUrl/api/videos/upload');
    final request = http.MultipartRequest('POST', url)..fields['name'] =_video!.name;

    // Read video data as bytes 
    final bytes = await _video!.readAsBytes();

    // Create MultipartFile from bytes
    final multipartFile = http.MultipartFile.fromBytes(
      'video',
      bytes,
      filename: _video!.name,
      contentType: MediaType('video', 'mp4'), // သင့် video type အလိုက်ပြင်ပါ
    );

    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 201) {
      print('Upload successful');
    } else {
      print('Upload failed with status: ${response.reasonPhrase}');
    }
  }

    Future<void> fetchVideos() async {
    final response = http.get(Uri.parse('$apiBaseUrl/api/videos/'));
    final data = jsonDecode((await response).body);
    print(data);

    setState(() {
     videoUrls = data.map<String>((item) => item['path'].toString()).toList();
     print(videoUrls!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Upload & Play')),
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _pickVideo,
            icon: Icon(Icons.video_library),
            label: Text("Choose Video"),
          ),
          if (_video != null) Text(_video!.name),
          ElevatedButton.icon(
            onPressed: _uploadVideo,
            icon: Icon(Icons.upload),
            label: Text("Upload Video"),
          ),
          SizedBox(height: 20),
        
        ],
      ),
    );
  }
}
