import 'package:flutter/material.dart';

class ProgressRoute extends StatefulWidget {
  const ProgressRoute({super.key});

  @override
  ProgressRouteState createState() => ProgressRouteState();
}

// with混入 允许类在不使用继承的情况下，复用另一个类（或多个类）的代码。dart是单继承语言，一个类只能有一个父类
class ProgressRouteState extends State<ProgressRoute>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    // 动画执行时间3秒
    _animationController = AnimationController(
      vsync: this, //注意State类需要混入SingleTickerProviderStateMixin（提供动画帧计时/触发器）
      duration: Duration(seconds: 3),
    );
    _animationController.forward();
    _animationController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: ColorTween(
                begin: Colors.grey,
                end: Colors.blue,
              ).animate(_animationController),
              value: _animationController.value,
            ),
          ),
        ],
      ),
    );
  }
}
