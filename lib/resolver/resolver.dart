import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/module.dart';

class ResolverProgress {
  final double percent;
  final String message;

  ResolverProgress({required this.percent, required this.message});
}

class Resolver {
  /// [Resolver] will try accessing all available endpoint of Canvas LMS, and
  /// making Kanbasu offline-capable.

  final CanvasBufferClient _api;

  Resolver(this._api);

  ResolverProgress ofTotal(ResolverProgress progress, int of, int total) =>
      ResolverProgress(
          percent: progress.percent / total + of / total,
          message: progress.message);

  /// Resolve all objects.
  Stream<ResolverProgress> resolve() async* {
    final courses = await _api.getCourses().last;
    await for (final progress in resolveCourses(courses)) {
      yield progress;
    }
  }

  /// Resolve List of [Course].
  Stream<ResolverProgress> resolveCourses(List<Course> courses) async* {
    final length = courses.length;
    var index = 0;
    for (final course in courses) {
      await for (final progress in resolveCourse(course)) {
        yield ofTotal(progress, index, length);
      }
      index += 1;
    }
  }

  /// Resolve [Course].
  Stream<ResolverProgress> resolveCourse(Course course) async* {
    final total = 3;

    final files = await _api.getFiles(course.id).last;
    await for (final progress in resolveFiles(files)) {
      yield ofTotal(progress, 0, total);
    }

    final assignments = await _api.getAssignments(course.id).last;
    await for (final progress in resolveAssignments(assignments)) {
      yield ofTotal(progress, 1, total);
    }

    final modules = await _api.getModules(course.id).last;
    await for (final progress in resolveModules(modules)) {
      yield ofTotal(progress, 2, total);
    }
  }

  /// Resolve stream of [File].
  Stream<ResolverProgress> resolveFiles(Stream<File> files) async* {
    await files.handleError((_) {}).toList();
  }

  /// Resolve stream of [Assignment].
  Stream<ResolverProgress> resolveAssignments(
      Stream<Assignment> assignments) async* {
    await assignments.handleError((_) {}).toList();
  }

  /// Resolve stream of [Module].
  Stream<ResolverProgress> resolveModules(Stream<Module> modules) async* {
    await modules.handleError((_) {}).toList();
  }
}
