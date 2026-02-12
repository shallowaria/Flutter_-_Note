import 'package:flutter/material.dart';

class EchoRoute extends StatelessWidget {
  const EchoRoute({super.key});

  @override
  Widget build(BuildContext context) {
    //获取路由参数
    var args = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text('Echo Route')),
      body: Center(child: Text('This is Echo route\'s $args')),
    );
  }
}
