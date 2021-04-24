library term;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'term.g.dart';

abstract class Term implements Built<Term, TermBuilder> {
  Term._();

  factory Term([Function(TermBuilder b) updates]) = _$Term;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'name')
  String get name;
  @BuiltValueField(wireName: 'start_at')
  DateTime get startAt;
  @BuiltValueField(wireName: 'end_at')
  DateTime get endAt;
  @BuiltValueField(wireName: 'created_at')
  DateTime get createdAt;
  @BuiltValueField(wireName: 'workflow_state')
  String get workflowState;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Term.serializer, this)!
        as Map<String, dynamic>;
  }

  static Term fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Term.serializer, object)!;
  }

  static Serializer<Term> get serializer => _$termSerializer;
}
