import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'tab_mock.g.dart';

@JsonLiteral('data/tab_response.json')
String get tabResponse => json.encode(_$tabResponseJsonLiteral);
