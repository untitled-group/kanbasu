import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/scaffolds/common.dart';

final router = FluroRouter();

void initRouter() {
  router.define('/course/:courseId', handler: Handler(
    handlerFunc: (context, parameters) {
      final courseId = parameters['courseId']!.first;
      return CommonScaffold(
        title: Text('Course $courseId'),
        body: Container(child: Text('$courseId')),
      );
    },
  ));
}
