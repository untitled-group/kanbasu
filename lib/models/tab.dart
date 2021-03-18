import 'package:json_annotation/json_annotation.dart';

part 'tab.g.dart';

@JsonSerializable()
class Tab {
  final String id;
  @JsonKey(name: 'html_url')
  final String htmlUrl;
  @JsonKey(name: 'full_url')
  final String fullUrl;
  final int position;
  final String visibility;
  final String label;
  final String type;

  Tab(
      {required this.id,
      required this.htmlUrl,
      required this.fullUrl,
      required this.position,
      required this.visibility,
      required this.label,
      required this.type});

  factory Tab.fromJson(Map<String, dynamic> json) => _$TabFromJson(json);
  Map<String, dynamic> toJson() => _$TabToJson(this);
}
