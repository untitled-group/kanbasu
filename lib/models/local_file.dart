library file;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'local_file.g.dart';

abstract class LocalFile implements Built<LocalFile, LocalFileBuilder> {
  LocalFile._();

  factory LocalFile([Function(LocalFileBuilder b) updates]) = _$LocalFile;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'path')
  String get path;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(LocalFile.serializer, this)!
        as Map<String, dynamic>;
  }

  static LocalFile fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(LocalFile.serializer, object)!;
  }

  static Serializer<LocalFile> get serializer => _$localFileSerializer;
}
