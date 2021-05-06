import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/resolver_model.dart';
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

  _File(this._item);

  @override
  Widget build(BuildContext context) {
    final fileStatus = useState<FileStatus>(FileStatus.Remote);
    final resolverModel = Provider.of<ResolverModel>(context);
    final notifier = useValueListenable(resolverModel.getNotifierFor(_item.id));

    final onTap = () {
      resolverModel.requestDownload(_item);
    };

    useEffect(() {
      resolverModel.fileResolver.getDownloadedFile(_item).then((value) {
        if (value != null) {
          fileStatus.value = FileStatus.Downloaded;
        }
      });
    }, [notifier]);

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
                    child: fileStatus.value == FileStatus.Downloaded
                        ? Icon(Icons.download_done_rounded)
                        : (resolverModel.isFileDownloading[_item.id] ?? false)
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    value: resolverModel
                                        .fileResolveProgress[_item.id]
                                        ?.percent))
                            : Container(width: 24, height: 24))),
          ],
        ),
      ),
    );
  }
}

class _FilesView extends RefreshableStreamListWidget<File> {
  final int courseId;

  _FilesView(this.courseId);

  @override
  int atLeast() => 20;

  @override
  List<Stream<File>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getFiles(courseId);

  @override
  Widget buildItem(context, File item) => _File(item);
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
