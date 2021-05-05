class ResolveProgress {
  final double percent;
  final String message;

  ResolveProgress({required this.percent, required this.message});

  ResolveProgress prepend(String moduleName) {
    return ResolveProgress(percent: percent, message: '$moduleName / $message');
  }
}
