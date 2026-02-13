import 'package:flutter/material.dart';

class RawMaterialButton extends StatelessWidget {
  const RawMaterialButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: () {}, child: Text('normal')),
        TextButton(onPressed: () {}, child: Text('normal')),
        OutlinedButton(onPressed: () {}, child: Text('normal')),
        IconButton(onPressed: () {}, icon: Icon(Icons.thumb_up)),
        ElevatedButton.icon(
          icon: Icon(Icons.send),
          onPressed: () {},
          label: Text('发送'),
        ),
        TextButton.icon(
          icon: Icon(Icons.add),
          onPressed: () {},
          label: Text('添加'),
        ),
        OutlinedButton.icon(
          icon: Icon(Icons.info),
          onPressed: () {},
          label: Text('详情'),
        ),
      ],
    );
  }
}
