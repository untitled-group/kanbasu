library folder;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'folder.g.dart';

abstract class Folder implements Built<Folder, FolderBuilder> {
  Folder._();

  factory Folder([Function(FolderBuilder b) updates]) = _$Folder;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'name')
  String get name;
  @BuiltValueField(wireName: 'full_name')
  String get fullName;
  @BuiltValueField(wireName: 'context_id')
  int get contextId;
  @BuiltValueField(wireName: 'context_type')
  String get contextType;
  @BuiltValueField(wireName: 'parent_folder_id')
  int? get parentFolderId;
  @BuiltValueField(wireName: 'created_at')
  DateTime get createdAt;
  @BuiltValueField(wireName: 'updated_at')
  DateTime get updatedAt;
  @BuiltValueField(wireName: 'lock_at')
  DateTime? get lockAt;
  @BuiltValueField(wireName: 'unlock_at')
  DateTime? get unlockAt;
  @BuiltValueField(wireName: 'position')
  int? get position;
  @BuiltValueField(wireName: 'locked')
  bool? get locked;
  @BuiltValueField(wireName: 'folders_url')
  String get foldersUrl;
  @BuiltValueField(wireName: 'files_url')
  String get filesUrl;
  @BuiltValueField(wireName: 'files_count')
  int get filesCount;
  @BuiltValueField(wireName: 'folders_count')
  int get foldersCount;
  @BuiltValueField(wireName: 'locked_for_user')
  bool get lockedForUser;
  @BuiltValueField(wireName: 'hidden_for_user')
  bool get hiddenForUser;
  @BuiltValueField(wireName: 'for_submissions')
  bool get forSubmissions;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Folder.serializer, this)!
        as Map<String, dynamic>;
  }

  static Folder fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Folder.serializer, object)!;
  }

  static Serializer<Folder> get serializer => _$folderSerializer;
}
