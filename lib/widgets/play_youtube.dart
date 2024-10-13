import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MyVideo extends StatefulWidget {
  MyVideo({super.key, required this.url});
  final String url;

  @override
  State<MyVideo> createState() => _MyVideoState();
}

class _MyVideoState extends State<MyVideo> {
  static YoutubePlayerController? _controller;
  late String _url;

  @override
  void initState() {
    _url = widget.url;
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_url)!,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercici'),
      ),
      body: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        onReady: () {
          print('Player is ready.');
        },
      ),
    );
  }
}
