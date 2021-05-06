import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:provider/provider.dart';
import 'package:file_sizes/file_sizes.dart';

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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_item.displayName),
              SizedBox(height: 2),
              Text(
                FileSize().getSize(_item.size),
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
    );
  }
}
