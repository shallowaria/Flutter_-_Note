import 'package:flutter/material.dart';

class SingleChildScrollViewTestRoute extends StatelessWidget {
  const SingleChildScrollViewTestRoute({super.key});

  @override
  Widget build(BuildContext context) {
    String str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    return Scrollbar(
      // 显示进度条
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            // 动态创建一个List<Widget>
            children: str
                .split("")
                .map((c) => Text(c, textScaler: TextScaler.linear(2.0)))
                .toList(),
          ),
        ),
      ),
    );
  }
}
