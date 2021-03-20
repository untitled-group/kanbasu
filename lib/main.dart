import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'home.dart';
import 'rest_api/canvas.dart';
import 'package:dio/dio.dart';
import 'buffer_api/kvstore.dart';

void main() {
  KvStore.initFfi();

  final model = Model();

  return runApp(
    ChangeNotifierProvider(create: (context) => model, child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;

    return MaterialApp(
      title: 'Kanbasu',
      theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: theme.primary,
          scaffoldBackgroundColor: theme.background),
      home: Home(),
    );
  }
}

Future<void> getCourses() async {
  final dio = Dio(BaseOptions(
      headers: {HttpHeaders.authorizationHeader: 'Bearer $CANVAS_API_KEY'}));
  final api = CanvasRestClient(dio, baseUrl: CANVAS_API_ENDPOINT);
  print(await api.getCourses());
}
