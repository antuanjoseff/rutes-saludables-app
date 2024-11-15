import 'package:flutter/material.dart';
import 'package:rutes_saludables/models/data.dart';
import 'package:rutes_saludables/pages/map.dart';

class CampusRoutes extends StatefulWidget {
  final List campusRoutes;

  const CampusRoutes({
    super.key,
    required this.campusRoutes,
  });

  @override
  State<CampusRoutes> createState() => _CampusRoutesState();
}

class _CampusRoutesState extends State<CampusRoutes> {
  late List _data;
  TextStyle itineraryStyleText = const TextStyle(color: Colors.white);

  @override
  void initState() {
    _data = widget.campusRoutes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: _data.map<Padding>((item) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: blueUdG,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.title, style: itineraryStyleText),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.directions_walk, color: Colors.white),
                    const SizedBox(
                      width: 5,
                    ),
                    Text('${item.distance}km', style: itineraryStyleText),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.watch_later_outlined,
                          color: Colors.white),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${item.duration}m', style: itineraryStyleText),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(itinerary: item),
                          ));
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(
                        Icons.play_arrow_sharp,
                      ),
                    ),
                  )
                ]),
          ),
        ),
      );
    }).toList());
  }
}
