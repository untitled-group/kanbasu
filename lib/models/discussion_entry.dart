import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:kanbasu/models/user_display.dart';
import 'serializers.dart';

part 'discussion_entry.g.dart';

abstract class DiscussionEntry
    implements Built<DiscussionEntry, DiscussionEntryBuilder> {
  DiscussionEntry._();

  factory DiscussionEntry([Function(DiscussionEntryBuilder b) updates]) =
      _$DiscussionEntry;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'user_id')
  int get userId;
  @BuiltValueField(wireName: 'parent_id')
  int? get parentId;
  @BuiltValueField(wireName: 'created_at')
  String get createdAt;
  @BuiltValueField(wireName: 'updated_at')
  String get updatedAt;
  @BuiltValueField(wireName: 'user_name')
  String get userName;
  @BuiltValueField(wireName: 'message')
  String get message;
  @BuiltValueField(wireName: 'user')
  UserDisplay get user;
  @BuiltValueField(wireName: 'read_state')
  String get readState;
  @BuiltValueField(wireName: 'forced_read_state')
  bool get forcedReadState;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(DiscussionEntry.serializer, this)!
        as Map<String, dynamic>;
  }

  static DiscussionEntry fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(DiscussionEntry.serializer, object)!;
  }

  static Serializer<DiscussionEntry> get serializer =>
      _$discussionEntrySerializer;
}
