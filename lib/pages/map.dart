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
import '../utils/geom.dart';

import '../models/itinerary.dart';
import '../models/track.dart';
import '../models/pois.dart';
import '../models/gps.dart';
import '../models/user_mobility.dart';

import 'poi_details.dart';
import 'track_stats.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vibration/vibration.dart';
import 'package:volume_controller/volume_controller.dart';

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
  late Points trackFeatures;
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
  bool exerciseDialogIsOpen = false;

  Track? track;
  late Track userTrack;
  List<LatLng> coords = [];
  bool serviceEnabled = false;
  bool hasLocationPermission = false;
  Position? initialLocation;
  Location? lastLocation;
  StreamSubscription? locationSubscription;

  final MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.none;
  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.normal;
  bool _myLocationEnabled = false;

  List<(int, Feature)> exerciseNodesPosition = [];
  LatLng initView = const LatLng(42.0, 3.0);

  final player = AudioPlayer();
  final gps = Gps();

  late UserMobility userMobility;
  int currentEvent = 0;
  List<String> events = [
    'accuracyWarning',
    'userOnTrack',
    'userOffTrack',
    'onExerciseDistance'
  ];

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    player.dispose();
    super.dispose();
  }

  void snackbar(context, Icon icon, Color color, Text myText) {
    // Close previous snackbar
    if (exerciseDialogIsOpen) {
      Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          children: [
            Row(
              children: [icon, const SizedBox(width: 10), myText],
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: color),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                ))
          ],
        ),
        backgroundColor: color,
        duration: Duration(minutes: 1),
      ),
    );
  }

  Future<List<LatLng>> addExercisesNodesToPath() async {
    // For each trackFeatures add a node to track
    int exerciseIndex = 0;
    for (var i = 0; i < trackFeatures.features.length; i++) {
      LatLng P = LatLng(
        trackFeatures.features[i].geometry.coordinates[1],
        trackFeatures.features[i].geometry.coordinates[0],
      );

      int numSegment = getClosestSegmentToLatLng(coords, P);
      LatLng A = coords[numSegment];
      LatLng B = coords[numSegment + 1];

      LatLng newP = projectPointToSegment(A, B, P);
      if (P.latitude >= min(A.latitude, B.latitude) &&
          (P.latitude <= max(A.latitude, B.latitude))) {
        exerciseIndex = numSegment + 1;
        coords.insert(exerciseIndex, newP);
      } else {
        // if point not inside segment line, then return the closest node of the segment
        if (getDistanceFromLatLonInMeters(A, P) <
            getDistanceFromLatLonInMeters(B, P)) {
          exerciseIndex = numSegment;
        } else {
          exerciseIndex = numSegment + 1;
        }
      }

      // Save exerciseNodePosition
      exerciseNodesPosition.add((exerciseIndex, trackFeatures.features[i]));
      debugPrint('Feture id ${trackFeatures.features[i].properties.id}');
    }
    for (var i = 0; i < exerciseNodesPosition.length; i++) {
      var (idx, feature) = exerciseNodesPosition[i];
    }

    List<Wpt> wpts = [];
    for (var i = 0; i < coords.length; i++) {
      Wpt wpt = Wpt(lat: coords[i].latitude, lon: coords[i].longitude);
      wpts.add(wpt);
    }

    track = Track(wpts);
    track!.init();
    userMobility = UserMobility(wpts, trackFeatures);
    StreamSubscription<(String, String?)> subscription =
        userMobility.streamController.stream.listen(handleMobilityEvent);
    return coords;
  }

  @override
  void initState() {
    userTrack = Track([]);
    _campus = widget.itinerary.campus;
    _title = widget.itinerary.title;
    _path = widget.itinerary.path;
    trackFeatures = widget.itinerary.points;
    _pois = pointsOfInterest;

    for (var i = 0; i < _path.coordinates[0].length; i++) {
      coords
          .add(LatLng(_path.coordinates[0][i][1], _path.coordinates[0][i][0]));
    }

    // Add snapped exercise points to coords

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
      if (status == ServiceStatus.enabled) {
        snackbar(
            context,
            const Icon(Icons.satellite_alt_outlined, color: Colors.white),
            blueUdG,
            Text('GPS Enabled', style: fontColorWhite));
        await listenBackgroundLocations();
      } else {
        serviceEnabled = false;
        hasLocationPermission = false;
        snackbar(
            context,
            const Icon(Icons.satellite_alt_outlined, color: Colors.white),
            redUdG,
            Text('GPS disabled', style: fontColorWhite));
      }
    });

    super.initState(); //comes first for initState();
  }

  void handleMobilityEvent(eventTupple) async {
    var (eventName, eventData) = eventTupple;

    switch (eventName) {
      case 'accuracyWarning':
        snackbar(
          context,
          const Icon(Icons.satellite_alt_rounded, color: Colors.white),
          redUdG,
          Text(AppLocalizations.of(context)!.warningAccuracy,
              style: fontColorWhite),
        );
        // bool confirm = await openAccuracyWarning();
        // if (confirm) {}
        break;
      case 'userOnTrack':
        playSound('sounds/on_track.wav');
        snackbar(
            context,
            const Icon(Icons.directions_walk_rounded, color: Colors.white),
            blueUdG,
            Text(AppLocalizations.of(context)!.trackReached,
                style: fontColorWhite));

        break;
      case 'userOffTrack':
        playSound('sounds/off_track.wav');
        snackbar(
            context,
            const Icon(Icons.warning, color: Colors.white),
            redUdG,
            Text(AppLocalizations.of(context)!.movingAwayFromTrack,
                style: fontColorWhite));
        // _dialogMessageBuilder(
        //     context, AppLocalizations.of(context)!.movingAwayFromTrack);
        break;
      case 'onExerciseDistance':
        var featureId = eventData;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await playSound('sounds/on_track.wav');
        var url = getVideoUrl(eventData, trackFeatures);
        bool? confirmation = await exerciseDialog(context, url);
        exerciseDialogIsOpen = false;
        if (confirmation != null) {
          userMobility.alreadyReached.add(featureId);
        }
    }
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
        Navigator.of(context).pop(true); // dismiss dialog
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MyVideo(url: videoUrl, title: _title, campus: _campus)));
      },
    );
  }

  Widget cancelButton(context) {
    return ElevatedButton(
      style: alertDialogButtons,
      child: Text(AppLocalizations.of(context)!.cancel, style: fontColorRedUdg),
      onPressed: () {
        Navigator.of(context).pop(false); // dismiss dialog
      },
    );
  }

  Future<bool?> exerciseDialog(BuildContext context, String url) async {
    exerciseDialogIsOpen = true;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.udgHealth,
                    style: fontColorWhite),
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

  void onFeatureTap(
      dynamic featureId, Point<double> point, LatLng latLng) async {
    var url = getVideoUrl(featureId, trackFeatures);
    if (url != '') {
      await exerciseDialog(context, url);
      exerciseDialogIsOpen = false;
    } else {
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
    // player.play(AssetSource(sound), volume: 1);
    VolumeController().setVolume(0.1);
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

  (Feature, double) getMinDistanceToExercises(LatLng P) {
    int numSegment = getClosestSegmentToLatLng(coords, P);
    LatLng A = coords[numSegment];
    LatLng B = coords[numSegment + 1];

    int start = 0;
    int end = coords.length - 1;

    List<LatLng> clone = [P];
    for (int i = 0; i < coords.length; i++) {
      clone.add(coords[i]);
    }

    LatLng newP = projectPointToSegment(A, B, P);

    if (P.latitude >= min(A.latitude, B.latitude) &&
        (P.latitude <= max(A.latitude, B.latitude))) {
      clone.insert(numSegment + 1, newP);
      start = numSegment + 1;
    } else {
      // if point not inside segment line, then return the closest node of the segment
      if (getDistanceFromLatLonInMeters(A, P) <
          getDistanceFromLatLonInMeters(B, P)) {
        start = numSegment;
      } else {
        start = numSegment + 1;
      }
    }

    double minDistance = double.infinity;
    var index, feature;
    for (int i = 0; i < exerciseNodesPosition.length; i++) {
      (index, feature) = exerciseNodesPosition[i];
      List idx = [start, index];

      idx.sort();
      List<LatLng> subCoords = clone.sublist(idx[0], idx[1] + 1);

      double d = getLengthFromCoordsList(subCoords);

      if (d < minDistance &&
          !userMobility.alreadyReached.contains(feature.properties.id)) {
        minDistance = d;
        (index, feature) = exerciseNodesPosition[i];
      }
    }

    return (feature, minDistance);
  }

  void handleNewLocation(Location loc) async {
    lastLocation = loc;

    userMobility.handleAccuray(loc);

    double distanceToTrack =
        track!.trackToPointDistance(LatLng(loc.latitude!, loc.longitude!));

    userTrack.push(createWptFromLocation(loc));
    userTrack.setTrackDistance(distanceToTrack);
    userMobility.addLastLocationDistance(distanceToTrack);
    userMobility.handleOnTrack(distanceToTrack);

    if (!userMovedMap) {
      centerMap(LatLng(loc.latitude!, loc.longitude!));
    }

    var (exercise, distanceToExercise) =
        getMinDistanceToExercises(LatLng(loc.latitude!, loc.longitude!));
    userMobility.handleExercisePoints(distanceToExercise, exercise);

    userTrack.setPointsOnTrack(userMobility.pointsOnTrack);
    userTrack.setPointsOffTrack(userMobility.pointsOffTrack);
    userTrack.setOnTrack(userMobility.onTrack);
    userTrack.setDistanteToExercise(distanceToExercise);
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

    // ADD TRACK EXERCISE POINTS TO MAP.
    var pts = trackFeatures.features;
    for (var i = 0; i < pts.length; i++) {
      final symbolOptions = <SymbolOptions>[];

      symbolOptions.add(SymbolOptions(
          iconImage: "exercisePoint",
          iconAnchor: 'bottom',
          geometry: LatLng(
              pts[i].geometry.coordinates[1], pts[i].geometry.coordinates[0])));

      var sym = await mapController!.addSymbols(symbolOptions);
      // Replace property.id for the id of the symbol associated to this point
      pts[i].properties.id = sym[0].id;
    }

    //Snap exercise points to track
    addExercisesNodesToPath();

    trackLine = await mapController!.addLine(LineOptions(
      geometry: track!.getCoordsList(),
      lineColor: trackColor.toHexStringRGB(),
      lineWidth: trackWidth,
      lineOpacity: 0.9,
    ));

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          minMaxZoomPreference: const MinMaxZoomPreference(8, 19),
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          onMapLongClick: (point, coordinates) {
            playSound('sounds/on_track.wav');
          },
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
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TrackStats(track: userTrack)));
                      if (lastLocation != null) {
                        centerMap(LatLng(
                            lastLocation!.latitude!, lastLocation!.longitude!));
                      }
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
