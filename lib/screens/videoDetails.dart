import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';

class videoDetailScreen extends StatefulWidget {
  String postimage;
  videoDetailScreen({Key? key, required this.postimage}) : super(key: key);

  @override
  State<videoDetailScreen> createState() => _videoDetailScreenState();
}

class _videoDetailScreenState extends State<videoDetailScreen> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(widget.postimage),
      //aspectRatio: 16 / 9,
      autoInitialize: true,
      autoPlay: false,
      looping: false,
      showControls: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
              ),
            ),
      body: Chewie(controller: _chewieController!),
    );
  }
}
