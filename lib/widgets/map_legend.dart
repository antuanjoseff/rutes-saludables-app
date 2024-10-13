import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            ),
            const SizedBox(
              width: 5,
            ),
            Text('Exercici recomanat de l\itinerari', style: defaultStyle)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/images/poi.svg',
              width: 50,
              height: 50,
            ),
            SizedBox(
              width: 5,
            ),
            Text('Punt d\interès proper', style: defaultStyle)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.abc),
            SizedBox(
              width: 30,
            ),
            Text('Text legend', style: defaultStyle)
          ],
        ),
        Padding(padding: EdgeInsets.all(10)),
      ],
    );
  }
}
