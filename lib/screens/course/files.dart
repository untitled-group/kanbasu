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

enum FileStatus { Downloaded, Downloading, Remote }

class _File extends HookWidget {
  final File _item;
  final FileResolver _resolver;
  final bool _doDownload;

  _File(this._item, this._resolver, this._doDownload);

  @override
  Widget build(BuildContext context) {
    final fileStatus = useState<FileStatus>(FileStatus.Remote);
    final resolveProgress = useState<Stream<ResolveProgress>?>(null);
    final downloadProgress = useStream(resolveProgress.value,
        initialData: null, preserveState: false);
    final progressData = downloadProgress.data;
    final onTap = () {
      if (fileStatus.value != FileStatus.Downloading) {
        fileStatus.value = FileStatus.Downloading;
        resolveProgress.value = _resolver
            .visit(_item)
            .doOnDone(() {
              fileStatus.value = FileStatus.Downloaded;
            })
            .handleError((e) => showErrorSnack(context, e))
            .throttleTime(Duration(milliseconds: 10));
      }
    };
    useEffect(() {
      _resolver.getDownloadedFile(_item).then((value) {
        if (value != null) {
          fileStatus.value = FileStatus.Downloaded;
        }
      });
      if (_doDownload) {
        onTap();
      }
    }, [_doDownload]);

    return InkWell(
      onTap: onTap,
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
                    child: fileStatus.value == FileStatus.Downloading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                value: progressData?.percent ?? 0.0))
                        : fileStatus.value == FileStatus.Downloaded
                            ? Icon(Icons.download_done_rounded)
                            : Container(width: 24, height: 24))),
          ],
        ),
      ),
    );
  }
}

class _FilesView extends RefreshableStreamListWidget<File> {
  final int courseId;
  final FileResolver _resolver;
  final bool _doFullDownload;

  _FilesView(this.courseId, this._resolver, this._doFullDownload);

  @override
  int atLeast() => 20;

  @override
  List<Stream<File>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getFiles(courseId);

  @override
  Widget buildItem(context, File item) =>
      _File(item, _resolver, _doFullDownload);
}

class CourseFilesScreen extends HookWidget {
  final int courseId;
  final bool doFullDownload;

  CourseFilesScreen(this.courseId, this.doFullDownload);

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (BuildContext context) {
      final resolver =
          FileResolver(Provider.of<Model>(context).kvs, createLogger());
      return _FilesView(courseId, resolver, doFullDownload);
    });
  }
}
