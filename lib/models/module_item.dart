library module_item;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'module_item.g.dart';

abstract class ModuleItem implements Built<ModuleItem, ModuleItemBuilder> {
  ModuleItem._();

  factory ModuleItem([Function(ModuleItemBuilder b) updates]) = _$ModuleItem;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'title')
  String get title;
  @BuiltValueField(wireName: 'position')
  int get position;
  @BuiltValueField(wireName: 'indent')
  int get indent;
  @BuiltValueField(wireName: 'type')
  String get type;
  @BuiltValueField(wireName: 'module_id')
  int get moduleId;
  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;
  @BuiltValueField(wireName: 'content_id')
  int get contentId;
  @BuiltValueField(wireName: 'url')
  String get url;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(ModuleItem.serializer, this)!
        as Map<String, dynamic>;
  }

  static ModuleItem fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(ModuleItem.serializer, object)!;
  }

  static Serializer<ModuleItem> get serializer => _$moduleItemSerializer;
}
