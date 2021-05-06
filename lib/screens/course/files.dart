import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:kanbasu/widgets/file.dart';
import 'package:provider/provider.dart';

// ignore: unused_element
// class _FilesTitle extends StreamWidget<Course?> {
//   final int courseId;

//   _FilesTitle(this.courseId);

//   @override
//   Widget buildWidget(context, Course? data) => Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: data == null
//           ? [
//               Text('tabs.file'.tr()),
//             ]
//           : [
//               Text('tabs.file'.tr(), style: TextStyle(fontSize: 20.0)),
//               Text(data.name, style: TextStyle(fontSize: 12.0)),
//             ]);

//   @override
//   List<Future<Course?>> getStream(context) =>
//       Provider.of<Model>(context).canvas.getCourse(courseId);
// }

class _FilesView extends RefreshableStreamListWidget<File> {
  final int courseId;

  _FilesView(this.courseId);

  @override
  int atLeast() => 20;

  @override
  List<Stream<File>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getFiles(courseId);

  @override
  Widget buildItem(context, File item) => FileWidget(item);
}

class CourseFilesScreen extends HookWidget {
  final int courseId;

  CourseFilesScreen(this.courseId);

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (BuildContext context) {
      return _FilesView(courseId);
    });
  }
}
