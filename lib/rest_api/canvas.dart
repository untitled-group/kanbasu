import 'dart:async';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import 'package:kanbasu/models/maybe_course.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/submission.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/course.dart';
import 'package:kanbasu/models/tab.dart';
import 'package:kanbasu/models/user.dart';
import 'package:kanbasu/models/activity_item.dart';

part 'canvas.g.dart';

@RestApi(baseUrl: 'https://oc.sjtu.edu.cn/api/v1')
abstract class CanvasRestClient {
  /// [CanvasRestClient] covers a subset of Canvas LMS Rest APIs.

  factory CanvasRestClient(Dio dio, {String baseUrl}) = _CanvasRestClient;

  /// Returns the paginated list of active courses for the current user.
  @GET('/courses')
  Future<HttpResponse<List<MaybeCourse>>> getCourses(
      {@Queries() Map<String, dynamic>? queries});

  /// Returns information on a single course.
  @GET('/courses/{id}')
  Future<HttpResponse<Course>> getCourse(@Path() int id);

  /// List available tabs for a course or group.
  @GET('/courses/{id}/tabs')
  Future<HttpResponse<List<Tab>>> getTabs(@Path() int id,
      {@Queries() Map<String, dynamic>? queries});

  /// List available modules for a course or group.
  @GET('/courses/{id}/modules')
  Future<HttpResponse<List<Module>>> getModules(@Path() int id,
      {@Queries() Map<String, dynamic>? queries});

  /// List available assignments for a course or group.
  @GET('/courses/{id}/assignments')
  Future<HttpResponse<List<Assignment>>> getAssignments(@Path() int id,
      {@Queries() Map<String, dynamic>? queries});

  /// List available submissions for an assignment for self.
  @GET('/courses/{course_id}/assignments/{assignment_id}/submissions/{user_id}')
  Future<HttpResponse<Submission>> getSubmission(
      @Path() int course_id, @Path() int assignment_id,
      [@Path() String user_id = 'self']);

  /// List available files for a course.
  @GET('/courses/{id}/files')
  Future<HttpResponse<List<File>>> getFiles(@Path() int id,
      {@Queries() Map<String, dynamic>? queries});

  /// Get current user
  @GET('/users/self')
  Future<HttpResponse<User>> getCurrentUser(
      {@Queries() Map<String, dynamic>? queries});

  /// Returns the current user's global activity stream, paginated
  @GET('/users/self/activity_stream')
  Future<HttpResponse<List<ActivityItem>>> getCurrentUserActivityStream(
      {@Queries() Map<String, dynamic>? queries});
}
