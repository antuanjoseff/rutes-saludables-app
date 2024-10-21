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
            const Image(
              image: AssetImage('assets/images/marker_salut.png'),
              width: 25,
            ),
            const SizedBox(
              width: 10,
            ),
            Text('Exercici recomanat de l\itinerari', style: defaultStyle)
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
            Text("Punt d'interès proper", style: defaultStyle)
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
            Text('La teva posició', style: defaultStyle)
          ],
        ),
      ],
    );
  }
}
