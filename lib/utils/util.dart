import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geoxml/geoxml.dart';
import 'dart:math';
import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';

/// Adds an asset image to the currently displayed style
Future<void> addImageFromAsset(
    MapLibreMapController controller, String name, String assetName) async {
  final bytes = await rootBundle.load(assetName);
  final list = bytes.buffer.asUint8List();
  return controller.addImage(name, list);
}

DateTime? avgTime(DateTime? startTime, DateTime? endTime) {
  if (startTime != null && endTime != null) {
    int inc =
        ((endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch) /
                2)
            .round();
    print('INCREMENT  ................. $inc');

    return DateTime.fromMillisecondsSinceEpoch(
        startTime.millisecondsSinceEpoch + inc,
        isUtc: true);
  }
  return null;
}

LatLng halfSegmentCoord(LatLng first, LatLng last) {
  return LatLng((first.latitude + last.latitude) / 2,
      (first.longitude + last.longitude) / 2);
}

Wpt halfSegmentWpt(Wpt first, Wpt last) {
  Wpt half = cloneWpt(first);

  half.ele = (first.ele! + last.ele!) / 2;
  half.lat = (first.lat! + last.lat!) / 2;
  half.lon = (first.lon! + last.lon!) / 2;
  half.time = avgTime(first.time, last.time);

  return half;
}

Wpt cloneWpt(Wpt wpt) {
  return Wpt(
      lat: wpt.lat,
      lon: wpt.lon,
      ele: wpt.ele,
      time: wpt.time,
      magvar: wpt.magvar,
      geoidheight: wpt.geoidheight,
      name: wpt.name,
      cmt: wpt.cmt,
      desc: wpt.desc,
      src: wpt.src,
      links: wpt.links,
      sym: wpt.sym,
      type: wpt.type,
      fix: wpt.fix,
      sat: wpt.sat,
      hdop: wpt.hdop,
      vdop: wpt.vdop,
      pdop: wpt.pdop,
      ageofdgpsdata: wpt.ageofdgpsdata,
      dgpsid: wpt.dgpsid,
      extensions: wpt.extensions);
}

setTimeout(callback, time) {
  Duration timeDelay = Duration(milliseconds: time);
  return Timer(timeDelay, callback);
}

void showSnackBar(context, String txt) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 20),
          Expanded(
              child: Text(
            txt,
            style: TextStyle(color: Theme.of(context).primaryColor),
          )),
        ],
      ),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      duration: const Duration(milliseconds: 3000),
    ),
  );
}
