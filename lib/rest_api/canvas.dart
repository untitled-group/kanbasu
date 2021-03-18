import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'canvas.g.dart';

@JsonSerializable()
class Course {
  final int? id;
  final String? name;
  final String? uuid;
  @JsonKey(name: 'course_code')
  final String? courseCode;
  @JsonKey(name: 'enrollment_term_id')
  final int? enrollmentTermId;

  Course(
      {this.id, this.name, this.uuid, this.courseCode, this.enrollmentTermId});

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@RestApi(baseUrl: "https://oc.sjtu.edu.cn/api/v1")
abstract class CanvasRestClient {
  factory CanvasRestClient(Dio dio, {String baseUrl}) = _CanvasRestClient;
  @GET('/courses')
  Future<HttpResponse<List<Course>>> getCourses(
      {@DioOptions() Options? options});
}
