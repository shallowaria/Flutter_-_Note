import 'package:flutter/material.dart';
import 'package:flutter_fight/%E8%B7%AF%E7%94%B1/tip_route.dart';

class RouterTestRoute extends StatelessWidget {
  const RouterTestRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return TipRoute(text: '我是提示xxxx');
              },
            ),
          );
          print('路由返回值: $result');
        },
        child: Text('打开提示页'),
      ),
    );
  }
}
