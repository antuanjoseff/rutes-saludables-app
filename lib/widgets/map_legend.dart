import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/bluedUdG.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  static TextStyle defaultStyle = const TextStyle(fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.all(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Image(
              image: AssetImage('assets/images/marker_salut.png'),
              width: 25,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(AppLocalizations.of(context)!.recommendedExercises,
                style: defaultStyle)
          ],
        ),
        const Padding(padding: EdgeInsets.all(1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Image(
              image: AssetImage('assets/images/marker_poi.png'),
              width: 25,
            ),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.nearbyPois, style: defaultStyle)
          ],
        ),
        const Padding(padding: EdgeInsets.all(1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset('assets/images/legend_position.svg',
                width: 25,
                height: 25,
                colorFilter:
                    const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
            const SizedBox(
              width: 10,
            ),
            Text(AppLocalizations.of(context)!.yourLocation,
                style: defaultStyle)
          ],
        ),
      ],
    );
  }
}
