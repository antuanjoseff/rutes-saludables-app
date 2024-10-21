import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class PoiDetails extends StatefulWidget {
  const PoiDetails({super.key});

  @override
  State<PoiDetails> createState() => _PoiDetailsState();
}

class _PoiDetailsState extends State<PoiDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Punt d'interès")),
        body: SingleChildScrollView(child: Html(data: '<u>hola mundo</u>')));
  }
}
