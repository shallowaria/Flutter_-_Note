import 'package:flutter/material.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/animated_list_route.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/grid_delegate_route.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/infinite_grid_view.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/infinite_list_view.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/page_view_test_widget.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/scroll_controller_test_route.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/scroll_notification_test_route.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/single_child_scroll_view_test_route.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/tab_view_route1.dart';
import 'package:flutter_fight/%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6/tab_view_route2.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%9F%B3%E7%BB%84%E4%BB%B6/%E8%B7%AF%E7%94%B1/echo_route.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%9F%B3%E7%BB%84%E4%BB%B6/%E8%B7%AF%E7%94%B1/new_route.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%9F%B3%E7%BB%84%E4%BB%B6/%E8%B7%AF%E7%94%B1/tip_route.dart';
import 'package:flutter_fight/%E5%9F%BA%E7%A1%80%E7%BB%84%E4%BB%B6/%E8%BE%93%E5%85%A5%E6%A1%86%E5%92%8C%E8%A1%A8%E5%8D%95/login_form_page.dart';
import 'package:flutter_fight/%E5%AE%B9%E5%99%A8%E7%B1%BB%E7%BB%84%E4%BB%B6/clip_test_widget.dart';
import 'package:flutter_fight/%E5%AE%B9%E5%99%A8%E7%B1%BB%E7%BB%84%E4%BB%B6/scaffold_route.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
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
        'scroll_controller_test_route': (context) =>
            ScrollControllerTestRoute(),
        'grid_view': (context) => GridDelegateRoute(),
        'tab_view_route2': (context) => TabViewRoute2(),
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
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                'scroll_controller_test_route',
                arguments: 'hi from main',
              );
            },
            child: Text(
              'scroll_controller_test_route',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                'grid_view',
                arguments: 'hi from main',
              );
            },
            child: Text('GridView'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                'tab_view_route2',
                arguments: 'hi from main',
              );
            },
            child: Text('TabViewRoute2'),
          ),
          Expanded(child: PageViewTestWidget()),
          // Expanded(child: AnimatedListRoute()),
          // Expanded(child: InfiniteGridView()),
          // Expanded(child: ScrollNotificationTestRoute()),
          // Expanded(child: InfiniteListView()),
          // Expanded(child: SingleChildScrollViewTestRoute()),
        ],
      ),
    );
  }
}
