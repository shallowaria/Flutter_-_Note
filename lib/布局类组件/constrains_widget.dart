import 'package:flutter/material.dart';

Widget redBox = DecoratedBox(decoration: BoxDecoration(color: Colors.red));

class ConstrainsWidget extends StatelessWidget {
  const ConstrainsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //BoxConstraints.tightFor(width: 80.0,height: 80.0),等价于👇
        // BoxConstraints(minHeight: 80.0,maxHeight: 80.0,minWidth: 80.0,maxWidth: 80.0)
        SizedBox(width: 80.0, height: 80.0, child: redBox),

        // SizeBox 是 ConstrainedBox的定制，等价于👇
        //   ConstrainedBox(
        //   constraints: BoxConstraints.tightFor(width: 80.0,    height: 80.0),
        //   child: redBox,
        // )
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: double.infinity,
            minHeight: 50.0,
          ),
          child: Container(height: 5, child: redBox),
        ),

        // UnconstrainedBox
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 60.0, minHeight: 100.0),
          child: UnconstrainedBox(
            //“去除”父级限制，但上方仍然有80的空白空间
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 90.0, minHeight: 20.0),
              child: redBox,
            ),
          ),
        ),
      ],
    );
  }
}
