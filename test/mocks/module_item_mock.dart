import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'module_item_mock.g.dart';

@JsonLiteral('data/module_items.json')
String get moduleItemsResponse => json.encode(_$moduleItemsResponseJsonLiteral);

@JsonLiteral('data/module_item.json')
String get moduleItemResponse => json.encode(_$moduleItemResponseJsonLiteral);
