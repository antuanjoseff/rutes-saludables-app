import 'package:flutter/material.dart';
import 'package:geoxml/geoxml.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'bounds.dart' as my;
import 'dart:math';

class Track {
  // Original track
  List<Wpt> trackSegment = [];

  // Array of coordinates to draw a linestring on map
  List<LatLng> gpxCoords = [];

  // Start recording time
  DateTime startAt = DateTime.now();

  // Track length
  double length = 0;

  // Last distance to track
  double trackDistance = -1;

  // Current altitud
  int? altitude;

  // Constructor
  Track(this.trackSegment);

  // Bbox del track
  my.Bounds? bounds;

  //offPointTracks (Consecutive points off track)
  int pointsOffTrack = 0;

  //user is on track?
  bool onTrack = false;

  // Distance to closest point exercise
  double distToExercise = 0;

  //onPointTracks (Consecutive points on track)
  int pointsOnTrack = 0;

  // Total gps location captures
  int captures = 0;

  // Acuracy of last point
  double accuracy = 0;

  // Consecutive points low accuracy
  double pointsOutOfAccuracy = 0;

  void init() async {
    LatLng cur;

    // Init track bounds with first track point
    bounds = my.Bounds(LatLng(trackSegment.first.lat!, trackSegment.first.lon!),
        LatLng(trackSegment.first.lat!, trackSegment.first.lon!));

    for (var i = 0; i < trackSegment.length; i++) {
      cur = LatLng(trackSegment[i].lat!, trackSegment[i].lon!);

      bounds!.expand(cur);
      gpxCoords.add(cur);
    }
  }

  List<LatLng> getCoordsList() {
    return gpxCoords;
  }

  List<Wpt> getTrack() {
    return trackSegment;
  }

  my.Bounds getBounds() {
    return bounds!;
  }

  double getLength() {
    return length;
  }

  int? getElevation() {
    return altitude;
  }

  DateTime getStartTime() {
    return startAt;
  }

  double getTrackDistance() {
    return trackDistance;
  }

  int getPointsOnTrack() {
    return pointsOnTrack;
  }

  int getPointsOffTrack() {
    return pointsOffTrack;
  }

  double getDistToExercise() {
    return distToExercise;
  }

  bool getOnTrack() {
    return onTrack;
  }

  double getAccuracy() {
    return accuracy;
  }

  setPointsOnTrack(int value) {
    pointsOnTrack = value;
  }

  setPointsOffTrack(int value) {
    pointsOffTrack = value;
  }

  setOnTrack(bool value) {
    onTrack = value;
  }

  setDistanteToExercise(double distance) {
    distToExercise = distance;
  }

  void setTrackDistance(double d) {
    trackDistance = d;
  }

  void setAccuracy(double value) {
    accuracy = value;
  }

  void reset() {
    gpxCoords = [];
    trackSegment = [];
  }

  void push(Wpt wpt) {
    double inc = 0;
    LatLng P = LatLng(wpt.lat!, wpt.lon!);
    if (gpxCoords.isNotEmpty) {
      LatLng prev = gpxCoords[gpxCoords.length - 1];
      inc = getDistanceFromLatLonInMeters(P, prev);
    }

    gpxCoords.add(P);
    trackSegment.add(wpt);
    length += inc;
    altitude = wpt.ele!.floor();
  }

  void insert(int position, Wpt wpt) {
    LatLng P = LatLng(wpt.lat!, wpt.lon!);
    gpxCoords.insert(position + 1, P);
    trackSegment.insert(position + 1, wpt);
  }

  void remove(int index) {
    trackSegment.removeAt(index);
    gpxCoords.removeAt(index);
  }

  void addWpt(int idx, Wpt wpt) {
    trackSegment.insert(idx, wpt);
    LatLng latlon = LatLng(wpt.lat!, wpt.lon!);
    gpxCoords.insert(idx, latlon);
  }

  void removeWpt(int idx, Wpt wpt) {
    trackSegment.removeAt(idx);
    gpxCoords.removeAt(idx);
  }

  void moveWpt(int idx, Wpt wpt) {
    trackSegment[idx] = wpt;
    LatLng latlon = LatLng(wpt.lat!, wpt.lon!);
    gpxCoords[idx] = latlon;
  }

  void changeNodeAt(int idx, LatLng coordinate) {
    gpxCoords[idx] = coordinate;
  }

  Wpt getWptAt(int idx) {
    return trackSegment[idx];
  }

