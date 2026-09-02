import 'core_contract_adapter.dart';
import 'core_models.dart';

class ProductionCoreContractAdapter
    implements CoreContractAdapter, CoreDiagnosticsContractAdapter {
  const ProductionCoreContractAdapter();

  @override
  Uri chatUri(Uri baseUrl) => baseUrl.resolve('/v1/chat');

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

  static String _requiredNonBlankString(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing non-blank string: $key');
    }
    return value.trim();
  }

  static String _requiredNonBlankText(
    Map<String, dynamic> json,
    String key,
  ) {
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
}
