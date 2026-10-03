import 'core_models.dart';

/// The only place allowed to know the Xiaxia Core endpoint and JSON schema.
/// Production mapping is verified against Xiaxia Core V0.1 routes and schemas.
abstract interface class CoreContractAdapter {
  Uri chatUri(Uri baseUrl);
  Uri sharedConversationUri(Uri baseUrl);
  Uri proactiveMessagesUri(Uri baseUrl, String conversationId, int afterId);
  Uri lifeStatusUri(Uri baseUrl);
  Map<String, Object?> encodeRequest(CoreChatRequest request);
  CoreChatReply decodeReply(Map<String, dynamic> json);
  List<CoreProactiveMessage> decodeProactiveMessages(Map<String, dynamic> json);
  LifeRuntimeStatusSnapshot decodeLifeStatus(Map<String, dynamic> json);
}

abstract interface class CoreDiagnosticsContractAdapter {
  Uri healthUri(Uri baseUrl);
  Uri statusUri(Uri baseUrl);
  CoreHealthSnapshot decodeHealth(Map<String, dynamic> json);
  CoreRuntimeStatusSnapshot decodeStatus(Map<String, dynamic> json);
}
