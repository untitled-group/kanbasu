import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'file_mock.g.dart';

@JsonLiteral('data/single_file.json')
String get fileResponse => json.encode(_$fileResponseJsonLiteral);

@JsonLiteral('data/files.json')
String get filesResponse => json.encode(_$filesResponseJsonLiteral);
