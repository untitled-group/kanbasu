import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/screens/list_screen.dart';
import 'package:kanbasu/widgets/course.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends ListScreen<Course> {
  @override
  Stream<Stream<Course>> getStreamStream() => Provider.of<Model>(useContext())
      .canvas
      .getCourses()
      .map((courseList) => Stream.fromIterable(courseList));

  @override
  Widget getTitle() => Text('Courses');

  @override
  Widget buildItem(Course item) =>
      Link(path: '/course/${item.id}', child: CourseWidget(item));
}
