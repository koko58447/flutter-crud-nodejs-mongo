import 'package:crudnodejsmongodb/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as mylib;
import 'package:flutter/foundation.dart' show kIsWeb;

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoName;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.videoName,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    print("videoUrl:" + widget.videoUrl);
    super.initState();
    if (kIsWeb) {
      // 🔁 web အတွက် network URL ကနေ play လုပ်တာ
      _controller = VideoPlayerController.network(apiBaseUrl + widget.videoUrl)
        ..initialize().then((_) {
          setState(() {});
          _controller.play(); // auto play
        });
    } else {
      // 📱 mobile အတွက် local သို့မဟုတ် network
      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) {
          setState(() {});
          _controller.play(); // auto play
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.videoName)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              Center(child: CircularProgressIndicator()),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  iconSize: 40,
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
