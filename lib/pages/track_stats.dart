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

  List<String> getListItems() {
    List<String> items = [];
    items.add("Captures (on track)");
    items.add("Dist. to track / exercise");
    items.add("Accuracy /Points out of Accuracy");
    items.add("Points on track / off track");
    items.add("Track length");
    items.add("Altitude");
    items.add("Time elapsed");
    return items;
  }

  List<String> getListContent() {
    List<String> items = [];
    items.add('${_track.captures} (${_track.getOnTrack()})');
    items.add(
        '${formatDistance(_track.trackDistance)} / ${formatDistance(_track.getDistToExercise())}');
    items.add(
        '${_track.getAccuracy().toStringAsFixed(2)}m / ${_track.pointsOutOfAccuracy}');
    items.add('${_track.getPointsOnTrack()} / ${_track.getPointsOffTrack()}');
    items.add(formatDistance(_track.length));
    items.add('${_track.altitude}');

    String trackTime = UserSimplePreferences.getTrackTime();
    trackTime =
        _formatDuration(DateTime.now().difference(_track.getStartTime()));
    items.add('${trackTime}');

    return items;
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
        // trackLength = formatDistance(_track.getLength());
        // trackDistance =
        //     double.parse(_track.getTrackDistance().toStringAsFixed(0));

        // trackTime =
        //     _formatDuration(DateTime.now().difference(_track.getStartTime()));
        // trackAltitude = _track.getElevation() != null
        //     ? _track.getElevation().toString() + 'm'
        //     : '--';
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
    var listItems = getListItems();
    var listContent = getListContent();

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.trackUserInfo),
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Center(
          child: ListView.builder(
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              return Container(
                color: index % 2 == 0 ? ochreUdG : greyUdG,
                child: ListTile(
                    title: Column(
                  children: [
                    Text(listItems[index]),
                    Text(
                      listContent[index],
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                )),
              );
            },
          ),
        ));
  }
}
