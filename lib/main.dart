import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'package:location/location.dart';
import './models/gps.dart';
import 'utils/user_simple_preferences.dart';

void main() async {
  // await _checkPermission();
  // WidgetsFlutterBinding.ensureInitialized();
  // await UserSimplePreferences.init();
  // await _checkPermission();
  runApp(const MyApp());
}

Future<void> _checkPermission() async {
  bool? hasPermission = false;
  final gps = new Gps();

  bool enabled = await gps.checkService();
  if (enabled) {
    hasPermission = await gps.checkPermission();
    hasPermission = await gps.listenOnBackground(printLocation) ?? false;

    // if (hasPermission!) {
    //   gps.listenOnBackground(printLocation);
    // }
  }
  print('................$hasPermission');
  await UserSimplePreferences.setGpsEnabled(enabled);
  await UserSimplePreferences.setHasPermission(hasPermission!);
  return;
}

void printLocation(LocationData loc) {
  debugPrint('${loc.latitude}                    ${loc.longitude}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
