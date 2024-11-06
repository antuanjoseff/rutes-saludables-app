import 'package:flutter/material.dart';
import 'package:rutes_saludables/models/data.dart';
import '../models/track.dart';
import 'dart:async';
import '../utils/user_simple_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late double trackDistance;

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
    trackDistance = double.parse(_track.getTrackDistance().toStringAsFixed(0));

    // defines a timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        trackLength = formatDistance(_track.getLength());
        trackDistance =
            double.parse(_track.getTrackDistance().toStringAsFixed(0));

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
          title: Text(AppLocalizations.of(context)!.trackUserInfo),
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Container(
          color: ochreUdG,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                  color: blueUdG,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(AppLocalizations.of(context)!.distance,
                            style: const TextStyle(fontSize: 25)),
                        Text(
                          trackLength,
                          style: const TextStyle(fontSize: 45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Text(AppLocalizations.of(context)!.distanceToTrack,
                            style: const TextStyle(fontSize: 25)),
                        Text(
                          '$trackDistance',
                          style: const TextStyle(fontSize: 45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Text(AppLocalizations.of(context)!.altitude,
                            style: TextStyle(fontSize: 25)),
                        Text(
                          trackAltitude,
                          style: const TextStyle(fontSize: 45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Text(AppLocalizations.of(context)!.movingTime,
                            style: TextStyle(fontSize: 25)),
                        Text(
                          trackTime,
                          style: const TextStyle(fontSize: 45),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
