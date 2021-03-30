library file;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'file.g.dart';

abstract class File implements Built<File, FileBuilder> {
  File._();

  factory File([Function(FileBuilder b) updates]) = _$File;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'uuid')
  String get uuid;
  @BuiltValueField(wireName: 'folder_id')
  int get folderId;
  @BuiltValueField(wireName: 'display_name')
  String get displayName;
  @BuiltValueField(wireName: 'filename')
  String get filename;
  @BuiltValueField(wireName: 'content-type')
  String get contentType;
  @BuiltValueField(wireName: 'url')
  String get url;
  @BuiltValueField(wireName: 'size')
  int get size;
  @BuiltValueField(wireName: 'created_at')
  DateTime get createdAt;
  @BuiltValueField(wireName: 'updated_at')
  DateTime get updatedAt;
  @BuiltValueField(wireName: 'unlock_at')
  DateTime? get unlockAt;
  @BuiltValueField(wireName: 'locked')
  bool get locked;
  @BuiltValueField(wireName: 'hidden')
  bool get hidden;
  @BuiltValueField(wireName: 'lock_at')
  DateTime? get lockAt;
  @BuiltValueField(wireName: 'hidden_for_user')
  bool get hiddenForUser;
  @BuiltValueField(wireName: 'thumbnail_url')
  String? get thumbnailUrl;
  @BuiltValueField(wireName: 'modified_at')
  DateTime get modifiedAt;
  @BuiltValueField(wireName: 'mime_class')
  String get mimeClass;
  @BuiltValueField(wireName: 'media_entry_id')
  String? get mediaEntryId;
  @BuiltValueField(wireName: 'locked_for_user')
  bool get lockedForUser;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(File.serializer, this)!
        as Map<String, dynamic>;
  }

  static File fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(File.serializer, object)!;
  }

  static Serializer<File> get serializer => _$fileSerializer;
}
