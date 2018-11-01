import 'package:flutter/material.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  final String url;

  const VideoApp({Key key, this.url}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.url,
    )
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized.
        setState(() {
          _controller.play();
        });
      });
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap:
            _controller.value.isPlaying ? _controller.pause : _controller.play,
        child: Center(
          child: _controller.value.initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : LoadingScreen(),
        ),
      ),
      bottomSheet: Container(
          height: 25.0,
          child: VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
          )),
    );
  }
}
