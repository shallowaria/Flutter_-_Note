import 'package:flutter/material.dart';

class PictureIcon extends StatelessWidget {
  const PictureIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 本地
        Image(image: AssetImage('images/avatar.png'), width: 100.0),
        Image.asset('images/avatar.png', width: 100),
        // 网络
        Image(
          image: NetworkImage(
            "https://avatars2.githubusercontent.com/u/20411648?s=460&v=4",
          ),
          width: 100.0,
        ),
        Image.network(
          'https://avatars2.githubusercontent.com/u/20411648?s=460&v=4',
          width: 100.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.accessible, color: Colors.green),
            Icon(Icons.error, color: Colors.green),
            Icon(Icons.fingerprint, color: Colors.green),
          ],
        ),
      ],
    );
  }
}
