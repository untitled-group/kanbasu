import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/resolver/file_resolver.dart';
import 'package:kanbasu/resolver/resolve_progress.dart';
import 'package:kanbasu/resolver/resolver.dart';
import 'package:kanbasu/utils/logging.dart';
import 'package:rxdart/rxdart.dart';

class _Notifier {}

class ResolverModel with ChangeNotifier {
  late Model _model;
  late FileResolver _fileResolver;
  final _resolveProgress = ValueNotifier<ResolveProgress?>(null);
  final _isFileDownloading = <int, bool>{};
  final _fileResolveProgress = <int, ResolveProgress>{};
  final _notifiers = <int, ValueNotifier<_Notifier>>{};

  ValueNotifier<ResolveProgress?> get resolveProgress => _resolveProgress;
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

  Future<int> requestDownloadAll(int courseId) async {
    final model = _model;

    final stream = model.canvas.getFiles(courseId).last.shareReplay();
    await for (final file in stream) {
      _isFileDownloading[file.id] = true;
      notifyId(file.id);
    }

    final files = await stream.toList();
    var count = 0;

    for (final file in files) {
      try {
        await Future.wait([
          requestDownload(file),
          Future.delayed(Duration(milliseconds: 100)),
        ]);
        count += 1;
      } catch (_) {}
      _isFileDownloading.remove(file.id);
      _fileResolveProgress.remove(file.id);
      notifyId(file.id);
    }

    return count;
  }

  Future<void> requestFullSync() async {
    final resolver = Resolver(
        _model.rest, KvStore.openInMemory(), _model.kvs, createLogger());
    final completer = Completer();
    resolver
        .visit()
        .doOnDone(() {})
        .doOnError((err, st) {
          completer.completeError(err, st);
        })
        .doOnDone(() {
          if (!completer.isCompleted) {
            completer.complete();
          }
        })
        .throttleTime(Duration(milliseconds: 10))
        .listen((event) {
          _resolveProgress.value = event;
        });
    _resolveProgress.value = null;
    await completer.future;
  }
}
