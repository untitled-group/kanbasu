import 'package:built_collection/built_collection.dart';
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
  BuiltMap<int, bool> _isFileDownloading = BuiltMap();
  BuiltMap<int, ResolveProgress> _fileResolveProgress = BuiltMap();
  BuiltMap<int, ValueNotifier<_Notifier>> _notifiers = BuiltMap();

  ResolveProgress? get resolveProgress => _resolveProgress;
  BuiltMap<int, ResolveProgress> get fileResolveProgress =>
      _fileResolveProgress;
  BuiltMap<int, bool> get isFileDownloading => _isFileDownloading;
  FileResolver get fileResolver => _fileResolver;

  ValueNotifier<_Notifier> getNotifierFor(int fileId) {
    _notifiers = _notifiers.rebuild(
        (b) => b..putIfAbsent(fileId, () => ValueNotifier(_Notifier())));
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

  void requestDownload(File file) {
    unawaited(() async {
      final fileResolver = _fileResolver;
      _isFileDownloading = _isFileDownloading
          .rebuild((b) => b..updateValue(file.id, (_) => true));
      notifyId(file.id);

      try {
        await for (final progress in fileResolver
            .visit(file)
            .throttleTime(Duration(milliseconds: 10))) {
          _fileResolveProgress = _fileResolveProgress
              .rebuild((b) => b..updateValue(file.id, (_) => progress));
          notifyId(file.id);
        }
      } finally {
        _isFileDownloading =
            _isFileDownloading.rebuild((b) => b..remove(file.id));
        _fileResolveProgress =
            _fileResolveProgress.rebuild((b) => b..remove(file.id));
        notifyId(file.id);
      }
      fileResolver.visit(file);
    }());
  }

  void requestDownloadAll(int courseId) {
    unawaited(() async {
      final model = _model;
      final fileResolver = _fileResolver;

      final files =
          await getListDataFromApi(model.canvas.getFiles(courseId), true);

      _isFileDownloading = _isFileDownloading.rebuild((b) {
        for (final file in files) {
          b.updateValue(file.id, (_) => true);
        }
        return b;
      });

      for (final file in files) {
        notifyId(file.id);
      }

      for (final file in files) {
        try {
          await for (final progress in fileResolver
              .visit(file)
              .throttleTime(Duration(milliseconds: 10))) {
            _fileResolveProgress = _fileResolveProgress
                .rebuild((b) => b..updateValue(file.id, (_) => progress));
            notifyId(file.id);
          }
        } finally {
          _isFileDownloading =
              _isFileDownloading.rebuild((b) => b..remove(file.id));
          _fileResolveProgress =
              _fileResolveProgress.rebuild((b) => b..remove(file.id));
          notifyId(file.id);
        }
      }
    }());
  }
}
