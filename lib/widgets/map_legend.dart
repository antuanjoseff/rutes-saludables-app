import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/bluedUdG.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  static TextStyle defaultStyle = TextStyle(fontSize: 15);

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.all(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/images/salut_no_text.svg',
              width: 50,
              height: 50,
              colorFilter: ColorFilter.mode(blueUdG, BlendMode.srcIn),
            ),
            const SizedBox(
              width: 5,
            ),
            Text('Exercici recomanat de l\itinerari', style: defaultStyle)
          ],
        ),
        Padding(padding: EdgeInsets.all(1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset('assets/images/poi.svg',
                width: 50,
                height: 50,
                colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn)),
            const SizedBox(
              width: 5,
            ),
            Text('Punt d\interès proper', style: defaultStyle)
          ],
        ),
        Padding(padding: EdgeInsets.all(1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset('assets/images/legend_position.svg',
                width: 50,
                height: 50,
                colorFilter:
                    const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
            const SizedBox(
              width: 5,
            ),
            Text('La teva posició', style: defaultStyle)
          ],
        ),
      ],
    );
  }
}
