import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/models/course.dart';

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

  /// Resolve all objects.
  Stream<ResolverProgress> resolve() async* {
    final courses = await _api.getCourses().last;
    await for (final progress in resolveCourses(courses)) {
      yield progress;
    }
  }

  /// Resolve `List<Course>`.
  Stream<ResolverProgress> resolveCourses(List<Course> courses) async* {}
}
