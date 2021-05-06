import 'package:built_value/built_value.dart';

part 'resolve_progress.g.dart';

abstract class ResolveProgress
    implements Built<ResolveProgress, ResolveProgressBuilder> {
  ResolveProgress._();

  factory ResolveProgress([Function(ResolveProgressBuilder b) updates]) =
      _$ResolveProgress;

  @BuiltValueField()
  double get percent;

  @BuiltValueField()
  String get message;

  ResolveProgress prepend(String moduleName) {
    return rebuild((r) => r..message = '$moduleName / ${r.message}');
  }
}
