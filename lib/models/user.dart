import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  /// A Canvas user, e.g. a student, teacher, administrator, observer, etc.

  /// The ID of the user.
  final int id;

  ///  The name of the user.
  final String name;

  /// The name of the user that is should be used for sorting groups of users, such as in the gradebook.
  @JsonKey(name: 'sortable_name')
  final String sortableName;

  /// A short name the user has selected, for use in conversations or other less formal places through the site.
  @JsonKey(name: 'short_name')
  final String shortName;

  /// If avatars are enabled, this field will be included and contain a url to retrieve the user's avatar.
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  /// Optional: The user''s bio.
  final String? bio;

  User(
      {required this.id,
      required this.name,
      required this.sortableName,
      required this.shortName,
      required this.avatarUrl,
      this.bio});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
