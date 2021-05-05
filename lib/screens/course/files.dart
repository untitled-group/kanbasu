import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/resolver/file_resolver.dart';
import 'package:kanbasu/resolver/resolve_progress.dart';
import 'package:kanbasu/utils/logging.dart';
import 'package:kanbasu/widgets/snack.dart';
import 'package:rxdart/rxdart.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
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

class _File extends HookWidget {
  final File _item;
  final FileResolver _resolver;

  _File(this._item, this._resolver);

  @override
  Widget build(BuildContext context) {
    final isDownloading = useState<bool>(false);
    final resolveProgress = useState<Stream<ResolveProgress>?>(null);
    final downloadProgress = useStream(resolveProgress.value,
        initialData: null, preserveState: false);
    final progressData = downloadProgress.data;

    return InkWell(
      onTap: () {
        isDownloading.value = true;
        resolveProgress.value = _resolver
            .visit(_item)
            .doOnDone(() {
              isDownloading.value = false;
              showSnack(context, '下载完成');
            })
            .handleError((e) => showErrorSnack(context, e))
            .throttleTime(Duration(milliseconds: 10));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(_item.displayName)]),
            Expanded(
                child: Align(
              alignment: Alignment.centerRight,
              child: isDownloading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          value: progressData?.percent ?? 0))
                  : Icon(Icons.open_in_new),
            )),
          ],
        ),
      ),
    );
  }
}

class _FilesView extends RefreshableStreamListWidget<File> {
  final int courseId;
  final FileResolver _resolver;

  _FilesView(this.courseId, this._resolver);

  @override
  int atLeast() => 20;

  @override
  List<Stream<File>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getFiles(courseId);

  @override
  Widget buildItem(context, File item) => _File(item, _resolver);
}

class CourseFilesScreen extends StatelessWidget {
  final int courseId;

  CourseFilesScreen(this.courseId);

  @override
  Widget build(BuildContext context) {
    final resolver =
        FileResolver(Provider.of<Model>(context).kvs, createLogger());
    return _FilesView(courseId, resolver);
  }
}
