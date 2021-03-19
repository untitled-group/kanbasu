import 'package:json_annotation/json_annotation.dart';

part 'assignment.g.dart';

@JsonSerializable()
class Assignment {
  final int id;
  final String description;

  Assignment({required this.id, required this.description});

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
  Map<String, dynamic> toJson() => _$AssignmentToJson(this);
}
