import 'package:get/get.dart';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/buffer_api/kvstore.dart';
import 'package:kanbasu/models/activity_item.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/folder.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/planner.dart';
import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/utils/logging.dart';
import 'package:logger/logger.dart';

class ResolveProgress {
  final double percent;
  final String message;

  ResolveProgress({required this.percent, required this.message});

  ResolveProgress prepend(String moduleName) {
    return ResolveProgress(percent: percent, message: '$moduleName / $message');
  }
}

class Resolver {
  /// [Resolver] will try accessing all available endpoint of Canvas LMS, and
  /// making Kanbasu offline-capable.

  final KvStore keyspace;
  final CanvasBufferClient _api;
  final Logger _logger;

  Resolver(CanvasRestClient rest, this.keyspace, this._logger)
      : _api = CanvasBufferClient(rest, keyspace);

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

    yield ofCurrent('解析用户日程', 1, 1);
    final planners = await _api.getPlanners().last;
    await for (final _ in visitPlanners(planners)) {}

    yield ofCurrent('解析用户动态', 1, 1);
    final activities = await _api.getCurrentUserActivityStream().last;
    await for (final _ in visitActivities(activities)) {}

    // final courses = await _api.getCourses().last;
    // await for (final progress in visitCourses(courses)) {
    //   yield progress;
    // }
  }

  /// Visit Stream of [ActivityItem].
  Stream<ResolveProgress> visitActivities(
      Stream<ActivityItem> activities) async* {
    _logger.i('[Visitor] Activities');

    await activities.handleError(onError).toList();
  }

  /// Visit Stream of [Planner].
  Stream<ResolveProgress> visitPlanners(Stream<Planner> planners) async* {
    _logger.i('[Visitor] Planners');

    await planners.handleError(onError).toList();
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

    final total = 4;

    final folders = await _api.getFolders(course.id).last;
    yield ofCurrent('解析文件夹', 0, total);
    await for (final progress in visitFolders(folders)) {
      yield ofTotal(progress.prepend('文件夹'), 0, total);
    }

    final files = await _api.getFiles(course.id).last;
    yield ofCurrent('解析文件', 0, total);
    await for (final progress in visitFiles(files)) {
      yield ofTotal(progress.prepend('文件'), 1, total);
    }

    final assignments = await _api.getAssignments(course.id).last;
    yield ofCurrent('解析作业', 0, total);
    await for (final progress in visitAssignments(assignments)) {
      yield ofTotal(progress.prepend('作业'), 2, total);
    }

    final modules = await _api.getModules(course.id).last;
    yield ofCurrent('解析单元', 0, total);
    await for (final progress in visitModules(course, modules)) {
      yield ofTotal(progress.prepend('单元'), 3, total);
    }
  }

  /// Visit stream of [File].
  Stream<ResolveProgress> visitFiles(Stream<File> files) async* {
    _logger.i('[Visitor] Files');

    await files.handleError(onError).toList();
  }

  /// Visit stream of [Folder].
  Stream<ResolveProgress> visitFolders(Stream<Folder> folders) async* {
    _logger.i('[Visitor] Folders');

    await folders.handleError(onError).toList();
  }

  /// Visit stream of [Assignment].
  Stream<ResolveProgress> visitAssignments(
      Stream<Assignment> assignments) async* {
    _logger.i('[Visitor] Assignments');

    await assignments.handleError(onError).toList();
  }

  /// Visit stream of [Module].
  Stream<ResolveProgress> visitModules(
      Course course, Stream<Module> modules) async* {
    _logger.i('[Visitor] Modules');

    await for (final module in modules) {
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
        .handleError(onError)
        .toList();
  }
}
