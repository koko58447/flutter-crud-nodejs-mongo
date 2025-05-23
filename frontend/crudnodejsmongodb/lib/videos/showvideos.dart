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

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _video = pickedVideo;
      _videoPath = pickedVideo?.name;
      print("path: " + _videoPath!);
    });
  }

  Future<void> _uploadVideo() async {
    if (_video == null) return;

    final url = Uri.parse('$apiBaseUrl/api/videos/upload');
    final request = http.MultipartRequest('POST', url);
    request.fields['filename'] = _video!.name;
    request.fields['path'] =
        '/uploads/${_video!.name}'; // သင့် server ပေါ်က uploads folder အတိုင်း

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Video")),
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
        ],
      ),
    );
  }
}

class VideoList extends StatefulWidget {
  final List<String> videoUrls;

  VideoList({required this.videoUrls});

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  late VideoPlayerController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.videoUrls.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: initializeVideoPlayer(widget.videoUrls[index]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<void> initializeVideoPlayer(String url) async {
    _controller = VideoPlayerController.network(url);
    await _controller.initialize();
    setState(() {});
  }
}
