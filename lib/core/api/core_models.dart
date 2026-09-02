class CoreChatRequest {
  const CoreChatRequest({
    required this.message,
    required this.conversationId,
  });

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
