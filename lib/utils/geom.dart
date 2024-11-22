import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geoxml/geoxml.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

int getClosestSegmentToLatLng(gpxCoords, point) {
  if (gpxCoords.length <= 0) return -1;
  int closestSegment = 0;
  double distance = double.infinity;
  double minD = double.infinity;

  // return 0;
  for (var i = 0; i < gpxCoords.length - 1; i++) {
    distance =
        _distanceBetweenSegmentAndPoint(gpxCoords[i], gpxCoords[i + 1], point);

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
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double d = R * c; // Distance in km
  return d * 1000; //distance in meters
}

double getLengthFromCoordsList(List<LatLng> coords) {
  double total = 0;

  for (int i = 0; i < coords.length - 1; i++) {
    double partial = getDistanceFromLatLonInMeters(coords[i], coords[i + 1]);
    total += partial;
  }
  return total;
}

double _deg2rad(double deg) {
  return deg / 180.0 * pi;
}

LatLng projectPointToSegment(LatLng X, LatLng Y, LatLng P) {
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
  double abBp, abAp;

  // Calculating the dot product
  abBp = (AB[0] * BP[0] + AB[1] * BP[1]);
  abAp = (AB[0] * AP[0] + AB[1] * AP[1]);

  // Minimum distance from
  // point E to the line segment
  double reqAns = 0;

  // Case 1
  if (abBp > 0) {
    // Finding the magnitude
    double y = P.latitude - B.latitude;
    double x = P.longitude - B.longitude;
    reqAns = sqrt(x * x + y * y);
  }

  // Case 2
  else if (abAp < 0) {
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

// Min distance between a segment (two points line) and a thirth point
double minDistance(LatLng A, LatLng B, LatLng P) {
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
  double abBp, abAp;

  // Calculating the dot product
  abBp = (AB[0] * BP[0] + AB[1] * BP[1]);
  abAp = (AB[0] * AP[0] + AB[1] * AP[1]);

  // Minimum distance from
  // point E to the line segment
  double reqAns = 0;

  // Case 1
  if (abBp > 0) {
    // Finding the magnitude
    double y = P.latitude - B.latitude;
    double x = P.longitude - B.longitude;
    reqAns = sqrt(x * x + y * y);
  }

  // Case 2
  else if (abAp < 0) {
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

// ¿?
LatLng projectionPoint(LatLng X, LatLng Y, LatLng P) {
  double slope = (Y.latitude - X.latitude) / (Y.longitude - X.longitude);
  double perpendicular = -1 / slope;

  double b = X.latitude - slope * X.longitude;
  double b2 = P.latitude + (P.longitude / slope);

  double intersectionX = (b2 - b) / (slope - perpendicular);
  double intersectionY = (slope * intersectionX) + b;

  return LatLng(intersectionY, intersectionX);
}

double deg2rad(double deg) {
  return deg / 180.0 * pi;
}
