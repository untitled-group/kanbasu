import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

import 'tab_mock.dart';
import 'course_mock.dart';
import 'user_mock.dart';

ResponseBody jsonResponse(content, {String? link}) {
  if (link == null) {
    return ResponseBody.fromString(content, 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  } else {
    return ResponseBody.fromString(content, 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      'Link': [link]
    });
  }
}

class MockAdapter extends HttpClientAdapter {
  static const String mockHost = 'mockserver';
  static const String mockBase = 'http://$mockHost';
  final DefaultHttpClientAdapter _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    final uri = options.uri;
    if (uri.host == mockHost) {
      switch (uri.path) {
        case '/courses/23333':
          return jsonResponse(singleCourse);
        case '/courses':
          if (uri.queryParameters['page'] == '2') {
            return jsonResponse(courseResponse2, link: getCoursesLink2);
          } else {
            return jsonResponse(courseResponse, link: getCoursesLink);
          }
        case '/courses/23333/tabs':
          return jsonResponse(tabResponse);
        case '/users/self':
          return jsonResponse(currentUserResponse);
        case '/users/23334':
          return jsonResponse(currentUserResponse);
        case '/users/self/activity_stream':
          return jsonResponse(activityStreamResponse);
        default:
          return ResponseBody.fromString('Mock HTTP 404 Error', 404);
      }
    }
    return _adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}