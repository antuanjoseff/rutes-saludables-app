import 'package:flutter/material.dart';
import 'package:geoxml/geoxml.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'bounds.dart' as my;
import 'dart:math';
import '../utils/geom.dart';

class Track {
  // Original track
  List<Wpt> trackSegment = [];

  // Array of coordinates to draw a linestring on map
  List<LatLng> gpxCoords = [];

  // Start recording time
  DateTime startAt = DateTime.now();

  // Track length
  double length = 0;
  double distanceToOrigin = 0;

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

  void push(Wpt wpt) async {
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
}
