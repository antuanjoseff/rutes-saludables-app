import 'package:flutter/material.dart';
import '../models/track.dart';
import 'dart:async';
import '../utils/user_simple_preferences.dart';

class TrackStats extends StatefulWidget {
  final Track track;
  const TrackStats({super.key, required this.track});

  @override
  State<TrackStats> createState() => _TrackStatsState();
}

class _TrackStatsState extends State<TrackStats> {
  late Track _track;
  Timer? _timer;
  late String trackLength;
  late String trackTime;
  late String trackAltitude;

  String _formatDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String formatDistance(double length) {
    int kms = (length / 1000).floor().toInt();
    int mts = (length - (kms * 1000)).toInt();

    String plural = kms > 1 ? 's ' : ' ';

    String format = '';
    if (kms > 0) {
      format = '${kms.toString()}Km$plural';
    }

    format += '${mts}m';
    return format;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _track = widget.track;

    trackLength = UserSimplePreferences.getTrackLength();
    trackTime = UserSimplePreferences.getTrackTime();
    trackAltitude = UserSimplePreferences.getTrackAltitude();

    // defines a timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        trackLength = formatDistance(_track.getLength());
        trackTime =
            _formatDuration(DateTime.now().difference(_track.getStartTime()));
        trackAltitude = _track.getElevation() != null
            ? _track.getElevation().toString() + 'm'
            : '--';
      });
    });
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
    await UserSimplePreferences.setTrackLength(trackLength);
    await UserSimplePreferences.setTrackTime(trackTime);
    await UserSimplePreferences.setTrackAltitude(trackAltitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Informació de l'itinerari"),
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Distància', style: TextStyle(fontSize: 25)),
                Text(
                  trackLength,
                  style: const TextStyle(fontSize: 45),
                ),
                SizedBox(height: 15),
                const Text('Altitud', style: TextStyle(fontSize: 25)),
                Text(
                  trackAltitude,
                  style: const TextStyle(fontSize: 45),
                ),
                SizedBox(height: 15),
                const Text('Temps en moviment', style: TextStyle(fontSize: 25)),
                Text(
                  trackTime,
                  style: const TextStyle(fontSize: 45),
                )
              ],
            ),
          ],
        ));
  }
}
