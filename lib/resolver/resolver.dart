import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/folder.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/utils/courses.dart';
import 'package:logger/logger.dart';
import 'package:kanbasu/resolver/resolve_progress.dart';

class Resolver {
  /// [Resolver] will try accessing all available endpoint of Canvas LMS, and
  /// making Kanbasu offline-capable.

  final KvStore _keyspace;
  final KvStore? _cache;
  final CanvasBufferClient _api;
  final Logger _logger;

  Resolver(CanvasRestClient rest, this._keyspace, this._cache, this._logger)
      : _api = CanvasBufferClient(rest, _keyspace);

  ResolveProgress ofCurrent(String message, int of, int current) =>
      ResolveProgress(
          percent: of.toDouble() / current.toDouble(), message: message);

  ResolveProgress ofTotal(ResolveProgress progress, int of, int total) =>
      ResolveProgress(
          percent: progress.percent / total + of / total,
          message: progress.message);

  void onError(dynamic error, StackTrace st) {
    _logger.w('An error occurred when downloading', error, st);
  }

  /// Visit all objects.
  Stream<ResolveProgress> visit() async* {
    _logger.i('[Visitor] Root');

    yield ofCurrent('解析课程数据', 0, 10);
    final courses = await _api.getCourses().last.handleError(onError).toList();
    final latestCourses = toLatestCourses(courses);

    await for (final progress in visitCourses(latestCourses)) {
      yield progress;
    }

    yield ofCurrent('解析用户日程', 8, 10);
    await _api.getPlanners().last.handleError(onError).toList();

    yield ofCurrent('解析用户动态', 9, 10);
    await _api
        .getCurrentUserActivityStream()
        .last
        .handleError(onError)
        .toList();

    yield ofCurrent('写入缓存', 10, 10);

    final cache = _cache;
    if (cache != null) {
      final items = await _keyspace.scan('');
      items.forEach((key, value) async {
        await cache.setItem(key, value);
      });
    }
  }

  /// Visit List of [Course].
  Stream<ResolveProgress> visitCourses(List<Course> courses) async* {
    _logger.i('[Visitor] Courses');

    final length = courses.length;
    var index = 0;
    for (final course in courses) {
      await for (final progress in visitCourse(course)) {
        yield ofTotal(progress.prepend(course.name), index, length);
      }
      index += 1;
    }
  }

  /// Visit [Course].
  Stream<ResolveProgress> visitCourse(Course course) async* {
    _logger.i('[Visitor] Course ${course.name}');

    final total = 9;

    yield ofCurrent('获取可用功能', 0, total);
    await _api.getTabs(course.id).last.handleError(onError).toList();

    yield ofCurrent('解析文件夹', 1, total);
    final folders =
        await _api.getFolders(course.id).last.handleError(onError).toList();
    await for (final progress in visitFolders(folders)) {
      yield ofTotal(progress.prepend('文件夹'), 0, total);
    }

    yield ofCurrent('解析文件', 2, total);
    final files =
        await _api.getFiles(course.id).last.handleError(onError).toList();
    await for (final progress in visitFiles(files)) {
      yield ofTotal(progress.prepend('文件'), 1, total);
    }

    yield ofCurrent('解析作业', 3, total);
    final assignments =
        await _api.getAssignments(course.id).last.handleError(onError).toList();
    await for (final progress in visitAssignments(assignments)) {
      yield ofTotal(progress.prepend('作业'), 2, total);
    }

    yield ofCurrent('解析提交', 4, total);
    await _api.getSubmissions(course.id).last.handleError(onError).toList();

    yield ofCurrent('解析单元', 5, total);
    final modules =
        await _api.getModules(course.id).last.handleError(onError).toList();
    await for (final progress in visitModules(course, modules)) {
      yield ofTotal(progress.prepend('单元'), 4, total);
    }

    yield ofCurrent('解析公告', 6, total);
    await _api.getAnnouncements(course.id).last.handleError(onError).toList();

    yield ofCurrent('解析讨论区', 7, total);
    await _api
        .getDiscussionTopics(course.id)
        .last
        .handleError(onError)
        .toList();

    yield ofCurrent('解析页面', 8, total);
    await _api.getPages(course.id).last.handleError(onError).toList();
  }

  /// Visit stream of [File].
  Stream<ResolveProgress> visitFiles(List<File> files) async* {
    _logger.i('[Visitor] Files');

    // await files.handleError(onError).toList();
  }

  /// Visit stream of [Folder].
  Stream<ResolveProgress> visitFolders(List<Folder> folders) async* {
    _logger.i('[Visitor] Folders');

    // await folders.handleError(onError).toList();
  }

  /// Visit stream of [Assignment].
  Stream<ResolveProgress> visitAssignments(
      List<Assignment> assignments) async* {
    _logger.i('[Visitor] Assignments');

    // await assignments.handleError(onError).toList();
  }

  /// Visit stream of [Module].
  Stream<ResolveProgress> visitModules(
      Course course, List<Module> modules) async* {
    _logger.i('[Visitor] Modules');

    for (final module in modules) {
      yield ofCurrent(module.name, 0, 1);
      await for (final progress in visitModule(course, module)) {
        yield progress;
      }
    }
  }

  /// Visit [Module]
  Stream<ResolveProgress> visitModule(Course course, Module module) async* {
    await _api
        .getModuleItems(course.id, module.id)
        .last
        .handleError(onError)
        .toList();
  }
}
