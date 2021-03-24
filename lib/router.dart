import 'package:fluro/fluro.dart';
import 'package:kanbasu/screens/course.dart';

final router = FluroRouter();

void initRouter() {
  router.define('/course/:courseId', handler: Handler(
    handlerFunc: (context, parameters) {
      final courseId = int.parse(parameters['courseId']!.first);
      return CourseScreen(id: courseId);
    },
  ));
}
