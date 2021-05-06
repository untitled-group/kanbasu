import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/resolver_model.dart';
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
    final theme = Provider.of<Model>(context).theme;
    final resolverModel = Provider.of<ResolverModel>(context);
    final notifier = useValueListenable(resolverModel.getNotifierFor(_item.id));

    useEffect(() {
      resolverModel.fileResolver.getDownloadedFile(_item).then((value) {
        if (value != null) {
          fileStatus.value = FileStatus.Downloaded;
        }
      });
    }, [notifier]);

    final Widget statusWidget;

    if (fileStatus.value == FileStatus.Downloaded) {
      // downloaded
      statusWidget = Icon(Icons.cloud_done_outlined);
    } else if (resolverModel.isFileDownloading[_item.id] == true) {
      // downloading
      final percent = resolverModel.fileResolveProgress[_item.id]?.percent;
      if (percent != null) {
        // transferring
        statusWidget = SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(value: percent),
        );
      } else {
        // queueing
        statusWidget = Icon(Icons.cloud_queue_outlined);
      }
    } else {
      // on cloud
      statusWidget = Icon(
        Icons.cloud_download_outlined,
        color: theme.tertiaryText,
      );
    }

    return InkWell(
      onTap: () => resolverModel.requestDownload(_item),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(_item.displayName)],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: statusWidget,
              ),
            ),
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
