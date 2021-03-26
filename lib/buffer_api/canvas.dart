import 'dart:async';
import 'dart:convert';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/assignment.dart';
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
Future<T> toResponse<T>(
    Logger logger, Future<HttpResponse<T>> Function() sendRequest) async {
  final response = await sendRequest();
  return response.data;
}

class CanvasBufferClient {
  /// [CanvasBufferClient] combines result from [CanvasRestClient] and
  /// sqlite cache. If a REST API returns a paginated list, it will be parsed
  /// and returned as an iterator.
  ///
  /// Currently, there are two styles of APIs.
  /// * Backupable API returns a Stream, which is guranteed to yield two
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
  Future<void> putPrefix<T>(
      String prefix, List<T> items, String Function(T) id, ToJson<T> toJson,
      {bool purge = false}) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return;
    }
    if (purge) {
      await kvStore.rangeDelete('$_prefix/$prefix');
    }
    for (final item in items) {
      await kvStore.setItem(
          '$_prefix/$prefix${id(item)}', json.encode(toJson(item)));
    }
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
  Future<void> putObject<T>(String key, T? item, ToJson<T> toJson) async {
    final kvStore = _kvStore;
    if (kvStore == null) {
      return;
    }
    if (item == null) {
      return;
    }
    await kvStore.setItem('$_prefix/$key', json.encode(toJson(item)));
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
    final kvStoreResult = await scanPrefix(prefix, fromJson, order: order);
    _logger.v('[KvStore] scan $prefix => ${kvStoreResult.length} entries');
    yield Stream.fromIterable(kvStoreResult);
    if (!_offline) {
      final stream = () async* {
        var itemCount = 0;
        final items = List<T>.empty(growable: true);
        // Then, yield return from REST API and put them back into database
        await for (final item in PaginatedList<T>(listPaginated).all()) {
          items.add(item);
          yield item;
          itemCount += 1;
        }
        _logger.v('[REST] scan $prefix => $itemCount entries');
        // batch add into KvStore
        await putPrefix<T>(prefix, items, getId, toJson);
      };
      yield stream();
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
    final kvStoreResult = await scanPrefix(prefix, fromJson, order: order);
    _logger.v('[KvStore] scan $prefix => ${kvStoreResult.length} entries');
    yield kvStoreResult;
    if (!_offline) {
      // Then, yield return from REST API and put them back into database
      final restResult = await PaginatedList<T>(listPaginated).all().toList();
      _logger.v('[REST] scan $prefix => ${restResult.length} entries');
      yield restResult;
      await putPrefix(prefix, restResult, getId, toJson);
    }
  }

  /// Fetch an item sequentially from [KvStore] and [CanvasRestClient],
  /// and produce a stream of type `T?`.
  Stream<T?> _getItemStream<T>(String key, FromJson<T> fromJson,
      ToJson<T> toJson, GetItem<T> getItem) async* {
    final kvStoreResult = await getObject(key, fromJson);
    _logger.v('[KvStore] get $key');
    yield kvStoreResult;
    final restResult = await toResponse(_logger, getItem);
    _logger.v('[REST] get $key');
    yield restResult;
    await putObject(key, restResult, toJson);
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

  String _getCoursePrefix(id) => 'courses/by_id/$id';

  /// Returns information on a single course.
  Stream<Course?> getCourse(int id) {
    return _getItemStream(_getCoursePrefix(id), (e) => Course.fromJson(e),
        (e) => e.toJson(), () => _restClient.getCourse(id));
  }

  String _getTabPrefix(id) => 'courses/$id/tabs/';

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
  Stream<User?> getCurrentUser() {
    return _getItemStream('users/self', (e) => User.fromJson(e),
        (e) => e.toJson(), _restClient.getCurrentUser);
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

  String _getModulePrefix(id) => 'courses/$id/modules/by_id/';

  /// List available modules for a course.
  Stream<Stream<Module>> getModules(int id) {
    return _getPaginatedStreamStream(
        _getModulePrefix(id),
        (e) => Module.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getModules(id, queries: queries),
        (e) => e.id.toString());
  }

  String _getAssignmentPrefix(id) => 'courses/$id/assignments/by_id/';

  /// List available modules for a course.
  Stream<Stream<Assignment>> getAssignments(int id) {
    return _getPaginatedStreamStream(
        _getAssignmentPrefix(id),
        (e) => Assignment.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getAssignments(id, queries: queries),
        (e) => e.id.toString());
  }
}
