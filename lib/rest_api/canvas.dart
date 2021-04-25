import 'dart:async';
import 'package:kanbasu/models/discussion_topic.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import 'package:kanbasu/models/maybe_course.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/module_item.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:kanbasu/models/submission.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/models/folder.dart';
import 'package:kanbasu/models/page.dart';
import 'package:kanbasu/models/planner.dart';
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
  Future<HttpResponse<List<MaybeCourse>>> getCourses({
    @Query('include[]') List<String> includes = const [
      'syllabus_body',
      'term',
      'course_image',
      'teachers',
    ],
    @Queries() Map<String, dynamic>? queries,
  });

  /// Returns information on a single course.
  @GET('/courses/{id}')
  Future<HttpResponse<Course>> getCourse(
    @Path() int id, {
    @Query('include[]') List<String> includes = const [
      'syllabus_body',
      'term',
      'course_image',
      'teachers',
    ],
  });

  /// List available tabs for a course or group.
  @GET('/courses/{id}/tabs')
  Future<HttpResponse<List<Tab>>> getTabs(@Path() int id,
      {@Queries() Map<String, dynamic>? queries});

  /// List available modules for a course or group.
  @GET('/courses/{id}/modules')
  Future<HttpResponse<List<Module>>> getModules(@Path() int id,
      {@Queries() Map<String, dynamic>? queries});

  /// List a single module for a course or group.
  @GET('/courses/{course_id}/modules/{module_id}')
  Future<HttpResponse<Module>> getModule(
      @Path() int course_id, @Path() int module_id,
      {@Queries() Map<String, dynamic>? queries});

  @GET('/courses/{course_id}/modules/{module_id}/items')
  Future<HttpResponse<List<ModuleItem>>> getModuleItems(
      @Path() int course_id, @Path() int module_id,
      {@Queries() Map<String, dynamic>? queries});

  @GET('/courses/{course_id}/modules/{module_id}/items/{item_id}')
  Future<HttpResponse<ModuleItem>> getModuleItem(
      @Path() int course_id, @Path() int module_id, @Path() int item_id,
      {@Queries() Map<String, dynamic>? queries});

  /// List available assignments for a course or group.
  @GET('/courses/{id}/assignments')
  Future<HttpResponse<List<Assignment>>> getAssignments(@Path() int id,
      {@Query('include[]') List<String> includes = const ['submission'],
      @Queries() Map<String, dynamic>? queries});

  /// Get available submissions for an assignment for self.
  @GET('/courses/{course_id}/assignments/{assignment_id}/submissions/{user_id}')
  Future<HttpResponse<Submission>> getSubmission(
      @Path() int course_id, @Path() int assignment_id,
      [@Path() String user_id = 'self',
      @Query('include[]') List<String> includes = const [
        'submission_history',
        'submission_comments',
        'rubric_assessment',
        'assignment',
        'visibility',
        'course',
        'user',
        'group'
      ]]);

  /// List available submissions for a course.
  @GET('/courses/{course_id}/students/submissions')
  Future<HttpResponse<List<Submission>>> getSubmissions(@Path() int course_id,
      {@Query('include[]') List<String> includes = const [
        'submission_history',
        'submission_comments',
        'rubric_assessment',
        'assignment',
        'visibility',
        'course',
        'user',
        'group'
      ],
      @Queries() Map<String, dynamic>? queries});

  /// List available files for a course.
  @GET('/courses/{course_id}/files')
  Future<HttpResponse<List<File>>> getFiles(@Path() int course_id,
      {@Queries() Map<String, dynamic>? queries});

  /// Get information about a single file.
  @GET('/courses/{course_id}/files/{file_id}')
  Future<HttpResponse<File>> getFile(@Path() int course_id, @Path() int file_id,
      {@Queries() Map<String, dynamic>? queries});

  /// List available folders for a course.
  @GET('/courses/{course_id}/folders')
  Future<HttpResponse<List<Folder>>> getFolders(@Path() int course_id,
      {@Queries() Map<String, dynamic>? queries});

  /// Get information about a single folder.
  @GET('/courses/{course_id}/folders/{folder_id}')
  Future<HttpResponse<Folder>> getFolder(
      @Path() int course_id, @Path() int folder_id,
      {@Queries() Map<String, dynamic>? queries});

  /// List available pages for a course.
  @GET('/courses/{course_id}/pages')
  Future<HttpResponse<List<Page>>> getPages(@Path() int course_id,
      {@Queries() Map<String, dynamic>? queries});

  /// Get information about a single page.
  @GET('/courses/{course_id}/pages/{page_id}')
  Future<HttpResponse<Page>> getPage(@Path() int course_id, @Path() int page_id,
      {@Queries() Map<String, dynamic>? queries});

  /// Get information about planners.
  @GET('/planner/items')
  Future<HttpResponse<List<Planner>>> getPlanners(
      {@Queries() Map<String, dynamic>? queries});

  /// Get current user
  @GET('/users/self')
  Future<HttpResponse<User>> getCurrentUser(
      {@Queries() Map<String, dynamic>? queries});

  /// Returns the current user's global activity stream, paginated
  @GET('/users/self/activity_stream')
  Future<HttpResponse<List<ActivityItem>>> getCurrentUserActivityStream(
      {@Queries() Map<String, dynamic>? queries});

  /// List announcements for some context codes.
  @GET('/announcements')
  Future<HttpResponse<List<DiscussionTopic>>> getAnnouncements(
    @Query('context_codes[]') List<String> contextCodes, {
    @Query('start_date') String startDate = '1970-01-01',
    @Query('end_date') String endDate = '9999-01-01',
    @Queries() Map<String, dynamic>? queries,
  });
}
