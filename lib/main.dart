import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'package:location/location.dart';
import 'utils/user_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';

void main() async {
  // await _checkPermission();
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  DisableBatteryOptimization.isBatteryOptimizationDisabled
      .then((isBatteryOptimizationDisabled) async {
    await handleBatteryOptimization(isBatteryOptimizationDisabled);
  });
  // await _checkPermission();
  runApp(const MyApp());
}

Future<void> handleBatteryOptimization(
    bool? isBatteryOptimizationDisabled) async {
  isBatteryOptimizationDisabled ??= false;
  if (!isBatteryOptimizationDisabled) {
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  }
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ca'), // catalan
        Locale('es'), // Spanish
        Locale('en'), // English
      ],
      debugShowCheckedModeBanner: false,
      title: 'UdG Salut',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
