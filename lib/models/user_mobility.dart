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

  // Sugested track direction. False means going backwards in reference to track coordinates
  bool userFollowingTrackDirection = true;
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

// Stream to throw events(name + data)
  StreamController<(String, String?)> streamController =
      StreamController<(String, String?)>();

  bool onTrack = false;
  bool ignoreLowAccuracy = false;
  int minNumberOfConsecutivePoints = 2;
  int minNumberOfConsecutivePointsOutOfAccuracy = 50;
  int minAccuracy = 35; // Minimum acceptable gps accuracy
  double? averageAccuracy;
  int exerciseDistance =
      15; //Minimum distance to be considered on exercise point
  int onTrackDistance = 12; //Minimum distance to be considered on track

  int offTrackDistance = 30; //Minimum distance to be considered off track
  int pointsOutOfAccuracy =
      0; // Number of consecutive captured points with unacceptable gps accuracy
  int pointsOffTrack = 0; // Number of consecutive captured points on track
  int pointsOnTrack = 0; // Number of consecutive captured points off track

  List<String> alreadyReached = [];
  Queue<double> lastFiveAccuracies = Queue<double>();
  Queue<double> lastFiveDistancesToTrack = Queue<double>();
  Queue<double> lastFiveTrackLengths = Queue<
      double>(); // Used to determine user location. Towards track start o track end
  int queueLength = 4;

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
    streamController.add(('trackInitialized', null));
  }

  createEvent(String name, String? data) {
    streamController.add((name, data));
  }

  Future<bool> isValidAccuracy(double accuracy) async {
    return accuracy < minAccuracy;
  }

  handleAccuray(Location loc) async {
    if (!ignoreLowAccuracy) {
      bool locationIsValid = await isValidAccuracy(loc.accuracy!);
      if (!locationIsValid) {
        pointsOutOfAccuracy += 1;
        if (pointsOutOfAccuracy > minNumberOfConsecutivePointsOutOfAccuracy) {
          ignoreLowAccuracy = true;
          bool? confirm = createEvent(
              'accuracyWarning', null); //await openAccuracyWarning();

          ignoreLowAccuracy = true;
          minNumberOfConsecutivePoints += minNumberOfConsecutivePoints;

          return;
        }
      } else {
        pointsOutOfAccuracy = 0;
      }
    }
  }

  handleOnTrack(
      double distanceToTrack, double walkedDistance, double accuracy) async {
    await addLastLocationDistanceAndAccuracy(distanceToTrack, accuracy);
    registerUserDirection(walkedDistance);
    if (!onTrack) {
      // First time location is on track
      if (distanceToTrack < onTrackDistance) {
        pointsOffTrack = 0;
        pointsOnTrack += 1;
        if ((pointsOnTrack >= minNumberOfConsecutivePoints) ||
            (distanceToTrack < onTrackDistance / 2 &&
                accuracy < (onTrackDistance / 2))) {
          onTrack = true;
          createEvent('userOnTrack', null);
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
          createEvent('userOffTrack', null);
          onTrack = false;
        }
      } else {
        pointsOnTrack += 1;
        pointsOffTrack = 0;
      }
    }
  }

  double avgAccuracies(accuracies) {
    double sum = 0;
    for (int i = 0; i < accuracies.length; i++) {
      sum += accuracies.elementAt(i);
    }

    return sum / accuracies.length;
  }

  registerUserDirection(double distance) {
    if (lastFiveTrackLengths.length >= queueLength) {
      lastFiveTrackLengths.removeFirst();
    }
    lastFiveTrackLengths.add(distance);

    List lengthList = lastFiveTrackLengths.toList();
    if (lengthList[0] <= lengthList[lengthList.length - 1]) {
      userFollowingTrackDirection = true;
    } else {
      userFollowingTrackDirection = false;
    }
  }

  addLastLocationDistanceAndAccuracy(double distance, double accuracy) {
    if (lastFiveDistancesToTrack.length >= queueLength) {
      lastFiveDistancesToTrack.removeFirst();
      lastFiveAccuracies.removeFirst();
    }
    lastFiveDistancesToTrack.add(distance);
    lastFiveAccuracies.add(accuracy);
    averageAccuracy = avgAccuracies(lastFiveAccuracies);
  }

  Function eq = const ListEquality().equals;

  bool isGettingAway() {
    if (lastFiveDistancesToTrack.length < queueLength ||
        averageAccuracy == null) {
      return false;
    } else {
      List tmpA = lastFiveDistancesToTrack.toList();
      List<double> tmpB = List<double>.from(tmpA);
      tmpB.sort();
      return eq(tmpA, tmpB) &&
          (lastFiveDistancesToTrack.first > (3 * averageAccuracy!));
    }
  }

  void handleExercisePoints(double distance, Feature p) {
    if (distance < exerciseDistance) {
      if (!alreadyReached.contains(p.properties.id)) {
        createEvent('onExerciseDistance', p.properties.id);
      }
    }
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
