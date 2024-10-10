import 'package:flutter/material.dart';
import '../widgets/campusRoutes.dart';

class ExpansionPanelListExampleApp extends StatelessWidget {
  final List routes;
  const ExpansionPanelListExampleApp({
    super.key,
    required this.routes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routes')),
      body: ExpansionPanelListExample(routes: routes),
    );
  }
}

class ExpansionPanelListExample extends StatefulWidget {
  final List routes;
  const ExpansionPanelListExample({
    super.key,
    required this.routes,
  });

  @override
  State<ExpansionPanelListExample> createState() =>
      _ExpansionPanelListExampleState();
}

class _ExpansionPanelListExampleState extends State<ExpansionPanelListExample> {
  late List _data;

  @override
  void initState() {
    widget.routes.sort((a, b) => a.campus.compareTo(b.campus));
    _data = organizeRoutes(widget.routes);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index]['isExpanded'] = isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item['campus']),
            );
          },
          canTapOnHeader: true,
          body: CampusRoutes(campusRoutes: item['routes']),
          // ListTile(
          //   title: Text(item['routes'].length.toString()),
          //   subtitle:
          //       const Text('To delete this panel, tap the trash can icon'),
          //   trailing: const Icon(Icons.delete),
          //   onTap: () {
          //     setState(() {});
          //   }),
          isExpanded: item['isExpanded'],
        );
      }).toList(),
    );
  }
}

List organizeRoutes(routes) {
  var campuses = [
    {"campus": routes[0].campus, "isExpanded": false, "routes": []}
  ];

  for (var i = 0; i < routes.length; i++) {
    var r = routes[i];
    int idx = campuses.indexWhere((item) {
      return item['campus'] == r.campus;
    });
    if (idx == -1) {
      campuses.add({
        "campus": r.campus,
        "isExpanded": false,
        "routes": [r]
      });
    } else {
      campuses[idx]['routes'].add(r);
    }
  }
  return campuses;
}
