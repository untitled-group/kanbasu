import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'user.dart';
import 'course.dart';
import 'assignment.dart';

import 'serializers.dart';

part 'activity_item.g.dart';

abstract class ActivityItem
    implements Built<ActivityItem, ActivityItemBuilder> {
  /// [ActivityItem] includes metadata for an activity. For detailed
  /// information, you should manually parse the JSON response.

  ActivityItem._();

  factory ActivityItem([updates(ActivityItemBuilder b)]) = _$ActivityItem;

  @BuiltValueField(wireName: 'created_at')
  String get createdAt;
  @BuiltValueField(wireName: 'updated_at')
  String get updatedAt;
  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'title')
  String get title;
  @BuiltValueField(wireName: 'message')
  String? get message;
  @BuiltValueField(wireName: 'body')
  String? get body;
  @BuiltValueField(wireName: 'type')
  String get type;
  @BuiltValueField(wireName: 'read_state')
  bool get readState;
  @BuiltValueField(wireName: 'context_type')
  String get contextType;
  @BuiltValueField(wireName: 'course_id')
  int? get courseId;
  @BuiltValueField(wireName: 'group_id')
  int? get groupId;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'assignment')
  Assignment? get assignment;

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'user')
  User? get user;

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'course')
  Course? get course;

  // attachments, submission_comments

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ActivityItem.serializer, this)!
        as Map<String, dynamic>;
  }

  static ActivityItem fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(ActivityItem.serializer, object)!;
  }

  static Serializer<ActivityItem> get serializer => _$activityItemSerializer;
}

// enum ActivityContextType {
//   @JsonValue('Course')
//   Course,

//   @JsonValue('Group')
//   Group,
// }

// enum ActivityType {
//   @JsonValue('DiscussionTopic')
//   DiscussionTopic,

//   @JsonValue('Conversation')
//   Conversation,

//   @JsonValue('Message')
//   Message,

//   @JsonValue('Submission')
//   Submission,

//   @JsonValue('Conference')
//   Conference,

//   @JsonValue('Collaboration')
//   Collaboration,

//   @JsonValue('AssessmentRequest')
//   AssessmentRequest,

//   @JsonValue('Announcement')
//   Announcement
// }
