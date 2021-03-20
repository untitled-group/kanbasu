import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';
import 'course.dart';

part 'maybe_course.g.dart';

abstract class MaybeCourse implements Built<MaybeCourse, MaybeCourseBuilder> {
  MaybeCourse._();

  factory MaybeCourse([Function(MaybeCourseBuilder b) updates]) = _$MaybeCourse;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'name')
  String? get name;
  @BuiltValueField(wireName: 'uuid')
  String? get uuid;
  @BuiltValueField(wireName: 'start_at')
  DateTime? get startAt;
  @BuiltValueField(wireName: 'course_code')
  String? get courseCode;
  @BuiltValueField(wireName: 'enrollment_term_id')
  int? get enrollmentTermId;
  @BuiltValueField(wireName: 'end_at')
  DateTime? get endAt;
  @BuiltValueField(wireName: 'time_zone')
  String? get timeZone;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(MaybeCourse.serializer, this)!
        as Map<String, dynamic>;
  }

  static MaybeCourse fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(MaybeCourse.serializer, object)!;
  }

  Course? toCourse() {
    try {
      return Course.fromJson(toJson());
    } on DeserializationError {
      return null;
    }
  }

  static Serializer<MaybeCourse> get serializer => _$maybeCourseSerializer;
}
