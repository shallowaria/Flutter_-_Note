import 'package:flutter/material.dart';

class PaddingTestRoute extends StatelessWidget {
  const PaddingTestRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text('Hello world'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('I am Jack'),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text('Your friend'),
          ),
        ],
      ),
    );
  }
}
