library author;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'author.g.dart';

abstract class Author implements Built<Author, AuthorBuilder> {
  Author._();

  factory Author([Function(AuthorBuilder b) updates]) = _$Author;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'display_name')
  String get displayName;
  @BuiltValueField(wireName: 'avatar_image_url')
  String get avatarImageUrl;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Author.serializer, this)!
        as Map<String, dynamic>;
  }

  static Author fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Author.serializer, object)!;
  }

  static Serializer<Author> get serializer => _$authorSerializer;
}
