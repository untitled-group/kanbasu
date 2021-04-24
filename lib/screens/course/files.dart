import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/widgets/refreshable_stream_list.dart';
import 'package:kanbasu/widgets/stream.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: unused_element
class _FilesTitle extends StreamWidget<Course?> {
  final int courseId;

  _FilesTitle(this.courseId);

  @override
  Widget buildWidget(context, Course? data) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: data == null
          ? [
              Text('tabs.file'.tr()),
            ]
          : [
              Text('tabs.file'.tr(), style: TextStyle(fontSize: 20.0)),
              Text(data.name, style: TextStyle(fontSize: 12.0)),
            ]);

  @override
  Stream<Course?> getStream(context) =>
      Provider.of<Model>(context).canvas.getCourse(courseId);
}

class _FilesView extends RefreshableStreamListWidget<File> {
  final int courseId;

  _FilesView(this.courseId);

  @override
  int atLeast() => 20;

  @override
  Stream<Stream<File>> getStreamStream(context) =>
      Provider.of<Model>(context).canvas.getFiles(courseId);

  @override
  Widget buildItem(context, File item) => Link(
        path: item.url,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(item.displayName)]),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.open_in_new),
              )),
            ],
          ),
        ),
      );
}

class CourseFilesScreen extends StatelessWidget {
  final int courseId;

  CourseFilesScreen(this.courseId);

  @override
  Widget build(BuildContext context) {
    return _FilesView(courseId);
  }
}
