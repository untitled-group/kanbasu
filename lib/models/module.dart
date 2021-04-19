library module;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'module.g.dart';

abstract class Module implements Built<Module, ModuleBuilder> {
  Module._();

  factory Module([Function(ModuleBuilder b) updates]) = _$Module;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'name')
  String get name;
  @BuiltValueField(wireName: 'position')
  int get position;
  @BuiltValueField(wireName: 'unlock_at')
  DateTime? get unlockAt;
  @BuiltValueField(wireName: 'require_sequential_progress')
  bool get requireSequentialProgress;
  @BuiltValueField(wireName: 'publish_final_grade')
  bool get publishFinalGrade;
  @BuiltValueField(wireName: 'state')
  String? get state;
  @BuiltValueField(wireName: 'completed_at')
  DateTime? get completedAt;
  @BuiltValueField(wireName: 'items_count')
  int get itemsCount;
  @BuiltValueField(wireName: 'items_url')
  String get itemsUrl;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Module.serializer, this)!
        as Map<String, dynamic>;
  }

  static Module fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Module.serializer, object)!;
  }

  static Serializer<Module> get serializer => _$moduleSerializer;
}