  void setWptAt(int idx, Wpt wpt) {
    trackSegment[idx] = wpt;
  }

  double trackToPointDistance(LatLng point) {
    Stopwatch stopwatch = new Stopwatch()..start();
    int numSegment = getClosestSegmentToLatLng(gpxCoords, point);
    print('Closest at ($numSegment) executed in ${stopwatch.elapsed}');

    LatLng A = gpxCoords[numSegment];
    LatLng B = gpxCoords[numSegment + 1];

    LatLng P = _projectPointToSegment(A, B, point);

    // Check if point is inside segment lint
    if (P.latitude >= min(A.latitude, B.latitude) &&
        (P.latitude <= max(A.latitude, B.latitude))) {
      double dist = getDistanceFromLatLonInMeters(point, P);
      return dist;
    } else {
      // if point not inside segment line, then return the closest node of the segment
      if (getDistanceFromLatLonInMeters(A, P) <
          getDistanceFromLatLonInMeters(B, P)) {
        double dist = getDistanceFromLatLonInMeters(point, A);

        return dist;
      } else {
        double dist = getDistanceFromLatLonInMeters(point, B);
        return dist;
      }
    }
  }

  int getClosestSegmentToLatLng(gpxCoords, point) {
    if (gpxCoords.length <= 0) return -1;
    int closestSegment = 0;
    double distance = double.infinity;
    double minD = double.infinity;

    // return 0;
    for (var i = 0; i < gpxCoords.length - 1; i++) {
      distance = _distanceBetweenSegmentAndPoint(
          gpxCoords[i], gpxCoords[i + 1], point);

      if (distance < minD) {
        minD = distance;
        closestSegment = i;
      }
    }

    return closestSegment;
  }

  double getDistanceFromLatLonInMeters(LatLng origin, LatLng target) {
    double lat1 = origin.latitude;
    double lat2 = target.latitude;
    double lon1 = origin.longitude;
    double lon2 = target.longitude;

    int R = 6371; // Radius of the earth in km
    double dLat = _deg2rad(lat2 - lat1); // deg2rad below
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = R * c; // Distance in km
    return d * 1000; //distance in meters
  }

  double _deg2rad(double deg) {
    return deg / 180.0 * pi;
  }

  LatLng _projectPointToSegment(LatLng X, LatLng Y, LatLng P) {
    double slope = (Y.latitude - X.latitude) / (Y.longitude - X.longitude);
    double perpendicular = -1 / slope;

    double b = X.latitude - slope * X.longitude;
    double b2 = P.latitude + (P.longitude / slope);

    double intersectionX = (b2 - b) / (slope - perpendicular);
    double intersectionY = (slope * intersectionX) + b;

    return LatLng(intersectionY, intersectionX);
  }

  double _distanceBetweenSegmentAndPoint(LatLng A, LatLng B, LatLng P) {
    // vector AB
    List<double> AB = [];

    AB.add(B.longitude - A.longitude);
    AB.add(B.latitude - A.latitude);

    // vector BP
    List<double> BP = [];
    BP.add(P.longitude - B.longitude);
    BP.add(P.latitude - B.latitude);

    // vector AP
    List<double> AP = [];
    AP.add(P.longitude - A.longitude);
    AP.add(P.latitude - A.latitude);

    // Variables to store dot product
    double AB_BP, AB_AP;

    // Calculating the dot product
    AB_BP = (AB[0] * BP[0] + AB[1] * BP[1]);
    AB_AP = (AB[0] * AP[0] + AB[1] * AP[1]);

    // Minimum distance from
    // point E to the line segment
    double reqAns = 0;

    // Case 1
    if (AB_BP > 0) {
      // Finding the magnitude
      double y = P.latitude - B.latitude;
      double x = P.longitude - B.longitude;
      reqAns = sqrt(x * x + y * y);
    }

    // Case 2
    else if (AB_AP < 0) {
      double y = P.latitude - A.latitude;
      double x = P.longitude - A.longitude;
      reqAns = sqrt(x * x + y * y);
    }

    // Case 3
    else {
      // Finding the perpendicular distance
      double x1 = AB[0];
      double y1 = AB[1];
      double x2 = AP[0];
      double y2 = AP[1];
      double mod = sqrt(x1 * x1 + y1 * y1);
      reqAns = ((x1 * y2 - y1 * x2) / mod).abs();
    }
    return reqAns;
  }
}
