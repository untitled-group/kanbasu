import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/course.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/widgets/refreshable_stream_list.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _CoursesView extends RefreshableStreamListWidget<Course> {
  @override
  Stream<Stream<Course>> getStreamStream() => Provider.of<Model>(useContext())
      .canvas
      .getCourses()
      .map((courseList) => Stream.fromIterable(courseList));

  @override
  Widget buildItem(Course item) =>
      Link(path: '/course/${item.id}', child: CourseWidget(item));
}

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title.courses'.tr()),
      ),
      body: _CoursesView(),
    );
  }
}
