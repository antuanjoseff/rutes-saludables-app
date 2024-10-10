import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/data.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List data = [];
  @override
  void initState() {
    routes.sort((a, b) => a.campus.compareTo(b.campus));
    data = sortRoutes(routes);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Llistat de rutes'),
        ),
        body: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: data.map((item) => Text(item['campus'])).toList(),
          ),
        ));
  }
}

List sortRoutes(routes) {
  var campuses = [
    {"campus": routes[0].campus, "routes": []}
  ];

  for (var i = 0; i < routes.length; i++) {
    var r = routes[i];
    int idx = campuses.indexWhere((item) {
      return item['campus'] == r.campus;
    });
    if (idx == -1) {
      campuses.add({
        "campus": r.campus,
        "routes": [r]
      });
    } else {
      campuses[idx]['routes'].add(r);
    }
  }
  return campuses;
}
