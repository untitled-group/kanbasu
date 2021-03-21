import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'module_mock.g.dart';

@JsonLiteral('data/modules.json')
String get moduleResponse => json.encode(_$moduleResponseJsonLiteral);
