import 'package:flutter/material.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/page_test_widget.dart';

class PageViewTestWidget extends StatefulWidget {
  const PageViewTestWidget({super.key});

  @override
  PageViewTestWidgetState createState() => PageViewTestWidgetState();
}

class PageViewTestWidgetState extends State<PageViewTestWidget> {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    // 生成 6 个 Tab 页
    for (int i = 0; i < 6; ++i) {
      children.add(PageTestWidget(text: '${i + 1}'));
    }

    return PageView(children: children);
  }
}
