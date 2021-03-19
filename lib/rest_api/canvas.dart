import 'dart:async';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

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
  Future<HttpResponse<List<Course>>> getCourses(
      {@Queries() Map<String, dynamic>? queries});

  /// Returns information on a single course.
  @GET('/courses/{id}')
  Future<HttpResponse<Course>> getCourse(@Path() int id);

  /// List available tabs for a course or group.
  @GET('/courses/{id}/tabs')
  Future<HttpResponse<List<Tab>>> getTabs(@Path() int id,
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
