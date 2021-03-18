// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceError _$ResourceErrorFromJson(Map<String, dynamic> json) {
  return ResourceError(
    json['type'] as String,
    json['message'] as String,
  );
}

Map<String, dynamic> _$ResourceErrorToJson(ResourceError instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
    };

Course _$CourseFromJson(Map<String, dynamic> json) {
  return Course(
    json['id'] as String,
    json['name'] as String,
  );
}

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
