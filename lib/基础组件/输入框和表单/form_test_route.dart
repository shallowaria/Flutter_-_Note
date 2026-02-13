import 'package:flutter/material.dart';

class FormTestRoute extends StatefulWidget {
  const FormTestRoute({super.key});

  @override
  FormTestRouteState createState() => FormTestRouteState();
}

class FormTestRouteState extends State<FormTestRoute> {
  TextEditingController _unameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  final GlobalKey _formKey =
      GlobalKey<FormState>(); //跨越组件层级，直接抓取到 Form 组件对应的“状态对象（State）”

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, //设置globalKey，用于后面获取FormState
      child: Column(
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: _unameController,
            decoration: InputDecoration(
              labelText: '用户名',
              hintText: '用户名或邮箱',
              icon: Icon(Icons.person),
            ),
            // 校验用户名
            validator: (value) {
              return value!.trim().isNotEmpty ? null : '用户名不能为空';
            },
          ),
          TextFormField(
            controller: _pwdController,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '您的登陆密码',
              icon: Icon(Icons.lock),
            ),
            obscureText: true,
            // 校验密码
            validator: (value) {
              return value!.trim().length > 5 ? null : '密码不能少于6位';
            },
          ),
          // 登录按钮
          Padding(
            padding: EdgeInsets.only(top: 28.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 通过_formKey.currentState 获取FormState后，
                      // 调用validate()方法校验用户名密码是否合法，校验
                      // 通过后再提交数据。
                      if ((_formKey.currentState as FormState).validate()) {
                        //验证通过提交数据
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('登录'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
