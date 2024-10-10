import 'package:flutter/material.dart';
import 'home.dart';
import '../widgets/NextPageAnimation.dart';

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
                    child: const DefaultTextStyle(
                  style: TextStyle(color: Colors.red),
                  child: const Column(
                    children: [
                      const Text(
                          "Benvingut/benvinguda als Itineraris Saludables de la UdG! Hem dissenyat unes rutes a cada un dels campus, especialment per a la comunitat universitària. Hi ha dos tipus d'itineraris, depenent del temps que vulguis invertir per desconnectar de la jornada laboral i acadèmica."),
                      const Padding(padding: EdgeInsets.all(8)),
                      const Text(
                          "Pots triar un recorregut curt (d'uns 20 minuts), per aprofitar els moments de descans, o un recorregut més llarg (d'uns 45 minuts). Dins dels itineraris, et recomanem uns exercicis físics (icones roses) amb tres nivells d'intensitat i una sèrie de punts d'interès (icones verdes) per conèixer a fons els serveis del teu campus"),
                      const Padding(padding: EdgeInsets.all(8)),
                      const Text("Al mapa trobaràs aquestes icones: ")
                    ],
                  ),
                )),
              ),
              NextPageAnimation(
                nextPage: HomePage(),
              )
            ],
          ),
        ));
  }
}
