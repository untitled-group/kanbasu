import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'submission_mock.g.dart';

@JsonLiteral('data/submission.json')
String get submissionResponse => json.encode(_$submissionResponseJsonLiteral);

@JsonLiteral('data/submissions.json')
String get submissionsResponse => json.encode(_$submissionsResponseJsonLiteral);
