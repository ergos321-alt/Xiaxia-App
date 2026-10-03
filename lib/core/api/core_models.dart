class CoreChatRequest {
  const CoreChatRequest({required this.message, required this.conversationId});

  final String message;
  final String? conversationId;
}

class CoreChatReply {
  const CoreChatReply({
    required this.reply,
    required this.conversationId,
    required this.requestId,
    this.diagnostics = const CoreReplyDiagnostics(),
  });

  final String reply;
  final String conversationId;
  final String requestId;
  final CoreReplyDiagnostics diagnostics;

  CoreChatReply copyWith({CoreReplyDiagnostics? diagnostics}) {
    return CoreChatReply(
      reply: reply,
      conversationId: conversationId,
      requestId: requestId,
      diagnostics: diagnostics ?? this.diagnostics,
    );
  }
}

/// Response metadata for developer diagnostics. Chat presentation ignores it.
class CoreReplyDiagnostics {
  const CoreReplyDiagnostics({
    this.httpStatus,
    this.headerRequestId,
    this.model,
    this.memoryRetrievedCount,
    this.memoryDegraded = false,
  });

  final int? httpStatus;
  final String? headerRequestId;
  final String? model;
  final int? memoryRetrievedCount;
  final bool memoryDegraded;
}

class CoreHealthSnapshot {
  const CoreHealthSnapshot({
    required this.status,
    required this.service,
    required this.version,
  });

  final String status;
  final String service;
  final String version;
}

class CoreRuntimeStatusSnapshot {
  const CoreRuntimeStatusSnapshot({
    required this.service,
    required this.version,
    required this.environment,
    required this.modelName,
    required this.modelConfigured,
    required this.memoryName,
    required this.memoryConfigured,
    required this.memoryContractStatus,
    required this.databaseStatus,
    required this.identityStatus,
    required this.identityFilesLoaded,
  });

  final String service;
  final String version;
  final String environment;
  final String modelName;
  final bool modelConfigured;
  final String memoryName;
  final bool memoryConfigured;
  final String memoryContractStatus;
  final String databaseStatus;
  final String identityStatus;
  final int identityFilesLoaded;
}

class CoreProactiveMessage {
  const CoreProactiveMessage({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final String content;
  final DateTime createdAt;
}

class LifeRuntimeStatusSnapshot {
  const LifeRuntimeStatusSnapshot({
    required this.mode,
    required this.lastWakeAt,
    required this.nextWakeAt,
    required this.wakeCount,
    required this.cognitionCount,
    required this.tokenUsage,
    required this.proactiveDeliveryCount,
    required this.activeActivityCount,
    required this.privateThoughtCount,
    required this.candidateCount,
    required this.lastOutcomeType,
    required this.lastOutcomeAt,
    required this.sharedConversationReady,
  });

  final String mode;
  final DateTime? lastWakeAt;
  final DateTime? nextWakeAt;
  final int wakeCount;
  final int cognitionCount;
  final int tokenUsage;
  final int proactiveDeliveryCount;
  final int activeActivityCount;
  final int privateThoughtCount;
  final int candidateCount;
  final String? lastOutcomeType;
  final DateTime? lastOutcomeAt;
  final bool sharedConversationReady;
}
