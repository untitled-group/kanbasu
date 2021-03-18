import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

final getCoursesResponse = """
[
    {
        "id": 23333,
        "name": "概率统计",
        "account_id": 9,
        "uuid": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "start_at": "2019-09-10T07:49:23Z",
        "grading_standard_id": null,
        "is_public": null,
        "course_code": "(2019-2020-1)-MA119-4-概率统计",
        "default_view": "assignments",
        "root_account_id": 1,
        "enrollment_term_id": 5,
        "end_at": null,
        "public_syllabus": false,
        "public_syllabus_to_auth": false,
        "storage_quota_mb": 1000,
        "is_public_to_auth_users": false,
        "apply_assignment_group_weights": false,
        "calendar": {
            "ics": "https://oc.sjtu.edu.cn/feeds/calendars/course_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.ics"
        },
        "time_zone": "Asia/Shanghai",
        "blueprint": false,
        "enrollments": [
            {
                "type": "student",
                "role": "StudentEnrollment",
                "role_id": 3,
                "user_id": 23333,
                "enrollment_state": "active"
            }
        ],
        "hide_final_grades": false,
        "workflow_state": "available",
        "restrict_enrollments_to_course_dates": false
    },
    {
        "id": 233333,
        "access_restricted_by_date": true
    }
]
""";

final getCoursesLink = """
<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="current",<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="next",<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="first",<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="last"
""";

final getCoursesResponse2 = """
[
    {
        "id": 318720,
        "access_restricted_by_date": true
    }
]
""";

final getCoursesLink2 = """
<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="current",<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="prev",<https://oc.sjtu.edu.cn/api/v1/courses?page=1&per_page=10>; rel="first",<https://oc.sjtu.edu.cn/api/v1/courses?page=2&per_page=10>; rel="last"
""";

final getSingleCourse = """
{
    "id": 23333,
    "name": "概率统计",
    "account_id": 9,
    "uuid": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "start_at": "2019-09-10T07:49:23Z",
    "grading_standard_id": null,
    "is_public": null,
    "course_code": "(2019-2020-1)-MA119-4-概率统计",
    "default_view": "assignments",
    "root_account_id": 1,
    "enrollment_term_id": 5,
    "end_at": null,
    "public_syllabus": false,
    "public_syllabus_to_auth": false,
    "storage_quota_mb": 1000,
    "is_public_to_auth_users": false,
    "apply_assignment_group_weights": false,
    "calendar": {
        "ics": "https://oc.sjtu.edu.cn/feeds/calendars/course_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.ics"
    },
    "time_zone": "Asia/Shanghai",
    "blueprint": false,
    "enrollments": [
        {
            "type": "student",
            "role": "StudentEnrollment",
            "role_id": 3,
            "user_id": 23333,
            "enrollment_state": "active"
        }
    ],
    "hide_final_grades": false,
    "workflow_state": "available",
    "restrict_enrollments_to_course_dates": false
}
""";

class MockAdapter extends HttpClientAdapter {
  static const String mockHost = "mockserver";
  static const String mockBase = "http://$mockHost";
  DefaultHttpClientAdapter _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    Uri uri = options.uri;
    if (uri.host == mockHost) {
      switch (uri.path) {
        case "/courses/23333":
          return ResponseBody.fromString(
            getSingleCourse,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
              "Link": [getCoursesLink2]
            },
          );
        case "/courses":
          if (uri.queryParameters["page"] == "2") {
            return ResponseBody.fromString(
              getCoursesResponse2,
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
                "Link": [getCoursesLink2]
              },
            );
          } else {
            return ResponseBody.fromString(
              getCoursesResponse,
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
                "Link": [getCoursesLink]
              },
            );
          }
        default:
          return ResponseBody.fromString("Mock HTTP 404 Error", 404);
      }
    }
    return _adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}