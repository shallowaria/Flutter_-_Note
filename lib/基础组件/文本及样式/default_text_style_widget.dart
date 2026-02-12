import 'package:flutter/material.dart';

class DefaultTextStyleWidget extends StatelessWidget {
  const DefaultTextStyleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文本默认样式')),
      body: DefaultTextStyle(
        //1.设置文本默认样式
        style: TextStyle(color: Colors.red, fontSize: 20.0),
        textAlign: TextAlign.start,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("hello world"),
            Text("I am Jack"),
            Text(
              "I am Jack",
              style: TextStyle(
                inherit: false, //2.不继承默认样式
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
