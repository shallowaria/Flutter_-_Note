import 'package:flutter/material.dart';

class SwitchAndCheckboxTestRoute extends StatefulWidget {
  const SwitchAndCheckboxTestRoute({super.key});

  @override
  SwitchAndCheckboxTestRouteState createState() =>
      SwitchAndCheckboxTestRouteState();
}

class SwitchAndCheckboxTestRouteState
    extends State<SwitchAndCheckboxTestRoute> {
  bool _switchSelected = true; //维护单选开关状态
  bool? _checkboxSelected = true; //维护复选框状态

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Switch(
          value: _switchSelected,
          activeThumbColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              _switchSelected = value;
            });
          },
        ),
        Checkbox(
          tristate: true,
          value: _checkboxSelected,
          activeColor: Colors.red,
          onChanged: (bool? value) {
            setState(() {
              _checkboxSelected = value;
            });
          },
        ),
      ],
    );
  }
}
