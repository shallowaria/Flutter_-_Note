import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文本及样式')),
      body: ListView(
        children: [
          Text("Hello world", textAlign: TextAlign.left),

          Text(
            "Hello world! I'm Jack. " * 4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Text("Hello world", textScaler: TextScaler.linear(1.5)),

          SizedBox(height: 10),

          Text(
            "Hello world",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18.0,
              height: 1.2,
              fontFamily: "Courier",
              // 比起backgroundColor改更多
              // var paint = Paint() paint.color = Colors.yellow
              background: Paint()..color = Colors.yellow,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
            ),
          ),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "Home: "),
                TextSpan(
                  text: "https://flutterchina.club",
                  style: TextStyle(color: Colors.blue),
                  // recognizer: _tapRecognizer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
