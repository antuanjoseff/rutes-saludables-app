import 'dart:async';
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_location/background_location.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter/material.dart';
import 'package:geoxml/geoxml.dart';
import 'package:rutes_saludables/models/data.dart';
import 'package:rutes_saludables/models/user_mobility.dart';

import '../widgets/play_youtube.dart';
import '../widgets/mapScale.dart';

import '../utils/util.dart';

import '../models/itinerary.dart';
import '../models/track.dart';
import '../models/pois.dart';
import '../models/gps.dart';
import '../models/user_mobility.dart';

import 'poi_details.dart';
import 'track_stats.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vibration/vibration.dart';

class MapPage extends StatelessWidget {
  final Itinerary itinerary;

  const MapPage({
    super.key,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${itinerary.campus}  -  ${itinerary.title}'),
          backgroundColor: const Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: MapWidget(itinerary: itinerary));
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
  double mapScaleWidth = 60;
  String? mapScaleText;
  double? resolution;
  late Path _path;
  late Points _points;
  late List<Feature> _pois;
  late String _title;
  late String _campus;
  late Line trackLine;

  final stopwatch = Stopwatch();
  bool _isMoving = false;
  bool justStop = false;
  bool justMoved = false;
  int panTime = 0;
  bool trackCameroMove = true;
  bool userMovedMap = false;

  Track? track;
  late Track userTrack;
  bool serviceEnabled = false;
  bool hasLocationPermission = false;
  Position? initialLocation;
  Location? lastLocation;
  StreamSubscription? locationSubscription;

  final MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.none;
  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.normal;
  bool _myLocationEnabled = false;

  LatLng initView = const LatLng(42.0, 3.0);

  final player = AudioPlayer();
  final gps = Gps();

  late UserMobility userMobility;

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }

