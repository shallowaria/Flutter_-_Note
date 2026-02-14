import 'package:flutter/material.dart';

class GridDelegateRoute extends StatefulWidget {
  const GridDelegateRoute({super.key});

  @override
  GridDelegateRouteState createState() => GridDelegateRouteState();
}

class GridDelegateRouteState extends State<GridDelegateRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('纵轴子元素固定长度/固定数量GridView')),
      body: ListView(
        children: [
          GridView(
            shrinkWrap: true, // 核心：让 GridView 宽度包裹内容
            physics: NeverScrollableScrollPhysics(), // 核心：禁用 GridView 自身的滚动
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
            children: [
              Icon(Icons.ac_unit),
              Icon(Icons.airport_shuttle),
              Icon(Icons.all_inclusive),
              Icon(Icons.beach_access),
              Icon(Icons.cake),
              Icon(Icons.free_breakfast),
            ],
          ),
          GridView(
            shrinkWrap: true, // 核心：让 GridView 宽度包裹内容
            physics: NeverScrollableScrollPhysics(), // 核心：禁用 GridView 自身的滚动
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120.0,
              childAspectRatio: 2.0, //宽高比为2
            ),
            children: <Widget>[
              Icon(Icons.ac_unit),
              Icon(Icons.airport_shuttle),
              Icon(Icons.all_inclusive),
              Icon(Icons.beach_access),
              Icon(Icons.cake),
              Icon(Icons.free_breakfast),
            ],
          ),
          GridView.count(
            shrinkWrap: true, // 核心：让 GridView 宽度包裹内容
            physics: NeverScrollableScrollPhysics(), // 核心：禁用 GridView 自身的滚动
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            children: <Widget>[
              Icon(Icons.ac_unit),
              Icon(Icons.airport_shuttle),
              Icon(Icons.all_inclusive),
              Icon(Icons.beach_access),
              Icon(Icons.cake),
              Icon(Icons.free_breakfast),
            ],
          ),
          GridView.extent(
            shrinkWrap: true, // 核心：让 GridView 宽度包裹内容
            physics: NeverScrollableScrollPhysics(), // 核心：禁用 GridView 自身的滚动
            maxCrossAxisExtent: 120.0,
            childAspectRatio: 2.0,
            children: <Widget>[
              Icon(Icons.ac_unit),
              Icon(Icons.airport_shuttle),
              Icon(Icons.all_inclusive),
              Icon(Icons.beach_access),
              Icon(Icons.cake),
              Icon(Icons.free_breakfast),
            ],
          ),
        ],
      ),
    );
  }
}
