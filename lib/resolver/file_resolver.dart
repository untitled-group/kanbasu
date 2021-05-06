import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/file.dart' as f;
import 'package:kanbasu/models/local_file.dart';
import 'package:kanbasu/resolver/resolve_progress.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:pedantic/pedantic.dart';

class FileResolver {
  /// [FileResolver] will download a file and save the record to cache

  final KvStore _cache;
  final Logger _logger;

  FileResolver(this._cache, this._logger);

  void onError(dynamic error, StackTrace st) {
    _logger.w('An error occurred when downloading', error, st);
  }

  String _getLocalFileId(file_id) => 'local_files/by_id/$file_id';

  /// Download file
  Stream<ResolveProgress> visit(f.File file) async* {
    if (await getDownloadedFile(file) != null) {
      return;
    }

    final downloadFolder =
        Directory((await getApplicationDocumentsDirectory()).path + '/kanbasu');
    await downloadFolder.create(recursive: true);
    final localFilePath =
        downloadFolder.path + '/' + '${file.id}-' + file.displayName;
    _logger.i('[FileResolver] Download ${file.displayName} to $localFilePath');

    final options = BaseOptions(responseType: ResponseType.stream);
    final dio = Dio(options);
    final subject = PublishSubject<ResolveProgress>();
    unawaited(dio
        .download(file.url, localFilePath,
            onReceiveProgress: (of, total) =>
                subject.add(ResolveProgress((r) => r
                  ..percent = of.toDouble() / total.toDouble()
                  ..message = '')))
        .then((value) => subject.close(), onError: (error, st) {
      onError(error, st);
      subject.close();
    }));
    await for (final item in subject) {
      yield item;
    }
    final fileItem = LocalFile((f) => f
      ..id = file.id
      ..path = localFilePath);
    await _cache.setItem(
        _getLocalFileId(file.id), jsonEncode(fileItem.toJson()));
    _logger.i('[FileResolver] Complete download ${file.displayName}');
  }

  Future<LocalFile?> getDownloadedFile(f.File file) async {
    final item = await _cache.getItem(_getLocalFileId(file.id));
    if (item != null) {
      return LocalFile.fromJson(jsonDecode(item));
    } else {
      return null;
    }
  }

  Future<Map<int, LocalFile>> getAll() async {
    const prefix = 'local_files/by_id/';
    final items = await _cache.scan(prefix);
    final files = <int, LocalFile>{};
    for (final item in items.entries) {
      files.putIfAbsent(int.parse(item.key.substring(prefix.length)),
          () => LocalFile.fromJson(jsonDecode(item.value)));
    }
    return files;
  }
}
