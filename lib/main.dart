import 'package:flutter/cupertino.dart';
import "dart:async";

import 'package:kanbasu/rest_api/course.dart';
import 'package:chopper/chopper.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<Request> authHeader(Request request) async =>
    applyHeader(
      request,
      "Authorization",
      "Bearer",
    );


sendRequest() async {
  final chopper = ChopperClient(
    client: http.Client(),
    baseUrl: "https://oc.sjtu.edu.cn/api/v1",
    services: [
      CourseService.create(),
    ],
    /* ResponseInterceptorFunc | RequestInterceptorFunc | ResponseInterceptor | RequestInterceptor */
    interceptors: [authHeader],
  );

  final courseService = chopper.getService<CourseService>();

  final response1 = await courseService.getCourses();
  print('response 1: ${response1.body}');
}

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: "Kanbasu",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Kanbasu'),
        ),
        child: Stack(
          children: [
            Align(
                alignment: FractionalOffset.center,
                child: CupertinoButton.filled(
                  key: Key('btn'),
                  child: Text('$_counter'),
                  onPressed: () {
                    setState(() {
                      _counter++;
                    });
                    sendRequest().then((_) {});
                  },
                )),
          ],
        ));
  }
}
