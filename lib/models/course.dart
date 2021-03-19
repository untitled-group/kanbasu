import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'course.g.dart';

abstract class Course implements Built<Course, CourseBuilder> {
  Course._();

  factory Course([Function(CourseBuilder b) updates]) = _$Course;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'name')
  String get name;
  @BuiltValueField(wireName: 'uuid')
  String get uuid;
  @BuiltValueField(wireName: 'start_at')
  DateTime get startAt;
  @BuiltValueField(wireName: 'course_code')
  String get courseCode;
  @BuiltValueField(wireName: 'enrollment_term_id')
  int get enrollmentTermId;
  @BuiltValueField(wireName: 'end_at')
  DateTime? get endAt;
  @BuiltValueField(wireName: 'time_zone')
  String get timeZone;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Course.serializer, this)!
        as Map<String, dynamic>;
  }

  static Course fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Course.serializer, object)!;
  }

  static Serializer<Course> get serializer => _$courseSerializer;
}
