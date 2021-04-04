library page;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'page.g.dart';

abstract class Page implements Built<Page, PageBuilder> {
  Page._();

  factory Page([Function(PageBuilder b) updates]) = _$Page;

  @BuiltValueField(wireName: 'title')
  String get title;
  @BuiltValueField(wireName: 'created_at')
  String get createdAt;
  @BuiltValueField(wireName: 'url')
  String get url;
  @BuiltValueField(wireName: 'editing_roles')
  String get editingRoles;
  @BuiltValueField(wireName: 'page_id')
  int get pageId;
  @BuiltValueField(wireName: 'published')
  bool get published;
  @BuiltValueField(wireName: 'hide_from_students')
  bool get hideFromStudents;
  @BuiltValueField(wireName: 'front_page')
  bool get frontPage;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;
  @BuiltValueField(wireName: 'todo_date')
  String? get todoDate;
  @BuiltValueField(wireName: 'updated_at')
  String get updatedAt;
  @BuiltValueField(wireName: 'locked_for_user')
  bool get lockedForUser;
  @BuiltValueField(wireName: 'body')
  String? get body;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Page.serializer, this)!
        as Map<String, dynamic>;
  }

  static Page fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Page.serializer, object)!;
  }

  static Serializer<Page> get serializer => _$pageSerializer;
}
