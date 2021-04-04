import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'page_mock.g.dart';

@JsonLiteral('data/page.json')
String get pageResponse => json.encode(_$pageResponseJsonLiteral);

@JsonLiteral('data/pages.json')
String get pagesResponse => json.encode(_$pagesResponseJsonLiteral);
