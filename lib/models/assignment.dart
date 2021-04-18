import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'assignment.g.dart';

abstract class Assignment implements Built<Assignment, AssignmentBuilder> {
  Assignment._();

  factory Assignment([Function(AssignmentBuilder b) updates]) = _$Assignment;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'description')
  String get description;
  @BuiltValueField(wireName: 'due_at')
  DateTime? get dueAt;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Assignment.serializer, this)!
        as Map<String, dynamic>;
  }

  static Assignment fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Assignment.serializer, object)!;
  }

  static Serializer<Assignment> get serializer => _$assignmentSerializer;
}
