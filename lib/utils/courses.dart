import 'dart:math';

import 'package:kanbasu/models/course.dart';

List<Course> toLatestCourses(List<Course> courseList) {
  final latestTerm = courseList.map((c) => c.term?.id ?? 0).fold(0, max);
  final latestCourses =
      courseList.where((c) => (c.term?.id ?? 0) >= latestTerm).toList();
  return latestCourses;
}
