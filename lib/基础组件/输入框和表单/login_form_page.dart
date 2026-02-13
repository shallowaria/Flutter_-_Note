import 'package:flutter/material.dart';

class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});

  @override
  LoginFormPageState createState() => LoginFormPageState();
}

class LoginFormPageState extends State<LoginFormPage> {
  // final TextEditingController _unameController = TextEditingController();
  final TextEditingController _selectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectionController.text = "hello world!";
    _selectionController.selection = TextSelection(
      baseOffset: 2,
      extentOffset: _selectionController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hintColor: Colors.grey[200], //定义下划线颜色
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey), //定义label字体样式
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0), //定义提示文本样式
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('输入框和表单')),
        body: Column(
          children: <Widget>[
            TextField(
              autofocus: true,
              controller: _selectionController,
              decoration: InputDecoration(
                labelText: '用户名',
                hintText: '用户名或邮箱',
                prefixIcon: Icon(Icons.person),
                border: InputBorder.none,
                // 未获得焦点下划线设为灰色
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                //获得焦点下划线设为蓝色
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '您的登陆密码',
                prefixIcon: Icon(Icons.lock),
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
