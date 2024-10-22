import 'dart:async';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/material.dart';
import 'package:geoxml/geoxml.dart';
import 'package:rutes_saludables/models/data.dart';

import '../widgets/play_youtube.dart';

import '../utils/user_simple_preferences.dart';
import '../utils/util.dart';

import '../models/itinerary.dart';
import '../models/track.dart';
import '../models/pois.dart';
import 'poi_details.dart';

class MapPage extends StatelessWidget {
  final Itinerary itinerary;

  MapPage({
    super.key,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.itinerary.campus + ' - ' + this.itinerary.title),
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: MapWidget(itinerary: this.itinerary));
  }
}

class MapWidget extends StatefulWidget {
  final Itinerary itinerary;

  const MapWidget({
    super.key,
    required this.itinerary,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapLibreMapController? mapController;
  late Path _path;
  late Points _points;
  late List<Feature> _pois;
  late String _title;
  late String _campus;
  late Line trackLine;
  bool onTrack = false;
  int tolerance = 15; //meters
  int onTrackDistance = 20; //meters
  int offTrackDistance = 50; //meters

  int pointsOffTrack = 0;
  int pointsOnTrack = 0;
  Location location = new Location();
  List<String> alreadyReached = [];

  Track? track;
  double trackWidth = 6;
  Color trackColor = Colors.orange; // Selects a mid-range green.

  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.compass;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.trackingGps;

  ButtonStyle udgStyle = ElevatedButton.styleFrom(
      backgroundColor: blueUdG, foregroundColor: Colors.white);

  final player = AudioPlayer();

  void initState() {
    super.initState(); //comes first for initState();
    _campus = widget.itinerary.campus;
    _title = widget.itinerary.title;
    _path = widget.itinerary.path;
    _points = widget.itinerary.points;
    _pois = pointsOfInterest;

    location.enableBackgroundMode(enable: true);
    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
  }

  Future<void> _dialogMessageBuilder(BuildContext context, String msg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Hello world!'),
            content: Text(msg),
            actions: [
              FloatingActionButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('OK'),
              ),
            ]);
      },
    );
  }

  Widget launchButton(contect, videoUrl) {
    return ElevatedButton(
      style: udgStyle,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("OK"),
        ],
      ),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MyVideo(url: videoUrl, title: _title, campus: _campus)));
      },
    );
  }

  Widget cancelButton(contect) {
    return ElevatedButton(
      style: udgStyle,
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
  }

  Future<void> _dialogBuilder(BuildContext context, String url) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('UdG Salut',
                    style: TextStyle(
                      color: blueUdG,
                    )),
                // SizedBox(width: 10),
                // Image(
                //   image: AssetImage('assets/images/salut_no_text.png'),
                //   height: 25,
                // ),
              ],
            ),
            content: const Text("Vols veure el video de l'exercici recomanat?",
                style: TextStyle(color: blueUdG, fontSize: 18)),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                launchButton(context, url),
                SizedBox(width: 10),
                cancelButton(context),
              ])
            ]);
      },
    );
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {
    var url = getVideoUrl(featureId, _points);
    if (url != '') {
      _dialogBuilder(context, url);
    }
    //check if tap on some POI
    Properties? info = getPoiInfo(featureId, _pois);
    if (info != null) {
      print(info.description);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PoiDetails(
                  title: info.title,
                  content: info.description,
                  moreInfo: info.url)));
    }
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
    mapController!.onFeatureTapped.add(onFeatureTap);
    List<Wpt> wpts = [];
    List lineCoords = _path.coordinates[0];

    for (var i = 0; i < lineCoords.length; i++) {
      Wpt wpt = Wpt(lat: lineCoords[i][1], lon: lineCoords[i][0]);
      wpts.add(wpt);
    }

    track = Track(wpts);

    await track!.init();

    mapController!.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: track!.getBounds().southEast,
          northeast: track!.getBounds().northWest,
        ),
        left: 10,
        top: 5,
        bottom: 25,
      ),
    );

    bool gpEnabled = UserSimplePreferences.getGpsEnabled() ?? false;
    bool gpsPermission = UserSimplePreferences.getHasPermission() ?? false;

    if (gpsPermission) {
      location.onLocationChanged.listen((LocationData currentLocation) {
        manageNewPosition(currentLocation);
      });
    }
  }

  Future<void> playSound(String sound) async {
    await player.setVolume(1);
    // await player.setReleaseMode(ReleaseMode.loop);
    player.play(AssetSource(sound));
  }

  void manageNewPosition(LocationData loc) async {
    location.changeNotificationOptions(
      title: 'Geolocation ',
      subtitle: 'Current accuracy ' + loc.accuracy.toString(),
    );
    // Check if location is in track
    double distanceToTrack =
        track!.trackToPointDistance(LatLng(loc.latitude!, loc.longitude!));
    if (!onTrack && (loc.accuracy! < tolerance)) {
      if (distanceToTrack < onTrackDistance) {
        onTrack = true;
        pointsOffTrack = 0;
        pointsOnTrack += 1;
        playSound('sounds/on_track.mp3');
      } else {
        pointsOffTrack += 1;
      }
    } else {
      if (onTrack &&
          (distanceToTrack > offTrackDistance && loc.accuracy! < tolerance)) {
        // Location is moving away
        onTrack = false;
        pointsOffTrack += 1;
        pointsOnTrack = 0;
        playSound('sounds/off_track.mp3');
        _dialogMessageBuilder(context, 'Moving away from track');
      } else {
        pointsOnTrack += 1;
      }
    }

    // Loop through all track points
    bool inRange = false;
    for (var a = 0; a < _points.features.length && !inRange; a++) {
      var p = _points.features[a];
      var coords = p.geometry.coordinates;
      double distance = getDistanceFromLatLonInMeters(
          LatLng(coords[1], coords[0]), LatLng(loc.latitude!, loc.longitude!));
      if (distance < tolerance) {
        inRange = true;
        String url = getVideoUrl(p.properties.id, _points);
        if (!alreadyReached.contains(url)) {
          await playSound('sounds/small_sound.mp3');
          alreadyReached.add(url);
          _dialogBuilder(context, url);
        }
      }
    }
  }

  Future<void> addImageFromAsset(String name, String assetName) async {
    final bytes = await rootBundle.load(assetName);
    final list = bytes.buffer.asUint8List();
    return mapController!.addImage(name, list);
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      trackCameraPosition: true,
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      myLocationTrackingMode: _myLocationTrackingMode,
      myLocationRenderMode: _myLocationRenderMode,
      onStyleLoadedCallback: () async {
        addImageFromAsset("exercisePoint", "assets/marker_salut.png");
        addImageFromAsset("poi", "assets/marker_poi.png");

        trackLine = await mapController!.addLine(LineOptions(
          geometry: track!.getCoordsList(),
          lineColor: trackColor.toHexStringRGB(),
          lineWidth: trackWidth,
          lineOpacity: 0.9,
        ));

        // ADD TRACK POINTS TO MAP. EXERCISES
        var pts = _points.features;
        for (var i = 0; i < pts.length; i++) {
          final symbolOptions = <SymbolOptions>[];

          symbolOptions.add(SymbolOptions(
              iconImage: "exercisePoint",
              iconAnchor: 'bottom',
              geometry: LatLng(pts[i].geometry.coordinates[1],
                  pts[i].geometry.coordinates[0])));

          var sym = await mapController!.addSymbols(symbolOptions);

          pts[i].properties.id = sym[0].id;
        }

        // ADD POINTS OF INTEREST TO MAP
        for (var i = 0; i < _pois.length; i++) {
          final symbolOptions = <SymbolOptions>[];

          symbolOptions.add(SymbolOptions(
              iconImage: "poi",
              iconAnchor: 'bottom',
              geometry: LatLng(_pois[i].geometry.coordinates[1],
                  _pois[i].geometry.coordinates[0])));

          var sym = await mapController!.addSymbols(symbolOptions);

          _pois[i].properties.id = sym[0].id;
        }
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(42.0, 3.0),
        zoom: 13.0,
      ),
      styleString:
          // 'https://geoserveis.icgc.cat/contextmaps/icgc_mapa_base_gris_simplificat.json',
          'https://geoserveis.icgc.cat/contextmaps/icgc_orto_hibrida.json',
    );
  }
}

String getVideoUrl(String id, Points pts) {
  var features = pts.features;
  for (var i = 0; i < features.length; i++) {
    var f = features[i];
    if (f.properties.id == id) {
      return 'https://' + f.properties.description;
    }
  }
  return '';
}

Properties? getPoiInfo(String id, List<Feature> pois) {
  for (var i = 0; i < pois.length; i++) {
    var f = pois[i];
    if (f.properties.id == id) {
      return f.properties;
    }
  }
  return null;
}
