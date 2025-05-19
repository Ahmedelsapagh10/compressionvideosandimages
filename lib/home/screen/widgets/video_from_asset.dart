import 'dart:io';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import 'video_from_file_screen.dart';

class VideoPlayerScreenFromFile extends StatefulWidget {
  File? videoFile;
  VideoPlayerScreenFromFile({required this.videoFile, super.key});
  @override
  _VideoPlayerScreenFromFileState createState() =>
      _VideoPlayerScreenFromFileState();
}

class _VideoPlayerScreenFromFileState extends State<VideoPlayerScreenFromFile> {
  VideoPlayerController? _controller;
  Future<void> _pickVideo() async {
    if (widget.videoFile != null) {
      _controller = VideoPlayerController.file(
        widget.videoFile!,
      )..initialize().then((_) {
          setState(() {});
          // _controller!.play();
        });
    }
  }

  @override
  void initState() {
    _pickVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller != null && _controller!.value.isInitialized
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoPlayerScreenFile(
                              videoFile: widget.videoFile,
                            )));
              },
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(
                  _controller!,
                ),
              ),
            )
          : Container(
              color: Colors.red,
              child: Image.asset('assets/images/profile.png')),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
