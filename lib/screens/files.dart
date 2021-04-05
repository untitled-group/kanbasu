import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/screens/list_screen.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class FilesScreen extends ListScreen<File> {
  final int courseId;

  FilesScreen({required this.courseId});

  @override
  Stream<Stream<File>> getStreamStream() =>
      Provider.of<Model>(useContext()).canvas.getFiles(courseId);

  @override
  Widget getTitle(s) => Text('tabs.file'.tr());

  @override
  Widget buildItem(File item) => Link(
      path: item.url,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(item.displayName),
            Expanded(
                child: Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.open_in_new),
            )),
          ],
        ),
      ));
}
