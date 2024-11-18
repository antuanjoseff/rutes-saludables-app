import 'package:geoxml/geoxml.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'bounds.dart' as myBounds;
import 'dart:async';
import 'package:background_location/background_location.dart';
import '../models/itinerary.dart';
import '../utils/util.dart';
import 'dart:collection';
import 'package:collection/collection.dart';

class UserMobility {
  // Original path
  List<Wpt> referencePath = [];
  List<Wpt> donePath = [];
  Points itineraryPoints;
  // Start recording time
  DateTime startAt = DateTime.now();

  // Track length
  double length = 0;

  // Last distance to track
  double trackDistance = -1;

  // Current altitud
  int? altitude;

// Bbox del track
  myBounds.Bounds? bounds;

// Stream to throw events
  StreamController<String> streamController = StreamController<String>();

  bool onTrack = false;
  bool ignoreLowAccuracy = false;
  int minNumberOfConsecutivePoints = 1;
  int minAccuracy = 35; // Minimum acceptable gps accuracy
  int exerciseDistance =
      10; //Minimum distance to be considered on exercise point
  int onTrackDistance = 7; //Minimum distance to be considered on track
  int offTrackDistance = 50; //Minimum distance to be considered off track
  int pointsOutOfAccuracy =
      0; // Number of consecutive captured points with unacceptable gps accuracy
  int pointsOffTrack = 0; // Number of consecutive captured points on track
  int pointsOnTrack = 0; // Number of consecutive captured points off track

  List<String> alreadyReached = [];
  Queue<double> lastFiveDistances = Queue<double>();
  int queueLength = 5;

  // Constructor
  UserMobility(this.referencePath, this.itineraryPoints) {
    LatLng cur;

    // Init track bounds with first track point
    bounds = myBounds.Bounds(
        LatLng(referencePath.first.lat!, referencePath.first.lon!),
        LatLng(referencePath.first.lat!, referencePath.first.lon!));

    for (var i = 0; i < referencePath.length; i++) {
      cur = LatLng(referencePath[i].lat!, referencePath[i].lon!);

      bounds!.expand(cur);
    }
    streamController.add('track has been init');
  }

  createEvent(String name) {
    streamController.add(name);
  }

  Future<bool> isValidAccuracy(double accuracy) async {
    return accuracy < minAccuracy;
  }

  handleAccuray(Location loc) async {
    if (!ignoreLowAccuracy) {
      bool locationIsValid = await isValidAccuracy(loc.accuracy!);
      if (!locationIsValid) {
        pointsOutOfAccuracy += 1;
        if (pointsOutOfAccuracy > minNumberOfConsecutivePoints) {
          ignoreLowAccuracy = true;
          bool? confirm =
              createEvent('accuracyWarning'); //await openAccuracyWarning();

          ignoreLowAccuracy = true;
          minNumberOfConsecutivePoints += minNumberOfConsecutivePoints;

          return;
        }
      } else {
        pointsOutOfAccuracy = 0;
      }
    }
  }

  handleOnTrack(double distanceToTrack) {
    if (!onTrack) {
      // First time location is on track
      if (distanceToTrack < onTrackDistance) {
        pointsOffTrack = 0;
        pointsOnTrack += 1;
        if (pointsOnTrack > minNumberOfConsecutivePoints) {
          onTrack = true;
          createEvent('userOnTrack');
        }
      } else {
        pointsOffTrack += 1;
        pointsOnTrack = 0;
      }
    } else {
      // User is on track
      if (onTrack && (isGettingAway())) {
        // Location is moving away
        pointsOffTrack += 1;
        pointsOnTrack = 0;
        if (pointsOffTrack > minNumberOfConsecutivePoints) {
          createEvent('userOffTrack');
          onTrack = false;
        }
      } else {
        pointsOnTrack += 1;
        pointsOffTrack = 0;
      }
    }
  }

  addLastLocationDistance(double distance) {
    if (lastFiveDistances.length >= queueLength) {
      lastFiveDistances.removeFirst();
    }
    lastFiveDistances.add(distance);
  }

  bool isGettingAway() {
    Function eq = const ListEquality().equals;
    if (lastFiveDistances.length < 5) {
      return false;
    } else {
      List tmpA = lastFiveDistances.toList();
      List<double> tmpB = List<double>.from(tmpA);
      tmpB.sort();
      print('LAST FIVE POSITIONS UNSORTED ${tmpA}');
      print('LAST FIVE POSITIONS SORTED ${tmpB}');
      print('Equals ${eq(tmpA, tmpB)}');
      return eq(tmpA, tmpB);
    }
  }

  double handleExercisePoints(Location loc) {
// Loop through all track points
    bool inRange = false;
    double minDistance = double.infinity;

    for (var a = 0; a < itineraryPoints.features.length && !inRange; a++) {
      var p = itineraryPoints.features[a];
      if (alreadyReached.contains(p.properties.id)) {
        continue;
      }
      var coords = p.geometry.coordinates;

      double distance = getDistanceFromLatLonInMeters(
          LatLng(coords[1], coords[0]), LatLng(loc.latitude!, loc.longitude!));
      if (distance < minDistance) {
        minDistance = distance;
      }
      if (minDistance < exerciseDistance) {
        inRange = true;
        String url = getVideoUrl(p.properties.id, itineraryPoints);
        if (!alreadyReached.contains(p.properties.id)) {
          alreadyReached.add(p.properties.id);
          createEvent('onExerciseDistance');
        }
      }
    }
    return minDistance;
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
}
