import 'package:json_annotation/json_annotation.dart';

import 'course.dart';
import 'user.dart';
import 'assignment.dart';

part 'activity.g.dart';

enum ActivityContextType {
  @JsonValue('Course')
  Course,

  @JsonValue('Group')
  Group,
}

enum ActivityType {
  @JsonValue('DiscussionTopic')
  DiscussionTopic,

  @JsonValue('Conversation')
  Conversation,

  @JsonValue('Message')
  Message,

  @JsonValue('Submission')
  Submission,

  @JsonValue('Conference')
  Conference,

  @JsonValue('Collaboration')
  Collaboration,

  @JsonValue('AssessmentRequest')
  AssessmentRequest,

  @JsonValue('Announcement')
  Announcement
}

@JsonSerializable()
class ActivityItem {
  /// [ActivityItem] includes metadata for an activity. For detailed
  /// information, you should manually parse the JSON response.

  final int id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final String title;
  final String? message;
  final ActivityType type;
  @JsonKey(name: 'read_state')
  final bool readState;
  @JsonKey(name: 'context_type')
  final ActivityContextType contextType;

  /// Only available if contextType is `course`.
  @JsonKey(name: 'course_id')
  final int? courseId;

  /// Only available if contextType is `group`.
  @JsonKey(name: 'group_id')
  final int? groupId;
  @JsonKey(name: 'html_url')
  final String htmlUrl;

  /// Only available when [type] is one of: [Submission].
  final User? user;

  /// Only available when [type] is one of: [Submission].
  final Course? course;

  /// Only available when [type] is one of: [Submission].
  final Assignment? assignment;

  // attachments, submission_comments

  ActivityItem(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      this.message,
      required this.type,
      required this.readState,
      required this.contextType,
      this.courseId,
      this.groupId,
      required this.htmlUrl,
      this.user,
      this.course,
      this.assignment});

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityItemToJson(this);
}
