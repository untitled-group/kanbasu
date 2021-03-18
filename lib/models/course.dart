import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final int id;
  final String? name;
  final String? uuid;
  @JsonKey(name: 'course_code')
  final String? courseCode;
  @JsonKey(name: 'enrollment_term_id')
  final int? enrollmentTermId;
  @JsonKey(name: 'start_at')
  final DateTime? startAt;
  @JsonKey(name: 'end_at')
  final DateTime? endAt;
  @JsonKey(name: 'access_restricted_by_date')
  final bool? accessRestrictedByDate;

  Course(
      {required this.id,
      this.name,
      this.uuid,
      this.courseCode,
      this.enrollmentTermId,
      this.startAt,
      this.endAt,
      this.accessRestrictedByDate});

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}
