import 'dart:async';
import 'dart:convert';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/models/discussion_topic.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/module_item.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/submission.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/folder.dart';
import 'package:kanbasu/models/page.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:retrofit/retrofit.dart';
import 'package:logger/logger.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/maybe_course.dart';
import 'package:kanbasu/models/tab.dart';
import 'package:kanbasu/models/user.dart';
import 'package:kanbasu/types.dart';
import 'package:kanbasu/utils/logging.dart';
import 'paginated_list.dart';
import 'package:rxdart/rxdart.dart';

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
  final Logger _logger = createLogger();
  bool _offline = false;

  CanvasBufferClient(this._restClient, [this._kvStore]);

  KvStore? get kvStore => _kvStore;

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
  /// [CanvasRestClient], and produce a two-item list of type `Stream<T>`.
  List<Stream<T>> _getPaginatedStreamStream<T>(
      String prefix,
      FromJson<T> fromJson,
      ToJson<T> toJson,
      ListPaginated<T> listPaginated,
      GetId getId,
      {ScanOrder? order,
      bool purge = false}) {
    // First, yield results from database

    final kvStream = () async* {
      final kvStoreResult = await scanPrefix(prefix, fromJson, order: order);
      _logger.v('[KvStore] scan $prefix => ${kvStoreResult.length} entries');
      for (final item in kvStoreResult) {
        yield item;
      }
    };

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
        await putPrefix<T>(prefix, items, getId, toJson, purge: purge);
      };
      return List.of([kvStream(), stream()], growable: false);
    }
    return List.of([kvStream()], growable: false);
  }

  /// Fetch an item sequentially from [KvStore] and [CanvasRestClient],
  /// and produce a stream of type `T?`.
  List<Future<T?>> _getItemStream<T>(
      String key, FromJson<T> fromJson, ToJson<T> toJson, GetItem<T> getItem) {
    final kvFuture = () async {
      final kvStoreResult = await getObject(key, fromJson);
      _logger.v('[KvStore] get $key');
      return kvStoreResult;
    };
    if (!_offline) {
      final restFuture = () async {
        final restResult = await toResponse(_logger, getItem);
        _logger.v('[REST] get $key');
        await putObject(key, restResult, toJson);
        return restResult;
      };
      return List.of([kvFuture(), restFuture()], growable: false);
    }
    return List.of([kvFuture()], growable: false);
  }

  // **************************************************************************
  // Add new REST APIs below
  // **************************************************************************

  Stream<Course> onlyCourse(Stream<MaybeCourse> courseList) {
    return courseList.map((e) => e.toCourse()).whereType<Course>();
  }

  /// Returns a stream of active courses for the current user.
  List<Stream<Course>> getCourses() {
    return _getPaginatedStreamStream<MaybeCourse>(
            'courses/by_id/',
            (e) => MaybeCourse.fromJson(e),
            (e) => e.toJson(),
            _restClient.getCourses,
            (e) => e.id.toString(),
            purge: true)
        .map(onlyCourse)
        .toList(growable: false);
  }

  String _getCoursePrefix(id) => 'courses/by_id/$id';

  /// Returns information on a single course.
  List<Future<Course?>> getCourse(int id) {
    return _getItemStream(_getCoursePrefix(id), (e) => Course.fromJson(e),
        (e) => e.toJson(), () => _restClient.getCourse(id));
  }

  String _getTabPrefix(id) => 'courses/$id/tabs/';

  /// List available tabs for a course or group.
  List<Stream<Tab>> getTabs(int id) {
    return _getPaginatedStreamStream(
        _getTabPrefix(id),
        (e) => Tab.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getTabs(id, queries: queries),
        (e) => e.id);
  }

  /// Returns current user.
  List<Future<User?>> getCurrentUser() {
    return _getItemStream('users/self', (e) => User.fromJson(e),
        (e) => e.toJson(), _restClient.getCurrentUser);
  }

  /// Returns the current user's global activity stream
  List<Stream<ActivityItem>> getCurrentUserActivityStream() {
    return _getPaginatedStreamStream(
        'activity_stream/by_id/',
        (e) => ActivityItem.fromJson(e),
        (e) => e.toJson(),
        ({queries}) =>
            _restClient.getCurrentUserActivityStream(queries: queries),
        (e) => e.id.toString(),
        order: ScanOrder.desc);
  }

  String _getModulesPrefix(id) => 'courses/$id/modules/by_id/';

  /// List available modules for a course.
  List<Stream<Module>> getModules(int id) {
    return _getPaginatedStreamStream(
        _getModulesPrefix(id),
        (e) => Module.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getModules(id, queries: queries),
        (e) => e.id.toString());
  }

  String _getModulePrefix(course_id, module_id) =>
      'courses/$course_id/modules/by_id/$module_id';

  /// List single module for a course.
  List<Future<Module?>> getModule(int course_id, int module_id) {
    return _getItemStream(
        _getModulePrefix(course_id, module_id),
        (e) => Module.fromJson(e),
        (e) => e.toJson(),
        () => _restClient.getModule(course_id, module_id));
  }

  String _getModuleItemsPrefix(course_id, module_id) =>
      'courses/$course_id/modules/$module_id/items/by_id/';

  /// List single module for a course.
  List<Stream<ModuleItem>> getModuleItems(int course_id, int module_id) {
    return _getPaginatedStreamStream(
        _getModuleItemsPrefix(course_id, module_id),
        (e) => ModuleItem.fromJson(e),
        (e) => e.toJson(),
        ({queries}) =>
            _restClient.getModuleItems(course_id, module_id, queries: queries),
        (e) => e.id.toString());
  }

  String _getModuleItemPrefix(course_id, module_id, item_id) =>
      'courses/$course_id/modules/$module_id/items/by_id/$item_id';

  /// List single module for a course.
  List<Future<ModuleItem?>> getModuleItem(
      int course_id, int module_id, item_id) {
    return _getItemStream(
        _getModuleItemPrefix(course_id, module_id, item_id),
        (e) => ModuleItem.fromJson(e),
        (e) => e.toJson(),
        () => _restClient.getModuleItem(course_id, module_id, item_id));
  }

  String _getAssignmentPrefix(id) => 'courses/$id/assignments/by_id/';

  /// List available assignments for a course.
  List<Stream<Assignment>> getAssignments(int id) {
    return _getPaginatedStreamStream(
        _getAssignmentPrefix(id),
        (e) => Assignment.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getAssignments(id, queries: queries),
        (e) => e.id.toString());
  }

  String _getSubmissionPrefix(course_id, assignment_id, user_id) =>
      'courses/$course_id/assignments/$assignment_id/submissions/$user_id';

  /// Get available submission for an assignment.
  List<Future<Submission?>> getSubmission(int course_id, int assignment_id,
      [String user_id = 'self']) {
    return _getItemStream(
        _getSubmissionPrefix(course_id, assignment_id, user_id),
        (e) => Submission.fromJson(e),
        (e) => e.toJson(),
        () => _restClient.getSubmission(course_id, assignment_id, user_id));
  }

  // FIXME: submissions cannot be cached independently
  String _getSubmissionsPrefix(course_id) =>
      'courses/$course_id/submissions/by_id/';

  /// List available submissions for an assignment.
  List<Stream<Submission>> getSubmissions(int course_id) {
    return _getPaginatedStreamStream(
        _getSubmissionsPrefix(course_id),
        (e) => Submission.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getSubmissions(course_id, queries: queries),
        (e) => e.id.toString());
  }

  String _getFilesPrefix(course_id) => 'courses/$course_id/files/by_id/';

  /// List available files for a course.
  List<Stream<File>> getFiles(int course_id) {
    return _getPaginatedStreamStream(
        _getFilesPrefix(course_id),
        (e) => File.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getFiles(course_id, queries: queries),
        (e) => e.id.toString());
  }

  String _getFilePrefix(course_id, file_id) =>
      'courses/$course_id/files/by_id/$file_id';

  /// List a specific file.
  List<Future<File?>> getFile(int course_id, int file_id) {
    return _getItemStream(
        _getFilePrefix(course_id, file_id),
        (e) => File.fromJson(e),
        (e) => e.toJson(),
        () => _restClient.getFile(course_id, file_id));
  }

  String _getPagesPrefix(course_id) => 'courses/$course_id/pages/by_id/';

  /// List available pages for a course.
  List<Stream<Page>> getPages(int course_id) {
    return _getPaginatedStreamStream(
        _getPagesPrefix(course_id),
        (e) => Page.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getPages(course_id, queries: queries),
        (e) => e.pageId.toString());
  }

  String _getPagePrefix(course_id, page_id) =>
      'courses/$course_id/pages/by_id/$page_id';

  /// List a specific page.
  List<Future<Page?>> getPage(int course_id, int page_id) {
    return _getItemStream(
        _getPagePrefix(course_id, page_id),
        (e) => Page.fromJson(e),
        (e) => e.toJson(),
        () => _restClient.getPage(course_id, page_id));
  }

  String _getPlannersPrefix() => 'planners/by_id/';

  /// List available planners for a course.
  List<Stream<Planner>> getPlanners() {
    return _getPaginatedStreamStream(
        _getPlannersPrefix(),
        (e) => Planner.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getPlanners(queries: queries),
        (e) => e.plannableId.toString());
  }

  String _getFoldersPrefix(course_id) => 'courses/$course_id/folders/by_id/';

  /// List available folders for a course.
  List<Stream<Folder>> getFolders(int course_id) {
    return _getPaginatedStreamStream(
        _getFoldersPrefix(course_id),
        (e) => Folder.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient.getFolders(course_id, queries: queries),
        (e) => e.id.toString());
  }

  String _getFolderPrefix(course_id, folder_id) =>
      'courses/$course_id/folders/by_id/$folder_id';

  /// List a specific file.
  List<Future<Folder?>> getFolder(int course_id, int folder_id) {
    return _getItemStream(
        _getFolderPrefix(course_id, folder_id),
        (e) => Folder.fromJson(e),
        (e) => e.toJson(),
        () => _restClient.getFolder(course_id, folder_id));
  }

  String _getAnnouncementsPrefix(course_id) =>
      'courses/$course_id/announcements/by_id/';

  /// List announcements for a course.
  List<Stream<DiscussionTopic>> getAnnouncements(int course_id) {
    return _getPaginatedStreamStream(
        _getAnnouncementsPrefix(course_id),
        (e) => DiscussionTopic.fromJson(e),
        (e) => e.toJson(),
        ({queries}) => _restClient
            .getAnnouncements(['course_$course_id'], queries: queries),
        (e) => e.id.toString());
  }
}
