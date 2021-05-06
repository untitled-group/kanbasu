import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanbasu/aggregation.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/resolver/file_resolver.dart';
import 'package:kanbasu/resolver/resolve_progress.dart';
import 'package:kanbasu/utils/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

class _Notifier {}

class ResolverModel with ChangeNotifier {
  late Model _model;
  late FileResolver _fileResolver;
  ResolveProgress? _resolveProgress;
  final _isFileDownloading = <int, bool>{};
  final _fileResolveProgress = <int, ResolveProgress>{};
  final _notifiers = <int, ValueNotifier<_Notifier>>{};

  ResolveProgress? get resolveProgress => _resolveProgress;
  Map<int, ResolveProgress> get fileResolveProgress => _fileResolveProgress;
  Map<int, bool> get isFileDownloading => _isFileDownloading;
  FileResolver get fileResolver => _fileResolver;

  ValueNotifier<_Notifier> getNotifierFor(int fileId) {
    if (!_notifiers.containsKey(fileId)) {
      _notifiers[fileId] = ValueNotifier(_Notifier());
    }
    return _notifiers[fileId]!;
  }

  ResolverModel();

  void updateModel(Model model) {
    _model = model;
    _fileResolver = FileResolver(model.kvs, createLogger());
    notifyListeners();
  }

  void notifyId(int fileId) {
    final notifier = _notifiers[fileId];
    if (notifier != null) {
      notifier.value = _Notifier();
    }
  }

  Future<void> requestDownload(File file) async {
    final fileResolver = _fileResolver;
    _isFileDownloading[file.id] = true;
    notifyId(file.id);

    final completer = Completer();
    fileResolver
        .visit(file)
        .handleError((error) => completer.completeError(error))
        .doOnDone(() => completer.complete())
        .throttleTime(Duration(milliseconds: 10))
        .listen((progress) {
      _fileResolveProgress[file.id] = progress;
      notifyId(file.id);
    });

    await completer.future;

    await Future.delayed(Duration(milliseconds: 100));
    _isFileDownloading.remove(file.id);
    _fileResolveProgress.remove(file.id);
    notifyId(file.id);
  }

  void requestDownloadAll(int courseId) {
    unawaited(() async {
      final model = _model;

      final files =
          await getListDataFromApi(model.canvas.getFiles(courseId), true);

      for (final file in files) {
        _isFileDownloading[file.id] = true;
        notifyId(file.id);
      }

      for (final file in files) {
        try {
          await requestDownload(file);
        } catch (_) {}
        await Future.delayed(Duration(milliseconds: 100));
        _isFileDownloading.remove(file.id);
        _fileResolveProgress.remove(file.id);
        notifyId(file.id);
      }
    }());
  }
}
