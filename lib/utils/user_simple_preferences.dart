import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSimplePreferences {
  static late SharedPreferences _preferences;

  static const _gpsEnabled = 'gpsEnabled';
  static const _hasPermission = 'hasPermission';
  static const _trackLength = 'trackLength';
  static const _trackTime = 'trackTime';
  static const _trackAltitude = 'trackAltitude';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  // GETTERS
  static bool getGpsEnabled() {
    final gpsEnabled = _preferences.getBool(_gpsEnabled);
    return gpsEnabled ?? false;
  }

  static bool getHasPermission() {
    final hasPermission = _preferences.getBool(_hasPermission);
    return hasPermission ?? false;
  }

  static String getTrackLength() {
    final trackLength = _preferences.getString(_trackLength);
    return trackLength ?? '0';
  }

  static String getTrackTime() {
    final trackTime = _preferences.getString(_trackTime);
    return trackTime ?? '';
  }

  static String getTrackAltitude() {
    final trackAltitude = _preferences.getString(_trackAltitude);
    return trackAltitude ?? '';
  }

  // SETTERS
  static Future setGpsEnabled(bool enabled) async =>
      await _preferences.setBool(_gpsEnabled, enabled);

  static Future setHasPermission(bool permission) async =>
      await _preferences.setBool(_hasPermission, permission);

  static Future setTrackLength(String length) async =>
      await _preferences.setString(_trackLength, length);

  static Future setTrackTime(String duration) async =>
      await _preferences.setString(_trackTime, duration);

  static Future setTrackAltitude(String altitude) async =>
      await _preferences.setString(_trackAltitude, altitude);
}
