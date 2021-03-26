import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'assignment_mock.g.dart';

@JsonLiteral('data/assignments.json')
String get assignmentResponse => json.encode(_$assignmentResponseJsonLiteral);
