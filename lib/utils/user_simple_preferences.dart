import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSimplePreferences {
  static late SharedPreferences _preferences;

  static const _gpsEnabled = 'gpsEnabled';
  static const _hasPermission = 'hasPermission';
  static const _trackLength = 'trackLength';
  static const _trackTime = 'trackTime';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  // GETTERS
  static bool getGpsEnabled() {
    final gpsEnabled = _preferences.getBool(_gpsEnabled);
    return gpsEnabled == null ? false : gpsEnabled;
  }

  static bool getHasPermission() {
    final hasPermission = _preferences.getBool(_hasPermission);
    return hasPermission == null ? false : hasPermission;
  }

  static String getTrackLength() {
    final trackLength = _preferences.getString(_trackLength);
    return trackLength == null ? '0' : trackLength;
  }

  static String getTrackTime() {
    final trackTime = _preferences.getString(_trackTime);
    return trackTime == null ? '' : trackTime;
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
}
