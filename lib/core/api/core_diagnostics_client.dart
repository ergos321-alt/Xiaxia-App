import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/core_connection_config.dart';
import 'core_client.dart';
import 'core_contract_adapter.dart';
import 'core_models.dart';

class CoreDiagnosticsClient {
  CoreDiagnosticsClient({
    required CoreConnectionConfig config,
    required CoreDiagnosticsContractAdapter adapter,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 10),
  })  : _config = config,
        _adapter = adapter,
        _httpClient = httpClient ?? http.Client();

  final CoreConnectionConfig _config;
  final CoreDiagnosticsContractAdapter _adapter;
  final http.Client _httpClient;
  final Duration timeout;

  Future<CoreHealthSnapshot> checkHealth() async {
    final baseUrl = _requiredBaseUrl();
    final response = await _get(_adapter.healthUri(baseUrl), authenticated: false);
    return _decode(response, _adapter.decodeHealth);
  }

  Future<CoreRuntimeStatusSnapshot> checkStatus() async {
    final baseUrl = _requiredBaseUrl();
    if (_config.bearerToken.isEmpty) {
      throw const CoreClientException(
        CoreFailureKind.missingConfiguration,
        '请先填写 Core 访问凭证。',
      );
    }
    final response = await _get(_adapter.statusUri(baseUrl), authenticated: true);
    return _decode(response, _adapter.decodeStatus);
  }

  Uri _requiredBaseUrl() {
    final baseUrl = _config.baseUrl;
    if (baseUrl == null) {
      throw const CoreClientException(
        CoreFailureKind.missingConfiguration,
        '请先填写有效的 Core 地址。',
      );
    }
    return baseUrl;
  }

  Future<http.Response> _get(Uri uri, {required bool authenticated}) async {
    try {
      final response = await _httpClient
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (authenticated)
                'Authorization': 'Bearer ${_config.bearerToken}',
            },
          )
          .timeout(timeout);
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
          '暂时无法验证 Xiaxia Core。',
          statusCode: response.statusCode,
        );
      }
      return response;
    } on TimeoutException {
      throw const CoreClientException(
        CoreFailureKind.timeout,
        'Core 验证超时，可以稍后重试。',
      );
    } on CoreClientException {
      rethrow;
    } on http.ClientException {
      throw const CoreClientException(
        CoreFailureKind.unavailable,
        '暂时无法验证 Xiaxia Core。',
      );
    } catch (_) {
      throw const CoreClientException(
        CoreFailureKind.unexpected,
        'Core 验证出现了意外问题。',
      );
    }
  }

  T _decode<T>(
    http.Response response,
    T Function(Map<String, dynamic>) decode,
  ) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Response root is not an object');
      }
      return decode(json);
    } on FormatException {
      throw const CoreClientException(
        CoreFailureKind.malformedResponse,
        'Core 返回了当前 App 无法识别的验证结果。',
      );
    } on CoreClientException {
      rethrow;
    } catch (_) {
      throw const CoreClientException(
        CoreFailureKind.malformedResponse,
        'Core 返回了当前 App 无法识别的验证结果。',
      );
    }
  }

  void close() => _httpClient.close();
}
