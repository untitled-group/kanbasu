import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'brief_info.g.dart';

abstract class BriefInfo implements Built<BriefInfo, BriefInfoBuilder> {
  BriefInfo._();

  @BuiltValueField()
  String get title;

  @BuiltValueField()
  String? get suffix;

  @BuiltValueField()
  BriefInfoType get type;

  @BuiltValueField()
  int get courseId;

  @BuiltValueField()
  String get courseName;

  @BuiltValueField()
  String get description;

  @BuiltValueField()
  DateTime get createdAt;

  @BuiltValueField()
  String? get url;

  @BuiltValueField()
  DateTime? get dueDate;

  factory BriefInfo([Function(BriefInfoBuilder b) updates]) = _$BriefInfo;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(BriefInfo.serializer, this)!
        as Map<String, dynamic>;
  }

  static BriefInfo fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(BriefInfo.serializer, object)!;
  }

  static Serializer<BriefInfo> get serializer => _$briefInfoSerializer;
}

enum BriefInfoType { announcements, assignment, file, grading, assignmentDue }
