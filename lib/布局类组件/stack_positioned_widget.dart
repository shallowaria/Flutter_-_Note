import 'package:flutter/material.dart';

class StackPositionedWidget extends StatelessWidget {
  const StackPositionedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
      fit: StackFit.expand, //未定位widget占满Stack整个空间
      children: [
        Positioned(left: 18.0, child: Text('I\'m Jack')),
        Container(
          child: Text('Hello world,', style: TextStyle(color: Colors.white)),
        ),
        Positioned(top: 18.0, child: Text('Your friend')),
      ],
    );
  }
}
