import '../config/core_connection_config.dart';
import 'core_models.dart';

abstract interface class CoreClient {
  Future<CoreChatReply> sendChat(CoreChatRequest request);
  void close();
}

abstract interface class CoreClientFactory {
  CoreClient create(CoreConnectionConfig config);
}

enum CoreFailureKind {
  missingConfiguration,
  authentication,
  invalidRequest,
  modelUnavailable,
  unavailable,
  timeout,
  malformedResponse,
  unexpected,
}

class CoreClientException implements Exception {
  const CoreClientException(this.kind, this.userMessage, {this.statusCode});

  final CoreFailureKind kind;
  final String userMessage;
  final int? statusCode;

  @override
  String toString() => 'CoreClientException($kind, $statusCode, $userMessage)';
}
