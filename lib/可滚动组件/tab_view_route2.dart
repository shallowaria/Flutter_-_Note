//如果需要 TabBar 和 TabBarView 联动，通常会创建一个 DefaultTabController 作为它们共同的父级组件，这样它们在执行时就会从组件树向上查找，都会使用我们指定的这个 DefaultTabController。

//无需去手动管理 Controller 的生命周期，也不需要提供 SingleTickerProviderStateMixin，同时也没有其他的状态需要管理，也就不需要用 StatefulWidget 了
import 'package:flutter/material.dart';

class TabViewRoute2 extends StatelessWidget {
  const TabViewRoute2({super.key});

  @override
  Widget build(BuildContext context) {
    List tabs = ["新闻2", "历史2", "图片2"];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("App Name"),
          bottom: TabBar(tabs: tabs.map((e) => Tab(text: e)).toList()),
        ),
        body: TabBarView(
          //构建
          children: tabs.map((e) {
            return Container(
              alignment: Alignment.center,
              child: Text(e, textScaler: TextScaler.linear(5)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
