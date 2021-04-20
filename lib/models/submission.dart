import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'submission.g.dart';

abstract class Submission implements Built<Submission, SubmissionBuilder> {
  Submission._();

  factory Submission([Function(SubmissionBuilder b) updates]) = _$Submission;

  @BuiltValueField(wireName: 'id')
  int get id;
  @BuiltValueField(wireName: 'body')
  String? get body;
  @BuiltValueField(wireName: 'url')
  String? get url;
  @BuiltValueField(wireName: 'grade')
  String? get grade;
  @BuiltValueField(wireName: 'score')
  double? get score;
  @BuiltValueField(wireName: 'submitted_at')
  DateTime? get submittedAt;
  @BuiltValueField(wireName: 'assignment_id')
  int get assignmentId;
  @BuiltValueField(wireName: 'user_id')
  int get userId;
  @BuiltValueField(wireName: 'submission_type')
  String? get submissionType;
  @BuiltValueField(wireName: 'workflow_state')
  String get workflowState;
  @BuiltValueField(wireName: 'grade_matches_current_submission')
  bool get gradeMatchesCurrentSubmission;
  @BuiltValueField(wireName: 'graded_at')
  DateTime? get gradedAt;
  @BuiltValueField(wireName: 'grader_id')
  int? get graderId;
  @BuiltValueField(wireName: 'attempt')
  int? get attempt;
  @BuiltValueField(wireName: 'excused')
  bool? get excused;
  @BuiltValueField(wireName: 'late_policy_status')
  String? get latePolicyStatus;
  @BuiltValueField(wireName: 'points_deducted')
  double? get pointsDeducted;
  @BuiltValueField(wireName: 'grading_period_id')
  int? get gradingPeriodId;
  @BuiltValueField(wireName: 'late')
  bool get late;
  @BuiltValueField(wireName: 'missing')
  bool get missing;
  @BuiltValueField(wireName: 'preview_url')
  String? get previewUrl;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Submission.serializer, this)!
        as Map<String, dynamic>;
  }

  static Submission fromJson(Map<String, dynamic> object) {
    return serializers.deserializeWith(Submission.serializer, object)!;
  }

  static Serializer<Submission> get serializer => _$submissionSerializer;
}
