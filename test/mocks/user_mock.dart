import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'user_mock.g.dart';

@JsonLiteral('data/current_user.json')
String get currentUserResponse => json.encode(_$currentUserResponseJsonLiteral);

@JsonLiteral('data/activity_stream.json')
String get activityStreamResponse =>
    json.encode(_$activityStreamResponseJsonLiteral);
