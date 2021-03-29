import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'unsubmitted_submission_mock.g.dart';

@JsonLiteral('data/unsubmitted_submission.json')
String get unsubmittedSubmissionResponse =>
    json.encode(_$unsubmittedSubmissionResponseJsonLiteral);
