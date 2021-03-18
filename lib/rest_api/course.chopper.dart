// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$CourseService extends CourseService {
  _$CourseService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = CourseService;

  @override
  Future<Response<List<Course>>> getCourses() {
    final $url = '/courses/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<Course>, Course>($request);
  }
}
