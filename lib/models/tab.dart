import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'tab.g.dart';

abstract class Tab implements Built<Tab, TabBuilder> {
  Tab._();

  factory Tab([updates(TabBuilder b)]) = _$Tab;

  @BuiltValueField(wireName: 'id')
  String get id;

  @BuiltValueField(wireName: 'html_url')
  String get htmlUrl;

  @BuiltValueField(wireName: 'full_url')
  String get fullUrl;

  /// 1 based
  @BuiltValueField(wireName: 'position')
  int get position;

  /// possible values are: public, members, admins, and none
  @BuiltValueField(wireName: 'visibility')
  String get visibility;

  @BuiltValueField(wireName: 'label')
  String get label;

  @BuiltValueField(wireName: 'type')
  String get type;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Tab.serializer, this)!
        as Map<String, dynamic>;
  }

  static Tab fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Tab.serializer, object)!;
  }

  static Serializer<Tab> get serializer => _$tabSerializer;
}
