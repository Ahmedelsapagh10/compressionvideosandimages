import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreenFile extends StatefulWidget {
  final File? videoFile;
  const VideoPlayerScreenFile({required this.videoFile, super.key});

  @override
  _VideoPlayerScreenFileState createState() => _VideoPlayerScreenFileState();
}

class _VideoPlayerScreenFileState extends State<VideoPlayerScreenFile> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> _pickVideo() async {
    if (widget.videoFile != null) {
      _videoPlayerController = VideoPlayerController.file(widget.videoFile!)
        ..initialize().then((_) {
          setState(() {});
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            additionalOptions: (context) {
              return <OptionItem>[
                OptionItem(
                  onTap: () {
                    _videoPlayerController!.seekTo(Duration.zero);
                  },
                  iconData: Icons.replay,
                  title: 'Replay',
                ),
              ];
            },
          );
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
    return Dismissible(
      key: const Key('some key here'),
      direction: DismissDirection.down,
      background: Container(),
      onDismissed: (_) => Navigator.pop(context),
      child: WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          body: Center(
            child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : Image.asset('assets/images/profile.png'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
