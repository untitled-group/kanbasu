library plannable;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'plannable.g.dart';

abstract class Plannable implements Built<Plannable, PlannableBuilder> {
  Plannable._();

  factory Plannable([Function(PlannableBuilder b) updates]) = _$Plannable;

  @BuiltValueField(wireName: 'title')
  String? get title;
  @BuiltValueField(wireName: 'message')
  String? get message;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Plannable.serializer, this)!
        as Map<String, dynamic>;
  }

  static Plannable fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Plannable.serializer, object)!;
  }

  static Serializer<Plannable> get serializer => _$plannableSerializer;
}
