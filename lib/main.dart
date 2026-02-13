import 'package:flutter/material.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%9F%B3%E7%BB%84%E4%BB%B6/%E8%B7%AF%E7%94%B1/echo_route.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%9F%B3%E7%BB%84%E4%BB%B6/%E8%B7%AF%E7%94%B1/new_route.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%9F%B3%E7%BB%84%E4%BB%B6/%E8%B7%AF%E7%94%B1/tip_route.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%A1%80%E7%BB%84%E4%BB%B6/%E5%8D%95%E9%80%89%E5%BC%80%E5%85%B3%E5%92%8C%E5%A4%8D%E9%80%89%E6%A1%86/progress_route.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%A1%80%E7%BB%84%E4%BB%B6/%E8%BE%93%E5%85%A5%E6%A1%86%E5%92%8C%E8%A1%A8%E5%8D%95/login_form_page.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%A1%80%E7%BB%84%E4%BB%B6/%E8%BF%9B%E5%BA%A6%E6%8C%87%E7%A4%BA%E5%99%A8/progress_indicator_widget.dart';
import 'package:flutter_fight/%E5%AE%B9%E5%99%A8%E7%B1%BB%E7%BB%84%E4%BB%B6/clip_test_widget.dart';
import 'package:flutter_fight/%E5%AE%B9%E5%99%A8%E7%B1%BB%E7%BB%84%E4%BB%B6/container_test_widget.dart';
import 'package:flutter_fight/%E5%AE%B9%E5%99%A8%E7%B1%BB%E7%BB%84%E4%BB%B6/padding_test_route.dart';
import 'package:flutter_fight/%E5%AE%B9%E5%99%A8%E7%B1%BB%E7%BB%84%E4%BB%B6/scaffold_route.dart';
import 'package:flutter_fight/%E5%B8%83%E5%B1%80%E7%B1%BB%E7%BB%84%E4%BB%B6/constrains_widget.dart';
import 'package:flutter_fight/%E5%B8%83%E5%B1%80%E7%B1%BB%E7%BB%84%E4%BB%B6/stack_positioned_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      // 注册路由表
      // onGenerateRoute: (RouteSettings settings) {
      //   return MaterialPageRoute(
      //     builder: (context) {
      //       String routeName = settings.name;
      //       // 如果访问的路由页需要登录，但当前未登录，则直接返回登录页路由，
      //       // 引导用户登录；其他情况则正常打开路由。
      //     },
      //   );
      // },
      routes: {
        "tip2": (context) {
          return TipRoute(
            text: ModalRoute.of(context)!.settings.arguments as String,
          );
        },
        'new_page': (context) => NewRoute(),
        'new_page2': (context) => EchoRoute(),
        'input_form': (context) => LoginFormPage(),
        'scaffold_route': (context) => ScaffoldRoute(),
        '/': (context) =>
            MyHomePage(title: 'Flutter Combat Home Page'), //等同于下面写home，注册主路由
      },

      // home: const MyHomePage(title: 'Flutter Combat Home Page'),
      // home: RouterTestRoute(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          ClipTestWidget(),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                'scaffold_route',
                arguments: 'hi from main',
              );
            },
            child: Text(
              'jump to scaffold_route',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }
}
