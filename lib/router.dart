import 'package:get/route_manager.dart';
import 'package:kanbasu/screens/course.dart';
import 'package:kanbasu/screens/preview.dart';
import 'package:kanbasu/screens/test/stream_list.dart';
import 'package:url_launcher/url_launcher.dart';

final getPages = [
  GetPage(
    name: '/course/:courseId',
    page: () => CourseScreen(courseId: int.parse(Get.parameters['courseId']!)),
  ),
  GetPage(
    name: '/course/:courseId/:initialTabId',
    page: () => CourseScreen(
      courseId: int.parse(Get.parameters['courseId']!),
      initialTabId: Get.parameters['initialTabId'],
    ),
  ),
  GetPage(
    name: '/preview/:fileId',
    page: () => PreviewScreen(fileId: Get.parameters['fileId']!),
  ),
  GetPage(
    name: '/test/stream_list',
    page: () => StreamListTestScreen(),
  ),
];

Future<void> navigateTo(
  String path, {
  bool replace = false,
}) async {
  if (path.startsWith('/')) {
    if (replace) {
      await Get.offNamed(path);
    } else {
      await Get.toNamed(path);
    }
  } else {
    if (await canLaunch(path)) {
      await launch(path);
    }
  }
}
