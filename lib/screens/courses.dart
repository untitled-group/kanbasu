import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/utils/courses.dart';
import 'package:kanbasu/widgets/course.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _CoursesView extends RefreshableStreamListWidget<Course> {
  @override
  List<Stream<Course>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getCourses().map((courseStream) {
        return () async* {
          final courseList = await courseStream.toList();
          final latestCourses = toLatestCourses(courseList);
          for (final course in latestCourses) {
            yield course;
          }
        }();
      }).toList();

  @override
  Widget buildItem(context, Course item) =>
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
