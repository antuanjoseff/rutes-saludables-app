import 'package:flutter/material.dart';
import 'package:rutes_saludables/models/data.dart';
import '../widgets/campusRoutes.dart';
import 'package:accordion/accordion.dart';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';

import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackList extends StatefulWidget //__
{
  static const headerStyle = TextStyle(
      color: Color(0xff000000), fontSize: 18, fontWeight: FontWeight.bold);
  // static const contentStyleHeader = TextStyle(
  //     color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  // static const contentStyle = TextStyle(
  //     color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);

  final List itineraries;
  const TrackList({
    super.key,
    required this.itineraries,
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  late List _data;
  void initState() {
    widget.itineraries.sort((a, b) => a.campus.compareTo(b.campus));
    _data = organizeRoutes(widget.itineraries);
    super.initState();
  }

  @override
  build(context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.healthyTracks),
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Accordion(
          maxOpenSections: 1,
          // headerBorderColor: blueUdG,
          headerBackgroundColor: Colors.blueGrey[100],
          // headerBorderColorOpened: Colors.transparent,
          // headerBorderWidth: 1,
          // headerBackgroundColorOpened: Colors.green,
          contentBackgroundColor: Colors.white,
          contentBorderColor: blueUdG,
          contentBorderWidth: 0,
          contentHorizontalPadding: 20,
          scaleWhenAnimating: true,
          openAndCloseAnimation: true,
          rightIcon: const CircleAvatar(
            backgroundColor: blueUdG,
            radius: 15,
            child: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Colors.white,
            ),
          ),
          headerPadding:
              const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
          sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
          sectionClosingHapticFeedback: SectionHapticFeedback.light,

          children: _data.map<AccordionSection>((item) {
            return AccordionSection(
              header: Text(item['campus'], style: TrackList.headerStyle),
              content: CampusRoutes(campusRoutes: item['itineraries']),
              isOpen: item['isExpanded'],
              contentHorizontalPadding: 0,
            );
          }).toList(),
        ),
      );
} //__

List organizeRoutes(itineraries) {
  var campuses = [
    {"campus": itineraries[0].campus, "isExpanded": false, "itineraries": []}
  ];

  for (var i = 0; i < itineraries.length; i++) {
    var r = itineraries[i];
    int idx = campuses.indexWhere((item) {
      return item['campus'] == r.campus;
    });
    if (idx == -1) {
      campuses.add({
        "campus": r.campus,
        "isExpanded": false,
        "itineraries": [r]
      });
    } else {
      campuses[idx]['itineraries'].add(r);
    }
  }

  return campuses;
}
