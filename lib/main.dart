import 'package:flutter/material.dart';
import 'package:flutter_fight/%E8%B7%AF%E7%94%B1/echo_route.dart';
import 'package:flutter_fight/%E8%B7%AF%E7%94%B1/new_route.dart';
import 'package:flutter_fight/%E8%B7%AF%E7%94%B1/router_test_route.dart';
import 'package:flutter_fight/%E8%B7%AF%E7%94%B1/tip_route.dart';

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
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) {
            String routeName = settings.name;
            // 如果访问的路由页需要登录，但当前未登录，则直接返回登录页路由，
            // 引导用户登录；其他情况则正常打开路由。
          },
        );
      },
      routes: {
        "tip2": (context) {
          return TipRoute(
            text: ModalRoute.of(context)!.settings.arguments as String,
          );
        },
        'new_page': (context) => NewRoute(),
        'new_page2': (context) => EchoRoute(),
        '/': (context) =>
            MyHomePage(title: 'Flutter Demo Home Page'), //等同于下面写home，注册主路由
      },

      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed('new_page2', arguments: 'hi from main');
                // Navigator.pushNamed(context, 'new_page');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return NewRoute();
                //     },
                //   ),
                // );
              },
              child: Text(
                'open new route',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
