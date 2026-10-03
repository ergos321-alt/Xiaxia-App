import 'core_contract_adapter.dart';
import 'core_models.dart';

class ProductionCoreContractAdapter
    implements CoreContractAdapter, CoreDiagnosticsContractAdapter {
  const ProductionCoreContractAdapter();

  @override
  Uri chatUri(Uri baseUrl) => baseUrl.resolve('/v1/chat');

  @override
  Uri sharedConversationUri(Uri baseUrl) =>
      baseUrl.resolve('/v1/life/conversation');

  @override
  Uri proactiveMessagesUri(Uri baseUrl, String conversationId, int afterId) =>
      baseUrl
          .resolve('/v1/chat/proactive')
          .replace(
            queryParameters: {
              'conversation_id': conversationId,
              'after_id': '$afterId',
            },
          );

  @override
  Uri lifeStatusUri(Uri baseUrl) => baseUrl.resolve('/v1/life/status');

  @override
  Uri healthUri(Uri baseUrl) => baseUrl.resolve('/health');

  @override
  Uri statusUri(Uri baseUrl) => baseUrl.resolve('/v1/status');

  @override
  Map<String, Object?> encodeRequest(CoreChatRequest request) {
    final message = request.message.trim();
    if (message.isEmpty) {
      throw const FormatException('Chat message must not be blank');
    }
    final conversationId = request.conversationId?.trim();
    return <String, Object?>{
      'message': message,
      if (conversationId != null && conversationId.isNotEmpty)
        'conversation_id': conversationId,
    };
  }

  @override
  CoreChatReply decodeReply(Map<String, dynamic> json) {
    final reply = _requiredNonBlankText(json, 'reply');
    final conversationId = _requiredNonBlankString(json, 'conversation_id');
    final requestId = _requiredNonBlankString(json, 'request_id');
    return CoreChatReply(
      reply: reply,
      conversationId: conversationId,
      requestId: requestId,
    );
  }

  @override
  List<CoreProactiveMessage> decodeProactiveMessages(
    Map<String, dynamic> json,
  ) {
    final values = json['messages'];
    if (values is! List) throw const FormatException('Missing messages list');
    return values
        .map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Malformed proactive message');
          }
          return CoreProactiveMessage(
            id: _requiredInt(value, 'id'),
            content: _requiredNonBlankText(value, 'content'),
            createdAt: _requiredDateTime(value, 'created_at'),
          );
        })
        .toList(growable: false);
  }

  @override
  LifeRuntimeStatusSnapshot decodeLifeStatus(Map<String, dynamic> json) {
    final today = _requiredObject(json, 'today');
    final activity = _requiredObject(json, 'active_activity');
    final interior = _requiredObject(json, 'interior');
    final outcome = _requiredObject(json, 'last_outcome');
    return LifeRuntimeStatusSnapshot(
      mode: _requiredNonBlankString(json, 'mode'),
      lastWakeAt: _optionalDateTime(json, 'last_wake_at'),
      nextWakeAt: _optionalDateTime(json, 'next_wake_at'),
      wakeCount: _requiredInt(today, 'wake_count'),
      cognitionCount: _requiredInt(today, 'cognition_count'),
      tokenUsage: _requiredInt(today, 'token_usage'),
      proactiveDeliveryCount: _requiredInt(today, 'proactive_delivery_count'),
      activeActivityCount: _requiredInt(activity, 'count'),
      privateThoughtCount: _requiredInt(interior, 'private_count'),
      candidateCount: _requiredInt(interior, 'candidate_count'),
      lastOutcomeType: _optionalString(outcome, 'type'),
      lastOutcomeAt: _optionalDateTime(outcome, 'at'),
      sharedConversationReady: _requiredBool(json, 'shared_conversation_ready'),
    );
  }

  @override
  CoreHealthSnapshot decodeHealth(Map<String, dynamic> json) {
    return CoreHealthSnapshot(
      status: _requiredNonBlankString(json, 'status'),
      service: _requiredNonBlankString(json, 'service'),
      version: _requiredNonBlankString(json, 'version'),
    );
  }

  @override
  CoreRuntimeStatusSnapshot decodeStatus(Map<String, dynamic> json) {
    final model = _requiredObject(json, 'model');
    final memory = _requiredObject(json, 'memory');
    final database = _requiredObject(json, 'database');
    final identity = _requiredObject(json, 'identity');
    return CoreRuntimeStatusSnapshot(
      service: _requiredNonBlankString(json, 'service'),
      version: _requiredNonBlankString(json, 'version'),
      environment: _requiredNonBlankString(json, 'environment'),
      modelName: _requiredNonBlankString(model, 'name'),
      modelConfigured: _requiredBool(model, 'configured'),
      memoryName: _requiredNonBlankString(memory, 'name'),
      memoryConfigured: _requiredBool(memory, 'configured'),
      memoryContractStatus: _requiredNonBlankString(memory, 'contract_status'),
      databaseStatus: _requiredNonBlankString(database, 'status'),
      identityStatus: _requiredNonBlankString(identity, 'status'),
      identityFilesLoaded: _requiredInt(identity, 'files_loaded'),
    );
  }

  static Map<String, dynamic> _requiredObject(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('Missing object: $key');
    }
    return value;
  }

  static String _requiredNonBlankString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing non-blank string: $key');
    }
    return value.trim();
  }

  static String _requiredNonBlankText(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing non-blank text: $key');
    }
    return value;
  }

  static bool _requiredBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! bool) throw FormatException('Missing bool: $key');
    return value;
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) throw FormatException('Missing int: $key');
    return value;
  }

  static DateTime _requiredDateTime(Map<String, dynamic> json, String key) {
    final value = _requiredNonBlankString(json, key);
    return DateTime.parse(value);
  }

  static DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Malformed datetime: $key');
    }
    return DateTime.parse(value);
  }

  static String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Malformed string: $key');
    }
    return value.trim();
  }
}
