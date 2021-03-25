import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:kanbasu/screens/course.dart';
import 'package:url_launcher/url_launcher.dart';

final router = FluroRouter();

void initRouter() {
  router.define('/course/:courseId', handler: Handler(
    handlerFunc: (context, parameters) {
      final courseId = int.parse(parameters['courseId']!.first);
      return CourseScreen(id: courseId);
    },
  ));
}

Future<void> navigateTo(
  BuildContext context,
  String path, {
  bool replace = false,
}) async {
  if (path.startsWith('/')) {
    await router.navigateTo(
      context,
      path,
      transition: TransitionType.material,
      replace: replace,
    );
  } else {
    if (await canLaunch(path)) {
      await launch(path);
    }
  }
}
