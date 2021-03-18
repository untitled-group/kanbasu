import 'dart:async';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:logger/logger.dart';

import 'package:kanbasu/rest_api/canvas.dart';
import 'package:kanbasu/models/course.dart';
import 'paginated_list.dart';

/// `toResponse` transform an HTTP response to corresponding object.
/// If the HTTP response errored, it will return null.
Future<T?> toResponse<T>(
    Logger logger, Future<HttpResponse<T>> Function() sendRequest) async {
  try {
    final response = await sendRequest();
    return response.data;
  } on DioError catch (e) {
    logger.w('${e.error} w/response ${e.response}');
  }
  return null;
}

class CanvasBufferClient {
  /// [CanvasBufferClient] combines result from [CanvasRestClient] and
  /// sqlite cache. If a REST API returns a paginated list, it will be parsed
  /// and returned as an iterator.

  // static const String _kvprefix = 'kanbasu/api_cache/';
  final CanvasRestClient restClient;
  final Logger logger = Logger();

  CanvasBufferClient(this.restClient);

  /// Returns a stream of active courses for the current user.
  Stream<Course> getCourses() {
    return PaginatedList<Course>(restClient.getCourses).all();
  }

  /// Returns information on a single course.
  Future<Course?> getCourse(int id) {
    return toResponse(logger, () => restClient.getCourse(id));
  }
}
