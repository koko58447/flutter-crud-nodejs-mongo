import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../constants.dart';
import '../utils.dart';
import 'package:http_parser/http_parser.dart';
import 'package:universal_html/html.dart' as mylib;

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  XFile? _video;
  VideoPlayerController? _videoController;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo == null) return;

    setState(() => _video = pickedVideo);

    if (kIsWeb) {
      final bytes = await pickedVideo.readAsBytes();
      final blob = mylib.Blob([bytes.buffer], 'video/mp4');
      final url = mylib.Url.createObjectUrlFromBlob(blob);

      _videoController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
        });
    } else {
      _videoController = VideoPlayerController.file(File(pickedVideo.path))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _uploadVideo() async {
    if (_video == null) {
      showSnackBar(context, "Please select a video first");
      return;
    }

    showLoadingDialog(context);

    try {
      final url = Uri.parse('$apiBaseUrl/api/videos/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['name'] = _video!.name;

      final bytes = await _video!.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'video',
        bytes,
        filename: _video!.name,
        contentType: MediaType(
          'video',
          'mp4',
        ), // သင့် video format အလိုက်ပြင်ပါ
      );

      request.files.add(multipartFile);

      final response = await request.send();

      Navigator.pop(context); // Dismiss loading dialog

      if (response.statusCode == 201) {
        showSnackBar(context, "Video uploaded successfully");
        Navigator.pop(context, true);
      } else {
        final resp = await response.stream.bytesToString();
        final json = jsonDecode(resp);
        showSnackBar(context, json['message'] ?? "Upload failed");
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      showSnackBar(context, "Error: $e");
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Uploading..."),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Upload & Play')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎞️ Choose Video Button
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: Icon(Icons.video_library),
              label: Text("Choose Video"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 16),

            // 📄 Selected Video Name
            if (_video != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Selected: ${_video!.name}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            SizedBox(height: 16),

            // ⬆️ Upload Button
            ElevatedButton.icon(
              onPressed: _uploadVideo,
              icon: Icon(Icons.upload),
              label: Text("Upload Video"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ▶️ Video Preview
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      VideoPlayer(_videoController!),
                      // ▶️ Play/Pause Button
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              size: 50,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_video != null)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
