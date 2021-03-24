import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/course.dart';
import 'package:provider/provider.dart';
import 'list_screen.dart';

class CoursesScreen extends ListViewScreen<Course> {
  @override
  Stream<Stream<Course>> getStream() => Provider.of<Model>(useContext())
      .canvas
      .getCourses()
      .map((courseList) => Stream.fromIterable(courseList));

  @override
  Widget getTitle() => Text('Courses');

  @override
  Widget buildWidget(context, Course item) => CourseWidget(item);
}
