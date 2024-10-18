import 'dart:async';
import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../models/track.dart';
import 'package:geoxml/geoxml.dart';

import '../widgets/play_youtube.dart';
import 'package:flutter/services.dart';
import '../utils/user_simple_preferences.dart';
import '../utils/util.dart';
import 'package:location/location.dart';

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
  late String _title;
  late String _campus;
  late Line trackLine;
  int snapDistance = 15;
  int counter = 0;
  Location location = new Location();
  List<String> alreadyReached = [];

  Track? track;
  double trackWidth = 6;
  Color trackColor = Colors.orange; // Selects a mid-range green.

  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.compass;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.trackingGps;

  void initState() {
    super.initState(); //comes first for initState();
    _campus = widget.itinerary.campus;
    _title = widget.itinerary.title;
    _path = widget.itinerary.path;
    _points = widget.itinerary.points;

    location.enableBackgroundMode(enable: true);
    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
  }

  Future<void> _dialogBuilder(BuildContext context, String videoUrl) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return MyVideo(url: videoUrl, title: _title, campus: _campus);
      },
    );
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {
    var prop = getVideoUrl(featureId, _points);
    if (prop != '') {
      _dialogBuilder(context, prop);
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

  void manageNewPosition(LocationData loc) {
    counter++;
    location.changeNotificationOptions(
      title: 'Geolocation ' + counter.toString(),
      subtitle: 'Geolocation detection ' + counter.toString(),
    );
    bool inRange = false;
    for (var a = 0; a < _points.features.length && !inRange; a++) {
      var p = _points.features[a];
      var coords = p.geometry.coordinates;
      double distance = getDistanceFromLatLonInMeters(
          LatLng(coords[1], coords[0]), LatLng(loc.latitude!, loc.longitude!));

      if (distance < snapDistance) {
        inRange = true;
        String url = getVideoUrl(p.properties.id, _points);
        if (!alreadyReached.contains(url)) {
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

        trackLine = await mapController!.addLine(LineOptions(
          geometry: track!.getCoordsList(),
          lineColor: trackColor.toHexStringRGB(),
          lineWidth: trackWidth,
          lineOpacity: 0.9,
        ));

        var pts = _points.features;
        for (var i = 0; i < pts.length; i++) {
          final symbolOptions = <SymbolOptions>[];
          String image = 'exercisePoint';

          symbolOptions.add(SymbolOptions(
              iconImage: "exercisePoint",
              geometry: LatLng(pts[i].geometry.coordinates[1],
                  pts[i].geometry.coordinates[0])));

          var sym = await mapController!.addSymbols(symbolOptions);

          // var p = await mapController!.addCircle(
          //   CircleOptions(
          //       circleRadius: 20,
          //       geometry: LatLng(pts[i].geometry.coordinates[1],
          //           pts[i].geometry.coordinates[0]),
          //       circleColor: "#FF0000"),
          // );
          pts[i].properties.id = sym[0].id;
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
