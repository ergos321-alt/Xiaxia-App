import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/core_connection_config.dart';
import 'core_client.dart';
import 'core_contract_adapter.dart';
import 'core_models.dart';

class HttpCoreClient implements CoreClient {
  HttpCoreClient({
    required CoreConnectionConfig config,
    required CoreContractAdapter adapter,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 100),
  }) : _config = config,
       _adapter = adapter,
       _httpClient = httpClient ?? http.Client();

  final CoreConnectionConfig _config;
  final CoreContractAdapter _adapter;
  final http.Client _httpClient;
  final Duration timeout;

  @override
  Future<CoreChatReply> sendChat(CoreChatRequest request) async {
    final baseUrl = _config.baseUrl;
    if (baseUrl == null || _config.bearerToken.isEmpty) {
      throw const CoreClientException(
        CoreFailureKind.missingConfiguration,
        '请先完成 Core 连接配置。',
      );
    }

    try {
      final response = await _httpClient
          .post(
            _adapter.chatUri(baseUrl),
            headers: {
              'Authorization': 'Bearer ${_config.bearerToken}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(_adapter.encodeRequest(request)),
          )
          .timeout(timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw CoreClientException(
          CoreFailureKind.authentication,
          'Core 拒绝了当前访问凭证。',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode == 422) {
        throw const CoreClientException(
          CoreFailureKind.invalidRequest,
          '这条消息没有被 Core 接受，请修改后再试。',
          statusCode: 422,
        );
      }
      if (response.statusCode == 502 &&
          _isModelUnavailable(response.bodyBytes)) {
        throw const CoreClientException(
          CoreFailureKind.modelUnavailable,
          '夏夏暂时无法回应，可以稍后再试。',
          statusCode: 502,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CoreClientException(
          CoreFailureKind.unavailable,
          '暂时无法连接 Xiaxia Core。',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response root is not an object');
      }
      final reply = _adapter.decodeReply(decoded);
      final headerRequestId = _nonBlankHeader(response, 'x-request-id');
      if (headerRequestId != null && headerRequestId != reply.requestId) {
        throw const FormatException('Request ID header/body mismatch');
      }
      return reply.copyWith(
        diagnostics: CoreReplyDiagnostics(
          httpStatus: response.statusCode,
          headerRequestId: headerRequestId,
          model: _nonBlankHeader(response, 'x-model'),
          memoryRetrievedCount: int.tryParse(
            _nonBlankHeader(response, 'x-memory-retrieved-count') ?? '',
          ),
          memoryDegraded:
              _nonBlankHeader(response, 'x-memory-degraded')?.toLowerCase() ==
              'true',
        ),
      );
    } on TimeoutException {
      throw const CoreClientException(
        CoreFailureKind.timeout,
        'Core 回应超时，可以稍后重试。',
      );
    } on CoreClientException {
      rethrow;
    } on FormatException {
      throw const CoreClientException(
        CoreFailureKind.malformedResponse,
        'Core 返回了当前 App 无法识别的内容。',
      );
    } on http.ClientException {
      throw const CoreClientException(
        CoreFailureKind.unavailable,
        '暂时无法连接 Xiaxia Core。',
      );
    } catch (_) {
      throw const CoreClientException(CoreFailureKind.unexpected, '连接出现了意外问题。');
    }
  }

  @override
  Future<void> registerSharedConversation(String conversationId) async {
    final baseUrl = _configuredBaseUrl();
    try {
      final response = await _httpClient
          .post(
            _adapter.sharedConversationUri(baseUrl),
            headers: _authorizedHeaders,
            body: jsonEncode({'conversation_id': conversationId}),
          )
          .timeout(timeout);
      _decodeProtectedJson(response);
    } on TimeoutException {
      throw const CoreClientException(
        CoreFailureKind.timeout,
        'Core 回应超时，可以稍后再试。',
      );
    } on CoreClientException {
      rethrow;
    } on FormatException {
      throw const CoreClientException(
        CoreFailureKind.malformedResponse,
        'Core 返回了当前 App 无法识别的内容。',
      );
    } on http.ClientException {
      throw const CoreClientException(
        CoreFailureKind.unavailable,
        '暂时无法连接 Xiaxia Core。',
      );
    }
  }

  @override
  Future<List<CoreProactiveMessage>> fetchProactiveMessages(
    String conversationId, {
    int afterId = 0,
  }) async {
    final baseUrl = _configuredBaseUrl();
    try {
      final response = await _httpClient
          .get(
            _adapter.proactiveMessagesUri(baseUrl, conversationId, afterId),
            headers: _authorizedHeaders,
          )
          .timeout(timeout);
      return _adapter.decodeProactiveMessages(_decodeProtectedJson(response));
    } on TimeoutException {
      throw const CoreClientException(
        CoreFailureKind.timeout,
        'Core 回应超时，可以稍后再试。',
      );
    } on CoreClientException {
      rethrow;
    } on FormatException {
      throw const CoreClientException(
        CoreFailureKind.malformedResponse,
        'Core 返回了当前 App 无法识别的内容。',
      );
    } on http.ClientException {
      throw const CoreClientException(
        CoreFailureKind.unavailable,
        '暂时无法连接 Xiaxia Core。',
      );
    }
  }

  @override
  Future<LifeRuntimeStatusSnapshot> fetchLifeStatus() async {
    final baseUrl = _configuredBaseUrl();
    try {
      final response = await _httpClient
          .get(_adapter.lifeStatusUri(baseUrl), headers: _authorizedHeaders)
          .timeout(timeout);
      return _adapter.decodeLifeStatus(_decodeProtectedJson(response));
    } on TimeoutException {
      throw const CoreClientException(
        CoreFailureKind.timeout,
        'Core 回应超时，可以稍后再试。',
      );
    } on CoreClientException {
      rethrow;
    } on FormatException {
      throw const CoreClientException(
        CoreFailureKind.malformedResponse,
        'Core 返回了当前 App 无法识别的内容。',
      );
    } on http.ClientException {
      throw const CoreClientException(
        CoreFailureKind.unavailable,
        '暂时无法连接 Xiaxia Core。',
      );
    }
  }

  Uri _configuredBaseUrl() {
    final baseUrl = _config.baseUrl;
    if (baseUrl == null || _config.bearerToken.isEmpty) {
      throw const CoreClientException(
        CoreFailureKind.missingConfiguration,
        '请先完成 Core 连接配置。',
      );
    }
    return baseUrl;
  }

  Map<String, String> get _authorizedHeaders => {
    'Authorization': 'Bearer ${_config.bearerToken}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _decodeProtectedJson(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw CoreClientException(
        CoreFailureKind.authentication,
        'Core 拒绝了当前访问凭证。',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CoreClientException(
        CoreFailureKind.unavailable,
        '暂时无法连接 Xiaxia Core。',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Response root is not an object');
    }
    return decoded;
  }

  @override
  void close() => _httpClient.close();

  static String? _nonBlankHeader(http.Response response, String name) {
    final value = response.headers[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static bool _isModelUnavailable(List<int> bodyBytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is! Map<String, dynamic>) return false;
      final detail = decoded['detail'];
      return detail is Map<String, dynamic> &&
          detail['code'] == 'model_unavailable';
    } on FormatException {
      return false;
    }
  }
}
