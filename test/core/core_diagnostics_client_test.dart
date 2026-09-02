import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:xiaxia_app/core/api/core_client.dart';
import 'package:xiaxia_app/core/api/core_diagnostics_client.dart';
import 'package:xiaxia_app/core/api/production_core_contract_adapter.dart';
import 'package:xiaxia_app/core/config/core_connection_config.dart';

void main() {
  final config = CoreConnectionConfig(
    baseUrl: Uri.parse('https://core.example.test'),
    bearerToken: 'diagnostic-token',
  );

  test('/health is unauthenticated and parsed', () async {
    final client = CoreDiagnosticsClient(
      config: config,
      adapter: const ProductionCoreContractAdapter(),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/health');
        expect(request.headers, isNot(contains('Authorization')));
        return http.Response(
          jsonEncode({
            'status': 'ok',
            'service': 'xiaxia-core',
            'version': '0.1.0',
          }),
          200,
        );
      }),
    );

    final health = await client.checkHealth();
    expect(health.status, 'ok');
    expect(health.service, 'xiaxia-core');
  });

  test('/v1/status uses the same Bearer token and parses developer data', () async {
    final client = CoreDiagnosticsClient(
      config: config,
      adapter: const ProductionCoreContractAdapter(),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/v1/status');
        expect(request.headers['Authorization'], 'Bearer diagnostic-token');
        return http.Response(
          jsonEncode({
            'service': 'xiaxia-core',
            'version': '0.1.0',
            'environment': 'production',
            'model': {'name': 'qwen', 'configured': true},
            'memory': {
              'name': 'xiaxia-memory',
              'configured': true,
              'contract_status': 'configured',
            },
            'database': {'status': 'ok'},
            'identity': {'status': 'ok', 'files_loaded': 7},
          }),
          200,
        );
      }),
    );

    final status = await client.checkStatus();
    expect(status.databaseStatus, 'ok');
    expect(status.identityFilesLoaded, 7);
  });

  test('/v1/status maps 401 without returning the token', () async {
    final client = CoreDiagnosticsClient(
      config: config,
      adapter: const ProductionCoreContractAdapter(),
      httpClient: MockClient((_) async => http.Response('{}', 401)),
    );

    await expectLater(
      client.checkStatus(),
      throwsA(
        isA<CoreClientException>()
            .having((error) => error.kind, 'kind', CoreFailureKind.authentication)
            .having(
              (error) => error.userMessage,
              'safe message',
              isNot(contains('diagnostic-token')),
            ),
      ),
    );
  });
}
