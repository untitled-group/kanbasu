library discussion_topic;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:kanbasu/models/user_display.dart';
import 'package:kanbasu/models/lock_info.dart';
import 'serializers.dart';

part 'discussion_topic.g.dart';

abstract class DiscussionTopic
    implements Built<DiscussionTopic, DiscussionTopicBuilder> {
  DiscussionTopic._();

  factory DiscussionTopic([Function(DiscussionTopicBuilder b) updates]) =
      _$DiscussionTopic;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'title')
  String get title;
  @BuiltValueField(wireName: 'last_reply_at')
  DateTime? get lastReplyAt;
  @BuiltValueField(wireName: 'posted_at')
  DateTime? get postedAt;
  @BuiltValueField(wireName: 'assignment_id')
  int? get assignmentId;
  @BuiltValueField(wireName: 'root_topic_id')
  int? get rootTopicId;
  @BuiltValueField(wireName: 'discussion_type')
  String get discussionType;
  @BuiltValueField(wireName: 'lock_at')
  DateTime? get lockAt;
  @BuiltValueField(wireName: 'user_name')
  String? get userName;
  @BuiltValueField(wireName: 'discussion_subentry_count')
  int get discussionSubentryCount;
  @BuiltValueField(wireName: 'read_state')
  String get readState;
  @BuiltValueField(wireName: 'unread_count')
  int get unreadCount;
  @BuiltValueField(wireName: 'published')
  bool get published;
  @BuiltValueField(wireName: 'locked')
  bool get locked;
  @BuiltValueField(wireName: 'can_lock')
  bool get canLock;
  @BuiltValueField(wireName: 'comments_disabled')
  bool get commentsDisabled;
  @BuiltValueField(wireName: 'author')
  UserDisplay get author;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;
  @BuiltValueField(wireName: 'url')
  String get url;
  @BuiltValueField(wireName: 'pinned')
  bool get pinned;
  @BuiltValueField(wireName: 'locked_for_user')
  bool get lockedForUser;
  @BuiltValueField(wireName: 'lock_info')
  LockInfo? get lockInfo;
  @BuiltValueField(wireName: 'lock_explanation')
  String? get lockExplanation;
  @BuiltValueField(wireName: 'message')
  String get message;
  @BuiltValueField(wireName: 'subscription_hold')
  String? get subscriptionHold;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(DiscussionTopic.serializer, this)!
        as Map<String, dynamic>;
  }

  static DiscussionTopic fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(DiscussionTopic.serializer, object)!;
  }

  static Serializer<DiscussionTopic> get serializer =>
      _$discussionTopicSerializer;
}
