import 'package:flutter/material.dart';
import 'home.dart';
import 'list.dart';
import 'expandable.dart';
import '../widgets/NextPageAnimation.dart';
import '../widgets/map_legend.dart';
import '../models/data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LegendPage extends StatefulWidget {
  const LegendPage({super.key});

  @override
  State<LegendPage> createState() => _LegendPageState();
}

class _LegendPageState extends State<LegendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(AppLocalizations.of(context)!.mapLegendTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                    child: SingleChildScrollView(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: blueUdG,
                      fontSize: 15,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.wellcomePart1),
                        const Padding(padding: EdgeInsets.all(10)),
                        Text(AppLocalizations.of(context)!.wellcomePart2),
                        const Padding(padding: EdgeInsets.all(10)),
                        Text(AppLocalizations.of(context)!.mapIconsText),
                        MapLegend()
                      ],
                    ),
                  ),
                )),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              NextPageAnimation(
                // nextPage: ListPage(),
                nextPage:
                    // ExpansionPanelListExampleApp(itineraries: itineraries),
                    AccordionPage(itineraries: itineraries),
              )
            ],
          ),
        ));
  }
}
