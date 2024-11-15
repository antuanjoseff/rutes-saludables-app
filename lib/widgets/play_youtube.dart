import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MyVideo extends StatefulWidget {
  const MyVideo({
    super.key,
    required this.url,
    required this.title,
    required this.campus,
  });

  final String url;
  final String title;
  final String campus;

  @override
  State<MyVideo> createState() => _MyVideoState();
}

class _MyVideoState extends State<MyVideo> {
  static YoutubePlayerController? _controller;
  late String _url;
  late String _campus;
  late String _title;

  @override
  void initState() {
    _url = widget.url;
    _campus = widget.campus;
    _title = widget.title;
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_url)!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        if (orientation == Orientation.portrait) {
          return Scaffold(
            appBar: AppBar(
              title: Text('$_campus - $_title'),
              backgroundColor: const Color(0xff3242a0),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                  onReady: () {
                    print('Player is ready.');
                  },
                )
              ],
            ),
          );
        } else {
          return Scaffold(
            body: YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: true,
              onReady: () {
                print('Player is ready.');
              },
            ),
          );
        }
      },
    );
  }
}
