import 'package:location/location.dart';

// Request a location

class Gps {
  Gps();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location location = Location();

  Future<bool> checkService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> requestPermission() async {
    print('INSIDE REQUESTPERMISSION');
    _permissionGranted = await location.hasPermission();
    print('PERMISSION GRANGTED $_permissionGranted');
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  listenOnBackground(Function managePosition) async {
    location.enableBackgroundMode(enable: true);

    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );

    location.onLocationChanged.listen((LocationData currentLocation) {
      managePosition(currentLocation);
    });
  }

  enableBackground(String notificationTitle, String notificationContent) {
    location.enableBackgroundMode(enable: true);

    location.changeNotificationOptions(
      title: notificationTitle,
      subtitle: notificationContent,
    );
  }

  changeSettings(
      LocationAccuracy accuracy, int? interval, double? distanceFilter) {
    location.changeSettings(
      interval: interval ?? 1000,
      distanceFilter: distanceFilter ?? 0,
      accuracy: accuracy,
    );
  }
}
