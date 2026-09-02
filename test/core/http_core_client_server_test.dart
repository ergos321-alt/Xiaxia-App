import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/core/api/core_models.dart';
import 'package:xiaxia_app/core/api/http_core_client.dart';
import 'package:xiaxia_app/core/api/production_core_contract_adapter.dart';
import 'package:xiaxia_app/core/config/core_connection_config.dart';

void main() {
  test('real HTTP transport preserves Core conversation continuity', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final received = <Map<String, dynamic>>[];
    server.listen((request) async {
      expect(request.method, 'POST');
      expect(request.uri.path, '/v1/chat');
      expect(
        request.headers.value(HttpHeaders.authorizationHeader),
        'Bearer server-test-token',
      );
      final json = jsonDecode(await utf8.decoder.bind(request).join());
      received.add(json as Map<String, dynamic>);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..headers.set('X-Request-ID', 'request-${received.length}')
        ..write(
          jsonEncode({
            'reply': 'reply-${received.length}',
            'conversation_id': 'core-issued-id',
            'request_id': 'request-${received.length}',
          }),
        );
      await request.response.close();
    });

    final client = HttpCoreClient(
      config: CoreConnectionConfig(
        baseUrl: Uri.parse('http://${server.address.host}:${server.port}'),
        bearerToken: 'server-test-token',
      ),
      adapter: const ProductionCoreContractAdapter(),
    );

    try {
      final first = await client.sendChat(
        const CoreChatRequest(message: '第一句', conversationId: null),
      );
      await client.sendChat(
        CoreChatRequest(
          message: '第二句',
          conversationId: first.conversationId,
        ),
      );

      expect(received, [
        {'message': '第一句'},
        {'message': '第二句', 'conversation_id': 'core-issued-id'},
      ]);
    } finally {
      client.close();
      await server.close(force: true);
    }
  });
}
