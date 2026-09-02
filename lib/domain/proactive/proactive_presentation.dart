enum ProactivePresentationKind { whisper, shadow, notification, knock, call }

class ProactivePresentation {
  const ProactivePresentation({
    required this.kind,
    required this.presentationId,
    this.message,
    this.expiresAt,
  });

  final ProactivePresentationKind kind;
  final String presentationId;
  final String? message;
  final DateTime? expiresAt;

  bool get mayInterrupt => switch (kind) {
        ProactivePresentationKind.whisper ||
        ProactivePresentationKind.shadow => false,
        ProactivePresentationKind.notification ||
        ProactivePresentationKind.knock ||
        ProactivePresentationKind.call => true,
      };
}
