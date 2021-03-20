import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'user.g.dart';

abstract class User implements Built<User, UserBuilder> {
  /// A Canvas user, e.g. a student, teacher, administrator, observer, etc.

  User._();

  factory User([Function(UserBuilder b) updates]) = _$User;

  /// The ID of the user.
  @BuiltValueField(wireName: 'id')
  int get id;

  ///  The name of the user.
  @BuiltValueField(wireName: 'name')
  String get name;

  /// The name of the user that is should be used for sorting groups of users, such as in the gradebook.
  @BuiltValueField(wireName: 'sortable_name')
  String get sortableName;

  /// A short name the user has selected, for use in conversations or other less formal places through the site.
  @BuiltValueField(wireName: 'short_name')
  String get shortName;

  /// If avatars are enabled, this field will be included and contain a url to retrieve the user's avatar.
  @BuiltValueField(wireName: 'avatar_url')
  String get avatarUrl;

  @BuiltValueField(wireName: 'locale')
  String? get locale;

  /// Optional: The user''s bio.
  @BuiltValueField(wireName: 'bio')
  String? get bio;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(User.serializer, this)!
        as Map<String, dynamic>;
  }

  static User fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(User.serializer, object)!;
  }

  static Serializer<User> get serializer => _$userSerializer;
}
