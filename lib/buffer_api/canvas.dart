import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/models/module.dart';
import 'package:retrofit/retrofit.dart';
import 'package:logger/logger.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/maybe_course.dart';
import 'package:kanbasu/models/tab.dart';
import 'package:kanbasu/models/user.dart';
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
  Future<List<T>> scanPrefix<T>(String prefix, FromJson<T> fromJson,
      {ScanOrder? order}) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return [];
    }
    return (await kvStore.scan('$_prefix/$prefix', order: order))
        .values
        .map((item) => fromJson(json.decode(item)))
        .toList();
  }

  /// Replace all object of [prefix] with new [items], returns [items].
  ///
  /// All objects are [transform]ed to [String], then stored to database as
  /// [prefix]/[id].
  Future<List<T>> putPrefix<T>(
      String prefix, List<T> items, String Function(T) id, ToJson<T> toJson,
      {bool purge = false}) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return items;
    }
    if (purge) {
      await kvStore.rangeDelete('$_prefix/$prefix');
    }
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
  /// [CanvasRestClient], and produce two streams of type `Stream<T>`.
  Stream<Stream<T>> _getPaginatedStreamStream<T>(
      String prefix,
      FromJson<T> fromJson,
      ToJson<T> toJson,
      ListPaginated<T> listPaginated,
      GetId getId,
      {ScanOrder? order}) async* {
    // First, yield results from database
    yield Stream.fromIterable(await scanPrefix(prefix, fromJson, order: order));
    if (!_offline) {
      final stream = () async* {
        // Then, yield return from REST API and put them back into database
        await for (final item in PaginatedList<T>(listPaginated).all()) {
          await putObject('$prefix${getId(item)}', item, toJson);
          yield item;
        }
      };
      yield stream();
    }
  }

  /// Fetch a [PaginatedList] either from [KvStore] or [CanvasRestClient],
  /// and produce a stream of type `T`.
  Future<Stream<T>> _getPaginatedStreamFuture<T>(
      String prefix,
      FromJson<T> fromJson,
      ToJson<T> toJson,
      ListPaginated<T> listPaginated,
      GetId getId,
      {ScanOrder? order}) async {
    if (!_offline) {
      final stream = () async* {
        await for (final item in PaginatedList<T>(listPaginated).all()) {
          await putObject('$prefix${getId(item)}', item, toJson);
          yield item;
        }
      };
      return stream();
    } else {
      return Stream.fromIterable(
          await scanPrefix(prefix, fromJson, order: order));
    }
  }

  /// Fetch a [PaginatedList] sequentially from [KvStore] and
  /// [CanvasRestClient], and produce a stream of type `List<T>`.
  Stream<List<T>> _getPaginatedListStream<T>(
      String prefix,
      FromJson<T> fromJson,
      ToJson<T> toJson,
      ListPaginated<T> listPaginated,
      GetId getId,
      {ScanOrder? order}) async* {
    // First, yield results from database
    yield await scanPrefix(prefix, fromJson, order: order);
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
      GetId getId,
      {ScanOrder? order}) async {
    if (!_offline) {
      return await putPrefix(prefix,
          await PaginatedList<T>(listPaginated).all().toList(), getId, toJson);
    } else {
      return await scanPrefix(prefix, fromJson, order: order);
    }
  }

  /// Fetch an item sequentially from [KvStore] and [CanvasRestClient],
  /// and produce a stream of type `T`. If none of the endpoints are available,
  /// no items will yield.
  Stream<T> _getItemStream<T>(String key, FromJson<T> fromJson,
      ToJson<T> toJson, GetItem<T> getItem) async* {
    final stream = () async* {
      yield await getObject(key, fromJson);
      yield await putObject(key, await toResponse(_logger, getItem), toJson);
    };
    await for (final item in stream()) {
      if (item != null) yield item;
    }
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

  List<Course> listToCourse(List<MaybeCourse> courseList) {
    return courseList.map((e) => e.toCourse()).whereType<Course>().toList();
  }

  /// Returns a stream of active courses for the current user.
  Stream<List<Course>> getCourses() {
    return _getPaginatedListStream<MaybeCourse>(
        'courses/by_id/',
        (e) => MaybeCourse.fromJson(e),
        (e) => e.toJson(),
        _restClient.getCourses,
        (e) => e.id.toString()).map(listToCourse);
  }

  /// Returns a stream of active courses for the current user.
  Future<List<Course>> getCoursesF() async {
    return _getPaginatedListFuture<MaybeCourse>(
        'courses/by_id/',
        (e) => MaybeCourse.fromJson(e),
        (e) => e.toJson(),
        _restClient.getCourses,
        (e) => e.id.toString()).then(listToCourse);
  }

  String _getCoursePrefix(id) => 'courses/by_id/$id';

  /// Returns information on a single course.
  Stream<Course> getCourse(int id) {
    return _getItemStream(_getCoursePrefix(id), (e) => Course.fromJson(e),
        (e) => e.toJson(), () => _restClient.getCourse(id));
  }

  /// Returns information on a single course.
  Future<Course?> getCourseF(int id) {
    return _getItemFuture(_getCoursePrefix(id), (e) => Course.fromJson(e),
        (e) => e.toJson(), () => _restClient.getCourse(id));
  }

  String _getTabPrefix(id) => 'tabs/course/by_id/$id/';

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

  /// Returns current user.
  Stream<User> getCurrentUser() {
    return _getItemStream('users/self', (e) => User.fromJson(e),
        (e) => e.toJson(), _restClient.getCurrentUser);
  }

  /// Returns current user.
  Future<User?> getCurrentUserF() {
    return _getItemFuture('users/self', (e) => User.fromJson(e),
        (e) => e.toJson(), _restClient.getCurrentUser);
  }

  /// Returns the current user's global activity stream
  Future<Stream<ActivityItem>> getCurrentUserActivityStreamF() {
    return _getPaginatedStreamFuture(
        'activity_stream/by_id/',
        (e) => ActivityItem.fromJson(e),
        (e) => e.toJson(),
        ({queries}) =>
            _restClient.getCurrentUserActivityStream(queries: queries),
        (e) => e.id.toString(),
        order: ScanOrder.desc);
  }

  /// Returns the current user's global activity stream
  Stream<Stream<ActivityItem>> getCurrentUserActivityStream() {
    return _getPaginatedStreamStream(
        'activity_stream/by_id/',
        (e) => ActivityItem.fromJson(e),
        (e) => e.toJson(),
        ({queries}) =>
            _restClient.getCurrentUserActivityStream(queries: queries),
        (e) => e.id.toString(),
        order: ScanOrder.desc);
  }

  /// List available modules for a course.
  Future<List<Module>> getModulesF(int id) {
    return _getPaginatedListFuture(
        _getTabPrefix(id),
        (e) => Module.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getModules(id, queries: queries),
        (e) => e.id.toString());
  }

  /// List available modules for a course.
  Stream<List<Module>> getModules(int id) {
    return _getPaginatedListStream(
        _getTabPrefix(id),
        (e) => Module.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getModules(id, queries: queries),
        (e) => e.id.toString());
  }
}
