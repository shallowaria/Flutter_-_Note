import 'package:flutter/material.dart';

class ClipTestWidget extends StatelessWidget {
  const ClipTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Widget avatar = Image.asset('images/avatar.png', width: 60.0);

    return Center(
      child: Column(
        children: [
          avatar,
          ClipOval(child: avatar),
          ClipRRect(borderRadius: BorderRadius.circular(5.0), child: avatar),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                widthFactor: .5,
                child: avatar,
              ),
              Text('你好世界', style: TextStyle(color: Colors.green)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  widthFactor: .5,
                  child: avatar,
                ),
              ),
              Text('你好世界', style: TextStyle(color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}
