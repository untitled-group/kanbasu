import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'lock_info.g.dart';

abstract class LockInfo implements Built<LockInfo, LockInfoBuilder> {
  LockInfo._();

  factory LockInfo([Function(LockInfoBuilder b) updates]) = _$LockInfo;

  @BuiltValueField(wireName: 'lock_at')
  DateTime? get lockAt;
  @BuiltValueField(wireName: 'can_view')
  bool get canView;
  @BuiltValueField(wireName: 'asset_string')
  String get assetString;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(LockInfo.serializer, this)!
        as Map<String, dynamic>;
  }

  static LockInfo fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(LockInfo.serializer, object)!;
  }

  static Serializer<LockInfo> get serializer => _$lockInfoSerializer;
}
