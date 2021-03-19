import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:retrofit/retrofit.dart';
import 'package:logger/logger.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/tab.dart';
import 'paginated_list.dart';

/// `toResponse` transform an HTTP response to corresponding object.
/// If the HTTP response errored, it will return null.
Future<T?> toResponse<T>(
    Logger logger, Future<HttpResponse<T>> Function() sendRequest) async {
  try {
    final response = await sendRequest();
    return response.data;
  } on DioError catch (e) {
    logger.w('${e.error} w/response ${e.response}');
  }
  return null;
}

class CanvasBufferClient {
  /// [CanvasBufferClient] combines result from [CanvasRestClient] and
  /// sqlite cache. If a REST API returns a paginated list, it will be parsed
  /// and returned as an iterator.
  ///
  /// Currently, there are two styles of APIs.
  /// * Backupable API returns a Stream, which may contain one or two
  ///   elements. First one is from `KvStore`, and second one if from REST API.
  /// * Single API returns one object. Depend on `offline` flag, it will either
  ///   returns data from `KvStore` or from REST API.

  static const String _prefix = 'kanbasu/api_cache';
  final CanvasRestClient _restClient;
  final KvStore? _kvStore;
  final Logger _logger = Logger();
  bool _offline = false;

  CanvasBufferClient(this._restClient, [this._kvStore]);

  /// Enable offline mode
  void enableOffline() {
    _offline = true;
  }

  /// Disable offline mode
  void disableOffline() {
    _offline = false;
  }

  /// Get all object of [prefix]
  ///
  /// All objects are fetched from database as [String], then [transform]ed
  /// to `T`.
  Future<List<T>> scanPrefix<T>(
      String prefix, T Function(Map<String, dynamic>) transform) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return [];
    }
    return (await kvStore.scan('$_prefix/$prefix'))
        .values
        .map((item) => transform(jsonDecode(item)))
        .toList();
  }

  /// Replace all object of [prefix] with new [items], returns [items].
  ///
  /// All objects are [transform]ed to [String], then stored to database as
  /// [prefix]/[id].
  Future<List<T>> putPrefix<T>(String prefix, List<T> items,
      String Function(T) id, Map<String, dynamic> Function(T) transform) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return items;
    }
    await kvStore.rangeDelete('$_prefix/$prefix');
    for (final item in items) {
      await kvStore.setItem(
          '$_prefix/$prefix${id(item)}', jsonEncode(transform(item)));
    }
    return items;
  }

  /// Get an object of [key] from database
  ///
  /// It will be [transform]ed to `T` before returning.
  Future<T?> getObject<T>(
      String key, T Function(Map<String, dynamic>) transform) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return null;
    }
    final jsonData = await kvStore.getItem('$_prefix/$key');
    if (jsonData == null) {
      return null;
    }
    return transform(jsonDecode(jsonData));
  }

  /// Put [item] of [key] to database, returns [item].
  ///
  /// The object will be [transform]ed into [String].
  Future<T?> putObject<T>(
      String key, T? item, Map<String, dynamic> Function(T) transform) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return item;
    }
    if (item == null) {
      return item;
    }
    await kvStore.setItem('$_prefix/$key', jsonEncode(transform(item)));
    return item;
  }

  Future<void> close() async {
    final kvStore = _kvStore;
    if (kvStore != null) {
      await kvStore.close();
    }
  }

  /// Returns a stream of active courses for the current user.
  Stream<List<Course>> getCourses() async* {
    yield await scanPrefix('courses/', (e) => Course.fromJson(e));
    if (!_offline) {
      yield await putPrefix(
          'courses/',
          await PaginatedList<Course>(_restClient.getCourses).all().toList(),
          (e) => e.id.toString(),
          (e) => e.toJson());
    }
  }

  /// Returns a stream of active courses for the current user.
  Future<List<Course>> getCoursesF() async {
    if (!_offline) {
      return await putPrefix(
          'courses/',
          await PaginatedList<Course>(_restClient.getCourses).all().toList(),
          (e) => e.id.toString(),
          (e) => e.toJson());
    } else {
      return await scanPrefix('courses/', (e) => Course.fromJson(e));
    }
  }

  /// Returns information on a single course.
  Stream<Course?> getCourse(int id) async* {
    yield await getObject('courses/$id', (e) => Course.fromJson(e));
    yield await toResponse(_logger, () => _restClient.getCourse(id));
  }

  /// Returns information on a single course.
  Future<Course?> getCourseF(int id) async {
    if (!_offline) {
      return await putObject(
          'courses/$id',
          await toResponse(_logger, () => _restClient.getCourse(id)),
          (e) => e.toJson());
    } else {
      return await getObject('courses/$id', (e) => Course.fromJson(e));
    }
  }

  /// List available tabs for a course or group.
  Future<List<Tab>> getTabsF(int id) async {
    final prefix = 'tabs/course/$id/';
    if (!_offline) {
      return await putPrefix(prefix, (await _restClient.getTabs(id)).data,
          (e) => e.id, (e) => e.toJson());
    } else {
      return await scanPrefix(prefix, (e) => Tab.fromJson(e));
    }
  }

  /// List available tabs for a course or group.
  Stream<List<Tab>> getTabs(int id) async* {
    final prefix = 'tabs/course/$id/';
    yield await scanPrefix(prefix, (e) => Tab.fromJson(e));
    if (!_offline) {
      yield await putPrefix(prefix, (await _restClient.getTabs(id)).data,
          (e) => e.id, (e) => e.toJson());
    }
  }
}
