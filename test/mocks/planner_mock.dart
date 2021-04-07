import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'planner_mock.g.dart';

@JsonLiteral('data/planners.json')
String get plannersResponse => json.encode(_$plannersResponseJsonLiteral);
