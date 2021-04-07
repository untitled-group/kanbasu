library planner;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'planner.g.dart';

abstract class Planner implements Built<Planner, PlannerBuilder> {
  Planner._();

  factory Planner([Function(PlannerBuilder b) updates]) = _$Planner;

  @BuiltValueField(wireName: 'context_type')
  String get contextType;
  @BuiltValueField(wireName: 'course_id')
  int get courseId;
  @BuiltValueField(wireName: 'plannable_id')
  int get plannableId;
  @BuiltValueField(wireName: 'planner_override')
  String? get plannerOverride;
  @BuiltValueField(wireName: 'new_activity')
  bool get newActivity;
  @BuiltValueField(wireName: 'plannable_date')
  DateTime get plannableDate;
  @BuiltValueField(wireName: 'plannable_type')
  String get plannableType;
  @BuiltValueField(wireName: 'plannable')
  Map<String, dynamic> get plannable;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Planner.serializer, this)!
        as Map<String, dynamic>;
  }

  static Planner fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Planner.serializer, object)!;
  }

  static Serializer<Planner> get serializer => _$plannerSerializer;
}
