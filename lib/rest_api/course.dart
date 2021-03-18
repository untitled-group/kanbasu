import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';
part 'course.chopper.dart';

@JsonSerializable()
class ResourceError {
  final String type;
  final String message;

  ResourceError(this.type, this.message);

  static const fromJsonFactory = _$ResourceErrorFromJson;

  Map<String, dynamic> toJson() => _$ResourceErrorToJson(this);
}

@JsonSerializable()
class Course {
  final String id;
  final String name;

  Course(this.id, this.name);

  static const fromJsonFactory = _$CourseFromJson;

  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@ChopperApi(baseUrl: "/courses")
abstract class CourseService extends ChopperService {
  static CourseService create([ChopperClient client]) =>
      _$CourseService(client);

  @Get(path: "/")
  Future<Response<List<Course>>> getCourses();
}
