import 'dart:async';
import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../models/track.dart';
import 'package:geoxml/geoxml.dart';

class MapPage extends StatelessWidget {
  final Path path;
  final Points points;

  MapPage({
    super.key,
    required this.path,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Itinerari')),
        body: MapWidget(path: this.path, points: this.points));
  }
}

class MapWidget extends StatefulWidget {
  final Path path;
  final Points points;

  const MapWidget({
    super.key,
    required this.path,
    required this.points,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapLibreMapController? mapController;
  late Path _path;
  late Points _points;
  late Line trackLine;

  Track? track;
  double trackWidth = 6;
  Color trackColor = Colors.orange; // Selects a mid-range green.

  void initState() {
    super.initState(); //comes first for initState();
    _path = widget.path;
    _points = widget.points;
  }

  Future<void> _dialogBuilder(BuildContext context, String content) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informació del punt'),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {
    var prop = getPointProperties(featureId, _points, latLng);
    if (prop != '') {
      _dialogBuilder(context, prop);
    }
  }

  // final snackBar = SnackBar(
  //   content: Text(
  //     'Tapped feature with id $featureId',
  //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //   ),
  //   backgroundColor: Theme.of(context).primaryColor,
  // );
  // ScaffoldMessenger.of(context).clearSnackBars();
  // ScaffoldMessenger.of(context).showSnackBar(snackBar);

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

    var a = track!.getCoordsList();
    print(a.length);
    for (var i = 0; i < a.length; i++) {
      print(a[i].latitude);
      print('*' * 10);
      print(a[i].longitude);
    }
    print(mapController == null);
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      compassEnabled: false,
      myLocationEnabled: true,
      trackCameraPosition: true,
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: () async {
        trackLine = await mapController!.addLine(LineOptions(
          geometry: track!.getCoordsList(),
          lineColor: trackColor.toHexStringRGB(),
          lineWidth: trackWidth,
          lineOpacity: 0.9,
        ));

        var pts = _points.features;
        for (var i = 0; i < pts.length; i++) {
          var p = await mapController!.addCircle(
            CircleOptions(
                circleRadius: 20,
                geometry: LatLng(pts[i].geometry.coordinates[1],
                    pts[i].geometry.coordinates[0]),
                circleColor: "#FF0000"),
          );
          pts[i].properties.id = p.id;
        }
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(42.0, 3.0),
        zoom: 13.0,
      ),
      // onStyleLoadedCallback: _onStyleLoadedCallback,
      styleString:
          // 'https://geoserveis.icgc.cat/contextmaps/icgc_mapa_base_gris_simplificat.json',
          'https://geoserveis.icgc.cat/contextmaps/icgc_orto_hibrida.json',
    );
  }
}

String getPointProperties(String id, Points pts, LatLng coords) {
  var features = pts.features;
  for (var i = 0; i < features.length; i++) {
    var f = features[i];
    if (f.properties.id == id) {
      return f.properties.description;
    }
  }
  return '';
}
