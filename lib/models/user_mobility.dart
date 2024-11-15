import 'package:geoxml/geoxml.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'bounds.dart' as myBounds;
import 'dart:async';
import 'package:background_location/background_location.dart';
import '../models/itinerary.dart';
import '../utils/util.dart';

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
  int minAccuracy = 35; //meters
  int exerciseDistance = 10; //meters
  int onTrackDistance = 16; //meters
  int offTrackDistance = 16; //meters
  int pointsOutOfAccuracy = 0; //meters
  int pointsOffTrack = 0;
  int pointsOnTrack = 0;

  List<String> alreadyReached = [];

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
          bool confirm =
              createEvent('accuracyWarning'); //await openAccuracyWarning();
          if (confirm) {
            ignoreLowAccuracy = true;
            minNumberOfConsecutivePoints += minNumberOfConsecutivePoints;
          }
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
      if (onTrack && (distanceToTrack > offTrackDistance)) {
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

  double handleExercisePoints(Location loc) {
// Loop through all track points
    bool inRange = false;
    double minDistance = double.infinity;

    for (var a = 0; a < itineraryPoints.features.length && !inRange; a++) {
      var p = itineraryPoints.features[a];
      var coords = p.geometry.coordinates;
      double distance = getDistanceFromLatLonInMeters(
          LatLng(coords[1], coords[0]), LatLng(loc.latitude!, loc.longitude!));
      if (distance < minDistance) {
        minDistance = distance;
      }
      if (minDistance < exerciseDistance) {
        inRange = true;
        String url = getVideoUrl(p.properties.id, itineraryPoints);
        if (!alreadyReached.contains(url)) {
          alreadyReached.add(url);
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
