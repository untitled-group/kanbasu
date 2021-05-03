import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'discussion_entry_mock.g.dart';

@JsonLiteral('data/discussion_entries.json')
String get discussionEntriesResponse =>
    json.encode(_$discussionEntriesResponseJsonLiteral);