  void snackbar(context, type, myText) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(type == 'success' ? Icons.thumb_up : Icons.warning_rounded,
                color: Colors.white),
            const SizedBox(width: 20),
            Expanded(child: Text(myText))
          ],
        ),
        backgroundColor: type == 'success' ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    userTrack = Track([]);
    _campus = widget.itinerary.campus;
    _title = widget.itinerary.title;
    _path = widget.itinerary.path;
    _points = widget.itinerary.points;
    _pois = pointsOfInterest;

    List<Wpt> wpts = [];
    List lineCoords = _path.coordinates[0];

    for (var i = 0; i < lineCoords.length; i++) {
      Wpt wpt = Wpt(lat: lineCoords[i][1], lon: lineCoords[i][0]);
      wpts.add(wpt);
    }

    track = Track(wpts);
    track!.init();
    userMobility = UserMobility(wpts, _points);
    StreamSubscription<String> subscription =
        userMobility.streamController.stream.listen(
      (String eventName) {
        handleMobilityEvent(eventName);
      },
    );

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
      if (status == ServiceStatus.enabled) {
        snackbar(context, 'success', 'GPS enabled!!');
        await listenBackgroundLocations();
      } else {
        snackbar(context, 'error', 'GPS disabled!!');
      }
    });
    super.initState(); //comes first for initState();
  }

  void handleMobilityEvent(eventName) async {
    switch (eventName) {
      case 'accuracyWarning':
        bool confirm = await openAccuracyWarning();
        if (confirm) {}
        break;
      case 'userOnTrack':
        playSound('sounds/on_track.mp3');
        snackbar(
            context, 'success', AppLocalizations.of(context)!.trackReached);
        break;
      case 'userOffTrack':
        playSound('sounds/off_track.mp3');
        _dialogMessageBuilder(
            context, AppLocalizations.of(context)!.movingAwayFromTrack);
        break;
      case 'onExerciseDistance':
        await playSound('sounds/small_sound.mp3');
        _dialogBuilder(
            context,
            userMobility
                .alreadyReached[userMobility.alreadyReached.length - 1]);
    }
  }

  Future<void> _dialogMessageBuilder(BuildContext context, String msg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(AppLocalizations.of(context)!.alert,
                style: fontColorWhite),
            backgroundColor: redUdG,
            content: Text(msg, style: fontColorWhite),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: alertDialogButtons,
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ]);
      },
    );
  }

  Widget launchButton(contect, videoUrl) {
    return ElevatedButton(
      style: alertDialogButtons,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.ok),
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
      style: alertDialogButtons,
      child: Text(AppLocalizations.of(context)!.cancel, style: fontColorRedUdg),
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.udgHealth,
                    style: fontColorWhite),
                // SizedBox(width: 10),
                // Image(
                //   image: AssetImage('assets/images/salut_no_text.png'),
                //   height: 25,
                // ),
              ],
            ),
            backgroundColor: redUdG,
            content: Text(AppLocalizations.of(context)!.wantToSeeVideo,
                style: fontColorWhite),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                launchButton(context, url),
                const SizedBox(width: 10),
                cancelButton(context),
              ])
            ]);
      },
    );
  }

  String getVideoUrl(String id, Points pts) {
    var features = pts.features;
    for (var i = 0; i < features.length; i++) {
      var f = features[i];
      if (f.properties.id == id) {
        return 'https://${f.properties.description}';
      }
    }
    return '';
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

  void _onMapChanged() async {
    final position = mapController!.cameraPosition;
    _isMoving = mapController!.isCameraMoving;
    if (_isMoving) {
      if (!justMoved) {
        justMoved = true;
        stopwatch.start();
      }
    } else {
      justMoved = false;
      justStop = true;
      panTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();
      stopwatch.reset();

      if (trackCameroMove && panTime > 200) {
        userMovedMap = true;
      }
    }
    resolution = await mapController!.getMetersPerPixelAtLatitude(
        mapController!.cameraPosition!.target.latitude);

    mapScaleText = (mapScaleWidth * resolution!).toStringAsFixed(0);
    setState(() {});
  }

  void _onMapCreated(MapLibreMapController controller) async {
    if (!mounted) return;

    mapController = controller;
    controller.addListener(_onMapChanged);
    resolution = await mapController!.getMetersPerPixelAtLatitude(
        mapController!.cameraPosition!.target.latitude);

    mapScaleText = (mapScaleWidth * resolution!).toStringAsFixed(0);
    mapController!.addListener(_onMapChanged);
    mapController!.onFeatureTapped.add(onFeatureTap);
    await mapController!.setSymbolIconAllowOverlap(true);
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

    hasLocationPermission = await requestLocationService();
    if (hasLocationPermission && initialLocation == null) {
      if (mounted) {
        BackgroundLocation.setAndroidNotification(
          title: AppLocalizations.of(context)!.notificationTitle,
          message: AppLocalizations.of(context)!.notificationContent,
        );
      } else {
        BackgroundLocation.setAndroidNotification(
          title: 'UdGsalut',
          message: 'Rutes saludables',
        );
      }

      await listenBackgroundLocations();
      _myLocationEnabled = true;

      getCurrentLocation().then((value) {
        setState(() {
          initialLocation = value;
        });
      });
    }
  }

  Future<void> listenBackgroundLocations() async {
    BackgroundLocation
        .stopLocationService(); //To ensure that previously started services have been stopped, if desired
    BackgroundLocation.startLocationService(distanceFilter: 5);
    BackgroundLocation.getLocationUpdates((location) {
      handleNewLocation(location);
    });
  }

  void centerMap(LatLng location) {
    mapController!.animateCamera(
      CameraUpdate.newLatLng(location),
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<void> playSound(String sound) async {
    await player.setVolume(1);
    player.play(AssetSource(sound));
    bool? vibrate = await Vibration.hasVibrator();
    bool? pattern = await Vibration.hasCustomVibrationsSupport();
    if (vibrate == true) {
      if (pattern == true) {
        Vibration.vibrate(pattern: [500, 500, 500, 500]);
      } else {
        Vibration.vibrate();
      }
    }
  }

  Future<bool> openAccuracyWarning() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.warningAccuracy,
                    style: fontColorWhite),
                backgroundColor: redUdG,
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: alertDialogButtons,
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(AppLocalizations.of(context)!.ok)),
                    ],
                  )
                ]));
  }

  void handleNewLocation(Location loc) async {
    lastLocation = loc;
    userMobility.handleAccuray(loc);

    double distanceToTrack =
        track!.trackToPointDistance(LatLng(loc.latitude!, loc.longitude!));

    userTrack.push(createWptFromLocation(loc));
    userTrack.setTrackDistance(distanceToTrack);

    userMobility.handleOnTrack(distanceToTrack);

    if (!userMovedMap) {
      centerMap(LatLng(loc.latitude!, loc.longitude!));
    }

    double minDistance = userMobility.handleExercisePoints(loc);

    userTrack.setPointsOnTrack(userMobility.pointsOnTrack);
    userTrack.setPointsOffTrack(userMobility.pointsOffTrack);
    userTrack.setOnTrack(userMobility.onTrack);
    userTrack.setDistanteToExercise(minDistance);
    userTrack.setAccuracy(loc.accuracy!);
    userTrack.captures += 1;
  }

  Future<void> addImageFromAsset(String name, String assetName) async {
    final bytes = await rootBundle.load(assetName);
    final list = bytes.buffer.asUint8List();
    return mapController!.addImage(name, list);
  }

  void callSetState() {
    _myLocationRenderMode = MyLocationRenderMode.compass;
    setState(() {});
  }

  Future<Position?> getCurrentLocation() async {
    if (serviceEnabled && hasLocationPermission) {
      return await Geolocator.getCurrentPosition();
    } else {
      return null;
    }
  }

  Future<bool> requestLocationService() async {
    serviceEnabled = await gps.checkService();
    bool permission = false;
    if (serviceEnabled) {
      permission = await gps.requestPermission();
    }
    return permission;
    // if (hasLocationPermission && initialLocation == null) {
    //   _myLocationEnabled = true;
    //   setState(() {});
    // }
  }

  Future<void> _onStyleCallback() async {
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
          geometry: LatLng(
              pts[i].geometry.coordinates[1], pts[i].geometry.coordinates[0])));

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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          minMaxZoomPreference: const MinMaxZoomPreference(8, 19),
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          myLocationEnabled: _myLocationEnabled,
          myLocationTrackingMode: _myLocationTrackingMode,
          myLocationRenderMode: _myLocationRenderMode,
          onStyleLoadedCallback: _onStyleCallback,
          initialCameraPosition: CameraPosition(
            target: (initialLocation != null)
                ? LatLng(initialLocation!.latitude, initialLocation!.longitude)
                : initView,
            zoom: 13.0,
          ),
          styleString:
              // 'https://geoserveis.icgc.cat/contextmaps/icgc_mapa_base_gris_simplificat.json',
              'https://geoserveis.icgc.cat/contextmaps/icgc_orto_hibrida.json',
        ),
        resolution != null
            ? Positioned(
                bottom: 30,
                right: 10,
                child: MapScale(
                  resolution: resolution!,
                  mapscale: mapScaleText,
                ))
            : Container(),
        Positioned(
            left: 10,
            top: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: redUdG,
                      padding: const EdgeInsets.only(
                          bottom: 6, top: 6, left: 15, right: 15), // and this
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TrackStats(track: userTrack)));
                    },
                    child: Text(AppLocalizations.of(context)!.trackData,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18))),
                const SizedBox(width: 10),
                if (userMovedMap && lastLocation != null)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: redUdG,
                        padding: const EdgeInsets.only(
                            bottom: 6, top: 6, left: 15, right: 15), // and this
                      ),
                      onPressed: () {
                        userMovedMap = false;
                        if (lastLocation != null) {
                          centerMap(LatLng(lastLocation!.latitude!,
                              lastLocation!.longitude!));
                        }
                        setState(() {});
                      },
                      child: Text(AppLocalizations.of(context)!.centerMap,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18))),
              ],
            ))
      ],
    );
  }
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

Wpt createWptFromLocation(Location location) {
  Wpt wpt = Wpt();
  wpt.lat = location.latitude;
  wpt.lon = location.longitude;
  wpt.ele = location.altitude;
  wpt.time = DateTime.now();

  return wpt;
}
