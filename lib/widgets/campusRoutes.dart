import 'package:flutter/material.dart';

class CampusRoutes extends StatefulWidget {
  final List campusRoutes;

  CampusRoutes({
    super.key,
    required this.campusRoutes,
  });

  @override
  State<CampusRoutes> createState() => _CampusRoutesState();
}

class _CampusRoutesState extends State<CampusRoutes> {
  late List _data;

  @override
  void initState() {
    _data = widget.campusRoutes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: _data.map<ListTile>((item) {
      return ListTile(
        leading: Icon(Icons.rocket),
        title: Text(item.title),
      );
    }).toList());
  }
}
