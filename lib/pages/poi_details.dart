import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class PoiDetails extends StatefulWidget {
  final String title;
  final String content;
  final String? moreInfo;

  PoiDetails({
    super.key,
    required this.title,
    required this.content,
    this.moreInfo,
  });

  @override
  State<PoiDetails> createState() => _PoiDetailsState();
}

class _PoiDetailsState extends State<PoiDetails> {
  late String _title;
  late String _content;
  late String? _moreInfo;

  @override
  void initState() {
    _content = widget.content;
    _title = widget.title;
    _moreInfo = widget.moreInfo;
    debugPrint(_content);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _imgWidth = MediaQuery.of(context).size.width - 14;
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
          backgroundColor: Color(0xff3242a0),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (_moreInfo != null)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // ElevatedButton(
                        //   style: ElevatedButton.styleFrom(
                        //       backgroundColor: Color(0xff6a1a32),
                        //       foregroundColor: Colors.white,
                        //       padding: EdgeInsets.symmetric(
                        //           horizontal: 10, vertical: 0),
                        //       textStyle: TextStyle(
                        //           fontWeight: FontWeight.bold, fontSize: 15)),
                        //   onPressed: () => launchUrl(Uri.parse(_moreInfo!)),
                        //   child: const Text('+ INFORMACIÓ'),
                        // ),
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 0, right: 0, bottom: 10),
                          child: Text('+ '),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 15, bottom: 10),
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse(_moreInfo!));
                            },
                            child: const Text('Informació',
                                style: TextStyle(
                                    color: Color(0xff6a1a32),
                                    fontSize: 20,
                                    decoration: TextDecoration.underline)),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              HtmlWidget(_content),
            ],
          ),
        ));
  }
}
