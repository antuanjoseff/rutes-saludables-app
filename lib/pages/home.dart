import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rutes_saludables/pages/legend.dart';
import '../widgets/NextPageAnimation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.udgHealth)),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/home.png"), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(10)),
            const Center(
                child: Image(
              color: Colors.white,
              image: AssetImage('assets/images/salut.png'),
              height: 100,
            )),
            const Padding(padding: EdgeInsets.all(20)),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.healthyTracks,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(15)),
                  const NextPageAnimation(
                    nextPage: LegendPage(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
