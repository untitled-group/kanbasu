import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
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

  factory ActivityItem([Function(ActivityItemBuilder b) updates]) =
      _$ActivityItem;

  @BuiltValueField(wireName: 'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: 'id')
  int get id;

  @BuiltValueField(wireName: 'title')
  String get title;

  /// One of `AssessmentRequest`, `Announcement`, `Collaboration`, `Conference`,
  /// `Submission`, `Message`, `Conversation`, `DiscussionTopic`
  @BuiltValueField(wireName: 'type')
  String get type;

  @BuiltValueField(wireName: 'read_state')
  bool get readState;

  /// One of `Course`, `Group`.
  @BuiltValueField(wireName: 'context_type')
  String get contextType;

  /// Only available when [contextType] is one of: `Course`.
  @BuiltValueField(wireName: 'course_id')
  int? get courseId;

  /// Only available when [contextType] is one of: `Group`.
  @BuiltValueField(wireName: 'group_id')
  int? get groupId;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;

  // **************************************************************************
  // Conversation related fields
  // **************************************************************************

  /// Only available when [type] is one of: [Conversation].
  @BuiltValueField(wireName: 'conversation_id')
  int? get conversationId;

  /// Only available when [type] is one of: [Conversation].
  @BuiltValueField(wireName: 'participant_count')
  int? get participantCount;

  /// Only available when [type] is one of: [Conversation].
  bool? get private;

  // **************************************************************************
  // Announcement related fields
  // **************************************************************************

  /// Only available when [type] is one of: [Announcement], [Message],
  /// [DiscussionTopic].
  String? get message;

  /// Only available when [type] is one of: [Announcement].
  @BuiltValueField(wireName: 'announcement_id')
  int? get announcementId;

  // **************************************************************************
  // Message related fields
  // **************************************************************************

  /// Only available when [type] is one of: [Message].
  @BuiltValueField(wireName: 'notification_category')
  String? get notificationCategory;

  /// Only available when [type] is one of: private [Message].
  @BuiltValueField(wireName: 'message_id')
  int? get messageId;

  // **************************************************************************
  // DiscussionTopic related fields
  // **************************************************************************
  @BuiltValueField(wireName: 'discussion_topic_id')
  int? get discussionTopicId;

  // **************************************************************************
  // Submission related fields
  // **************************************************************************

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'body')
  String? get body;

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'submitted_at')
  DateTime? get submittedAt;

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'assignment_id')
  int? get assignmentId;

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'submission_id')
  int? get submissionId;

  /// Only available when [type] is one of: [Submission].
  @BuiltValueField(wireName: 'workflow_state')
  String? get workflowState;

  /// Only available when [type] is [Submission] and [workflowState] is `graded`.
  @BuiltValueField(wireName: 'graded_at')
  DateTime? get gradedAt;

  /// Only available when [type] is [Submission] and [workflowState] is `graded`.
  @BuiltValueField(wireName: 'grader_id')
  int? get graderId;

  /// Only available when [type] is [Submission] and [workflowState] is `graded`.
  double? get score;

  /// Only available when [type] is [Submission] and [workflowState] is `graded`.
  String? get grade;

  /// Only available when [type] is [Submission] and [workflowState] is `graded`.
  int? get attempt;

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
