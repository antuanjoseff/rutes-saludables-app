import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'package:location/location.dart';

void main() async {
  runApp(const MyApp());
  await _checkPermission();
}

Future<void> _checkPermission() async {
  final location = Location();
  final hasPermissions = await location.hasPermission();
  print('*' * 100);
  if (hasPermissions != PermissionStatus.granted) {
    await location.requestPermission();
    print(location.hasPermission() == PermissionStatus.granted);
  } else {
    print(location.hasPermission() == PermissionStatus.granted);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
