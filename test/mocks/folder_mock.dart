import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'folder_mock.g.dart';

@JsonLiteral('data/folders.json')
String get foldersResponse => json.encode(_$foldersResponseJsonLiteral);

@JsonLiteral('data/single_folder.json')
String get folderResponse => json.encode(_$folderResponseJsonLiteral);
