import 'package:flutter/material.dart';
import 'package:rutes_saludables/models/data.dart';
import '../widgets/campusRoutes.dart';

class ExpansionPanelListExampleApp extends StatelessWidget {
  final List itineraries;
  const ExpansionPanelListExampleApp({
    super.key,
    required this.itineraries,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routes')),
      body: ExpansionPanelListExample(itineraries: itineraries),
    );
  }
}

class ExpansionPanelListExample extends StatefulWidget {
  final List itineraries;
  const ExpansionPanelListExample({
    super.key,
    required this.itineraries,
  });

  @override
  State<ExpansionPanelListExample> createState() =>
      _ExpansionPanelListExampleState();
}

class _ExpansionPanelListExampleState extends State<ExpansionPanelListExample> {
  late List _data;

  @override
  void initState() {
    widget.itineraries.sort((a, b) => a.campus.compareTo(b.campus));
    _data = organizeRoutes(widget.itineraries);
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
          body: CampusRoutes(campusRoutes: item['itineraries']),
          isExpanded: item['isExpanded'],
        );
      }).toList(),
    );
  }
}

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
