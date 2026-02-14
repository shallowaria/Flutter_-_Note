import 'package:flutter/material.dart';

Widget buildTwoSliverList() {
  var listView = SliverFixedExtentList(
    delegate: SliverChildBuilderDelegate(
      (_, index) => ListTile(title: Text('$index')),
      childCount: 10,
    ),
    itemExtent: 56,
  );

  return CustomScrollView(slivers: [listView, listView]);
}
