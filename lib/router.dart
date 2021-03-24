import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

final router = FluroRouter();

void initRouter() {
  router.define('/course/:courseId', handler: Handler(
    handlerFunc: (context, parameters) {
      final courseId = parameters['courseId']!.first;
      return Container(child: Text('$courseId'));
    },
  ));
}
