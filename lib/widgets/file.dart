import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:provider/provider.dart';
import 'package:filesize/filesize.dart';
import 'package:open_file/open_file.dart';

enum FileStatus { Downloaded, Downloading, Remote }

class FileWidget extends HookWidget {
  final File _item;

  FileWidget(this._item);

  @override
  Widget build(BuildContext context) {
    final fileStatus = useState<FileStatus>(FileStatus.Remote);
    final theme = Provider.of<Model>(context).theme;
    final resolverModel = Provider.of<ResolverModel>(context);
    final notifier = useValueListenable(resolverModel.getNotifierFor(_item.id));

    useEffect(() {
      resolverModel.fileResolver.getDownloadedFile(_item).then((value) {
        if (value != null) fileStatus.value = FileStatus.Downloaded;
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
        statusWidget = CircularProgressIndicator(value: percent);
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
      onTap: () async {
        await resolverModel.requestDownload(_item);

        // if (_item.contentType == 'application/pdf') {
        //   await navigateTo('/preview/${_item.id}');
        //   return;
        // }

        // Always open file and use native previewer
        final localFile =
            await resolverModel.fileResolver.getDownloadedFile(_item);
        if (localFile != null) {
          await OpenFile.open(localFile.path);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_item.displayName),
                SizedBox(height: 2),
                Text(
                  filesize(_item.size),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.tertiaryText,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: statusWidget is Icon
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          icon: statusWidget,
                          onPressed: () => resolverModel.requestDownload(_item),
                        )
                      : statusWidget,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
