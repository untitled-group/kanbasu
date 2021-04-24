library user_display;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'user_display.g.dart';

abstract class UserDisplay implements Built<UserDisplay, UserDisplayBuilder> {
  UserDisplay._();

  factory UserDisplay([Function(UserDisplayBuilder b) updates]) = _$UserDisplay;

  @BuiltValueField(wireName: 'id')
  int? get id;
  @BuiltValueField(wireName: 'display_name')
  String? get displayName;
  @BuiltValueField(wireName: 'avatar_image_url')
  String? get avatarImageUrl;
  @BuiltValueField(wireName: 'html_url')
  String? get htmlUrl;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(UserDisplay.serializer, this)!
        as Map<String, dynamic>;
  }

  static UserDisplay fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(UserDisplay.serializer, object)!;
  }

  static Serializer<UserDisplay> get serializer => _$userDisplaySerializer;
}
