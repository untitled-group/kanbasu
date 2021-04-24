import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'discussion_topic_mock.g.dart';

@JsonLiteral('data/discussion_topic.json')
String get discussionTopicResponse =>
    json.encode(_$discussionTopicResponseJsonLiteral);

@JsonLiteral('data/discussion_topics.json')
String get discussionTopicsResponse =>
    json.encode(_$discussionTopicsResponseJsonLiteral);
