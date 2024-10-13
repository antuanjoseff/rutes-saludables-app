import 'package:flutter/material.dart';
import 'home.dart';
import 'list.dart';
import 'expandable.dart';
import '../widgets/NextPageAnimation.dart';
import '../widgets/map_legend.dart';
import '../models/data.dart';

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
          title: const Text('Llegenda del mapa'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                    child: SingleChildScrollView(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: blueUdG,
                      fontSize: 23,
                    ),
                    child: const Column(
                      children: [
                        const Text(
                          "Benvingut/benvinguda als Itineraris Saludables de la UdG! Hem dissenyat unes rutes a cada un dels campus, especialment per a la comunitat universitària. Hi ha dos tipus d'itineraris, depenent del temps que vulguis invertir per desconnectar de la jornada laboral i acadèmica.",
                        ),
                        const Padding(padding: EdgeInsets.all(18)),
                        const Text(
                            "Pots triar un recorregut curt (d'uns 20 minuts), per aprofitar els moments de descans, o un recorregut més llarg (d'uns 45 minuts). Dins dels itineraris, et recomanem uns exercicis físics (icones roses) amb tres nivells d'intensitat i una sèrie de punts d'interès (icones verdes) per conèixer a fons els serveis del teu campus"),
                        const Padding(padding: EdgeInsets.all(18)),
                        const Text("Al mapa trobaràs aquestes icones: "),
                        MapLegend()
                      ],
                    ),
                  ),
                )),
              ),
              Padding(padding: EdgeInsets.all(20)),
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
