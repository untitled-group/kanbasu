import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/course.dart';
import 'list_screen.dart';

class CoursesScreen extends ListViewScreen<Course> {
  @override
  Stream<Stream<Course>> getStream(Model model) => model.canvas
      .getCourses()
      .map((courseList) => Stream.fromIterable(courseList));

  @override
  Widget getTitle() => Text('Courses');

  @override
  Widget buildWidget(Course item) => CourseWidget(item);
}
