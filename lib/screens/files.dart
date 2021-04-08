import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/screens/list_screen.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/widgets/stream.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class _FilesTitle extends StreamWidget<Course?> {
  final int courseId;

  _FilesTitle(this.courseId);

  @override
  Widget buildWidget(Course? data) => Column(
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
  Stream<Course?> getStream() =>
      Provider.of<Model>(useContext()).canvas.getCourse(courseId);
}

class FilesScreen extends ListScreen<File> {
  final int courseId;

  FilesScreen({required this.courseId});

  @override
  Stream<Stream<File>> getStreamStream() =>
      Provider.of<Model>(useContext()).canvas.getFiles(courseId);

  @override
  Widget getTitle(s) => useMemoized(() => _FilesTitle(courseId));

  @override
  Widget buildItem(File item) => Link(
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
      ));
}
