import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:retrofit/retrofit.dart';
import 'package:logger/logger.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/tab.dart';
import 'package:kanbasu/types.dart';
import 'paginated_list.dart';

/// [toResponse] transform an HTTP response to corresponding object.
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
  Future<List<T>> scanPrefix<T>(String prefix, FromJson<T> fromJson) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return [];
    }
    return (await kvStore.scan('$_prefix/$prefix'))
        .values
        .map((item) => fromJson(json.decode(item)))
        .toList();
  }

  /// Replace all object of [prefix] with new [items], returns [items].
  ///
  /// All objects are [transform]ed to [String], then stored to database as
  /// [prefix]/[id].
  Future<List<T>> putPrefix<T>(String prefix, List<T> items,
      String Function(T) id, ToJson<T> toJson) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return items;
    }
    await kvStore.rangeDelete('$_prefix/$prefix');
    for (final item in items) {
      await kvStore.setItem(
          '$_prefix/$prefix${id(item)}', json.encode(toJson(item)));
    }
    return items;
  }

  /// Get an object of [key] from database
  ///
  /// It will be [transform]ed to `T` before returning.
  Future<T?> getObject<T>(String key, FromJson<T> fromJson) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return null;
    }
    final jsonData = await kvStore.getItem('$_prefix/$key');
    if (jsonData == null) {
      return null;
    }
    return fromJson(json.decode(jsonData));
  }

  /// Put [item] of [key] to database, returns [item].
  ///
  /// The object will be [transform]ed into [String].
  Future<T?> putObject<T>(String key, T? item, ToJson<T> toJson) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return item;
    }
    if (item == null) {
      return item;
    }
    await kvStore.setItem('$_prefix/$key', json.encode(toJson(item)));
    return item;
  }

  /// Close the [KvStore]. Generally this is only used in tests.
  Future<void> close() async {
    final kvStore = _kvStore;
    if (kvStore != null) {
      await kvStore.close();
    }
  }

  /// Fetch a [PaginatedList] sequentially from [KvStore] and
  /// [CanvasRestClient], and produce a stream of type `List<T>`.
  Stream<List<T>> _getPaginatedListStream<T>(
      String prefix,
      FromJson<T> fromJson,
      ToJson<T> toJson,
      ListPaginated<T> listPaginated,
      GetId getId) async* {
    // First, yield results from database
    yield await scanPrefix(prefix, fromJson);
    if (!_offline) {
      // Then, yield return from REST API and put them back into database
      yield await putPrefix(prefix,
          await PaginatedList<T>(listPaginated).all().toList(), getId, toJson);
    }
  }

  /// Fetch a [PaginatedList] either from [KvStore] or [CanvasRestClient],
  /// and produce a future of type `List<T>`.
  Future<List<T>> _getPaginatedListFuture<T>(
      String prefix,
      FromJson<T> fromJson,
      ToJson<T> toJson,
      ListPaginated<T> listPaginated,
      GetId getId) async {
    if (!_offline) {
      return await putPrefix(prefix,
          await PaginatedList<T>(listPaginated).all().toList(), getId, toJson);
    } else {
      return await scanPrefix(prefix, fromJson);
    }
  }

  /// Fetch an item sequentially from [KvStore] and [CanvasRestClient],
  /// and produce a stream of type `T?`.
  Stream<T?> _getItemStream<T>(String key, FromJson<T> fromJson,
      ToJson<T> toJson, GetItem<T> getItem) async* {
    yield await getObject(key, fromJson);
    yield await putObject(key, await toResponse(_logger, getItem), toJson);
  }

  /// Fetch an item either from [KvStore] or [CanvasRestClient],
  /// and produce a future of type `T?`.
  Future<T?> _getItemFuture<T>(String key, FromJson<T> fromJson,
      ToJson<T> toJson, GetItem<T> getItem) async {
    if (!_offline) {
      return await putObject(key, await toResponse(_logger, getItem), toJson);
    } else {
      return await getObject(key, fromJson);
    }
  }

  // **************************************************************************
  // Add new REST APIs below
  // **************************************************************************

  /// Returns a stream of active courses for the current user.
  Stream<List<Course>> getCourses() {
    return _getPaginatedListStream('courses/', (e) => Course.fromJson(e),
        (e) => e.toJson(), _restClient.getCourses, (e) => e.id.toString());
  }

  /// Returns a stream of active courses for the current user.
  Future<List<Course>> getCoursesF() {
    return _getPaginatedListFuture('courses/', (e) => Course.fromJson(e),
        (e) => e.toJson(), _restClient.getCourses, (e) => e.id.toString());
  }

  String _getCoursePrefix(id) => 'courses/$id';

  /// Returns information on a single course.
  Stream<Course?> getCourse(int id) {
    return _getItemStream(_getCoursePrefix(id), (e) => Course.fromJson(e),
        (e) => e.toJson(), () => _restClient.getCourse(id));
  }

  /// Returns information on a single course.
  Future<Course?> getCourseF(int id) {
    return _getItemFuture(_getCoursePrefix(id), (e) => Course.fromJson(e),
        (e) => e.toJson(), () => _restClient.getCourse(id));
  }

  String _getTabPrefix(id) => 'tabs/course/$id/';

  /// List available tabs for a course or group.
  Future<List<Tab>> getTabsF(int id) {
    return _getPaginatedListFuture(
        _getTabPrefix(id),
        (e) => Tab.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getTabs(id, queries: queries),
        (e) => e.id);
  }

  /// List available tabs for a course or group.
  Stream<List<Tab>> getTabs(int id) {
    return _getPaginatedListStream(
        _getTabPrefix(id),
        (e) => Tab.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getTabs(id, queries: queries),
        (e) => e.id);
  }
}
