enum LiveTokenStatus {
  correct,
  incorrect,
}

class LiveTokenFeedback {
  final String typedText;
  final LiveTokenStatus status;
  final bool isCompleted;

  const LiveTokenFeedback({
    required this.typedText,
    required this.status,
    required this.isCompleted,
  });
}
