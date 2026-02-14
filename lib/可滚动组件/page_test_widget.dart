import 'package:flutter/material.dart';

class PageTestWidget extends StatefulWidget {
  const PageTestWidget({super.key, required this.text});

  final String text;

  @override
  PageTestWidgetState createState() => PageTestWidgetState();
}

class PageTestWidgetState extends State<PageTestWidget> {
  @override
  Widget build(BuildContext context) {
    print('build ${widget.text}');
    return Center(
      child: Text('build ${widget.text}', textScaler: TextScaler.linear(5)),
    );
  }
}
