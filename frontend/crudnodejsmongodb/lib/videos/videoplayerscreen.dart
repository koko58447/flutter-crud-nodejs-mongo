import 'package:crudnodejsmongodb/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as mylib;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../utils.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String id;
  final String videoUrl;
  final String videoName;

  const VideoPlayerScreen({
    Key? key,
    required this.id,
    required this.videoUrl,
    required this.videoName,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  late final videoUrl = '$apiBaseUrl${widget.videoUrl}'.replaceAll(r'\', '/');

  void initializeVideoPlayer() {
    if (kIsWeb) {
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize()
            .then((_) {
              if (mounted) {
                _controller.setVolume(0.5); // for auto play in web
                setState(() {});
                _controller.play();
              }
            })
            .catchError((e) {
              print("Web Video Error: $e");
            });
    } else {
      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize()
            .then((_) {
              if (mounted) {
                setState(() {});
                _controller.play();
              }
            })
            .catchError((e) {
              print("Mobile Video Error: $e");
            });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
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
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth * 0.8, // screen width ရဲ့ 80%
                      height:
                          constraints.maxWidth *
                          0.8 /
                          _controller.value.aspectRatio,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    );
                  },
                ),
              )
            else
              Center(child: CircularProgressIndicator()),

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
                IconButton(
                  icon: Icon(Icons.share),
                  iconSize: 40,
                  color: Colors.blue,
                  onPressed: () {
                    Share.share(videoUrl);
                  },
                ),
                if (kIsWeb)
                  IconButton(
                    icon: Icon(Icons.download),
                    iconSize: 40,
                    color: Colors.blue,
                    onPressed: () {
                      mylib.window.open(videoUrl, '_blank');
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.delete),
                  iconSize: 40,
                  color: Colors.red,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Video'),
                        content: Text(
                          'Are you sure you want to delete this video?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final response = await http.delete(
                                Uri.parse(
                                  '$apiBaseUrl/api/videos/${widget.id}',
                                ),
                              );
                              if (response.statusCode == 200) {
                                Navigator.pop(context, true);
                                Navigator.pop(context, true);
                              } else {
                                showErrorDialog(
                                  context,
                                  'Failed to delete video',
                                );
                              }
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
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
