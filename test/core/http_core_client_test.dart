import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:xiaxia_app/core/api/core_client.dart';
import 'package:xiaxia_app/core/api/core_models.dart';
import 'package:xiaxia_app/core/api/http_core_client.dart';
import 'package:xiaxia_app/core/api/production_core_contract_adapter.dart';
import 'package:xiaxia_app/core/config/core_connection_config.dart';

void main() {
  final config = CoreConnectionConfig(
    baseUrl: Uri.parse('https://core.example.test'),
    bearerToken: 'secret',
  );

  test('default chat timeout exceeds the 90 second edge budget', () {
    final client = HttpCoreClient(
      config: config,
      adapter: const ProductionCoreContractAdapter(),
      httpClient: MockClient((_) async => _chatResponse()),
    );

    expect(client.timeout, const Duration(seconds: 100));
    client.close();
  });

  test(
    'first /v1/chat request omits conversation_id and uses Bearer auth',
    () async {
      final client = HttpCoreClient(
        config: config,
        adapter: const ProductionCoreContractAdapter(),
        httpClient: MockClient((incoming) async {
          expect(incoming.url.path, '/v1/chat');
          expect(incoming.method, 'POST');
          expect(incoming.headers['Authorization'], 'Bearer secret');
          expect(jsonDecode(incoming.body), {'message': '今天有点累。'});
          return _chatResponse();
        }),
      );

      final reply = await client.sendChat(
        const CoreChatRequest(message: '  今天有点累。  ', conversationId: null),
      );
      expect(reply.reply, '那就先慢一点，我在。');
      expect(reply.conversationId, 'core-conversation-1');
      expect(reply.requestId, 'request-1');
    },
  );

  test(
    'follow-up /v1/chat request includes Core conversation_id only',
    () async {
      final client = HttpCoreClient(
        config: config,
        adapter: const ProductionCoreContractAdapter(),
        httpClient: MockClient((incoming) async {
          expect(jsonDecode(incoming.body), {
            'message': '继续',
            'conversation_id': 'core-conversation-1',
          });
          return _chatResponse();
        }),
      );

      await client.sendChat(
        const CoreChatRequest(
          message: '继续',
          conversationId: 'core-conversation-1',
        ),
      );
    },
  );

  test(
    'parses response headers without exposing them to Chat presentation',
    () async {
      final client = HttpCoreClient(
        config: config,
        adapter: const ProductionCoreContractAdapter(),
        httpClient: MockClient(
          (_) async => _chatResponse(memoryDegraded: true),
        ),
      );

      final reply = await client.sendChat(
        const CoreChatRequest(message: '你好', conversationId: null),
      );
      expect(reply.diagnostics.headerRequestId, 'request-1');
      expect(reply.diagnostics.httpStatus, 200);
      expect(reply.diagnostics.model, 'qwen-flash');
      expect(reply.diagnostics.memoryRetrievedCount, 6);
      expect(reply.diagnostics.memoryDegraded, isTrue);
      expect(reply.reply, isNotEmpty);
    },
  );

  test('maps 401 without leaking credentials', () async {
    final client = _client(config, (_) async => http.Response('{}', 401));
    final error = await _captureFailure(client);
    expect(error.kind, CoreFailureKind.authentication);
    expect(error.statusCode, 401);
    expect(error.userMessage, isNot(contains('secret')));
  });

  test('maps 422 invalid request', () async {
    final client = _client(
      config,
      (_) async => http.Response('{"detail":"validation detail"}', 422),
    );
    final error = await _captureFailure(client);
    expect(error.kind, CoreFailureKind.invalidRequest);
    expect(error.statusCode, 422);
    expect(error.userMessage, isNot(contains('validation detail')));
  });

  test('maps sanitized 502 model_unavailable', () async {
    final client = _client(
      config,
      (_) async => http.Response(
        jsonEncode({
          'detail': {
            'code': 'model_unavailable',
            'message': 'internal upstream detail',
            'request_id': 'request-1',
          },
        }),
        502,
      ),
    );
    final error = await _captureFailure(client);
    expect(error.kind, CoreFailureKind.modelUnavailable);
    expect(error.statusCode, 502);
    expect(error.userMessage, isNot(contains('upstream')));
  });

  test('maps other unavailable Core responses', () async {
    final client = _client(
      config,
      (_) async => http.Response('internal detail', 503),
    );
    final error = await _captureFailure(client);
    expect(error.kind, CoreFailureKind.unavailable);
    expect(error.statusCode, 503);
    expect(error.userMessage, isNot(contains('internal detail')));
  });

  test('maps timeout', () async {
    final client = HttpCoreClient(
      config: config,
      adapter: const ProductionCoreContractAdapter(),
      timeout: const Duration(milliseconds: 1),
      httpClient: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return _chatResponse();
      }),
    );
    final error = await _captureFailure(client);
    expect(error.kind, CoreFailureKind.timeout);
  });

  test('rejects malformed JSON and missing required response fields', () async {
    final malformedJson = _client(config, (_) async => http.Response('{', 200));
    expect(
      (await _captureFailure(malformedJson)).kind,
      CoreFailureKind.malformedResponse,
    );

    final missingFields = _client(
      config,
      (_) async => http.Response('{"reply":"hello"}', 200),
    );
    expect(
      (await _captureFailure(missingFields)).kind,
      CoreFailureKind.malformedResponse,
    );
  });

  test('rejects request ID disagreement between body and header', () async {
    final client = _client(
      config,
      (_) async => http.Response(
        jsonEncode({
          'reply': 'hello',
          'conversation_id': 'conversation',
          'request_id': 'body-request',
        }),
        200,
        headers: {'x-request-id': 'header-request'},
      ),
    );
    expect(
      (await _captureFailure(client)).kind,
      CoreFailureKind.malformedResponse,
    );
  });

  test('registers shared conversation with bearer auth', () async {
    final client = _client(config, (incoming) async {
      expect(incoming.method, 'POST');
      expect(incoming.url.path, '/v1/life/conversation');
      expect(incoming.headers['Authorization'], 'Bearer secret');
      expect(jsonDecode(incoming.body), {'conversation_id': 'conversation-7'});
      return http.Response('{"conversation_id":"conversation-7"}', 200);
    });

    await client.registerSharedConversation('conversation-7');
  });

  test('parses proactive messages and preserves server ids', () async {
    final client = _client(config, (incoming) async {
      expect(incoming.url.path, '/v1/chat/proactive');
      expect(incoming.url.queryParameters, {
        'conversation_id': 'conversation-7',
        'after_id': '40',
      });
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'conversation_id': 'conversation-7',
            'messages': [
              {
                'id': 42,
                'content': '我想起你啦。',
                'created_at': '2026-09-21T08:00:00Z',
              },
            ],
          }),
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final messages = await client.fetchProactiveMessages(
      'conversation-7',
      afterId: 40,
    );
    expect(messages.single.id, 42);
    expect(messages.single.content, '我想起你啦。');
  });

  test('life status is authenticated and excludes private content', () async {
    final client = _client(config, (incoming) async {
      expect(incoming.url.path, '/v1/life/status');
      expect(incoming.headers['Authorization'], 'Bearer secret');
      return http.Response(
        jsonEncode({
          'mode': 'idle',
          'last_wake_at': '2026-09-21T07:00:00Z',
          'next_wake_at': '2026-09-21T09:00:00Z',
          'today': {
            'wake_count': 2,
            'cognition_count': 1,
            'token_usage': 3269,
            'proactive_delivery_count': 1,
          },
          'active_activity': {'exists': false, 'count': 0},
          'interior': {'private_count': 2, 'candidate_count': 0},
          'last_outcome': {'type': 'DELIVERY', 'at': '2026-09-21T08:00:00Z'},
          'shared_conversation_ready': true,
        }),
        200,
      );
    });

    final status = await client.fetchLifeStatus();
    expect(status.mode, 'idle');
    expect(status.privateThoughtCount, 2);
    expect(status.proactiveDeliveryCount, 1);
    expect(status.lastOutcomeType, 'DELIVERY');
  });

  test('life status accepts no next meaningful wake', () async {
    final client = _client(config, (incoming) async {
      expect(incoming.url.path, '/v1/life/status');
      return http.Response(
        jsonEncode({
          'mode': 'idle',
          'last_wake_at': '2026-09-21T07:00:00Z',
          'next_wake_at': null,
          'today': {
            'wake_count': 0,
            'cognition_count': 0,
            'token_usage': 0,
            'proactive_delivery_count': 0,
          },
          'active_activity': {'exists': false, 'count': 0},
          'interior': {'private_count': 0, 'candidate_count': 0},
          'last_outcome': {'type': 'REST', 'at': null},
          'shared_conversation_ready': true,
        }),
        200,
      );
    });

    final status = await client.fetchLifeStatus();
    expect(status.nextWakeAt, isNull);
  });
}

HttpCoreClient _client(
  CoreConnectionConfig config,
  Future<http.Response> Function(http.Request) handler,
) {
  return HttpCoreClient(
    config: config,
    adapter: const ProductionCoreContractAdapter(),
    httpClient: MockClient(handler),
  );
}

Future<CoreClientException> _captureFailure(HttpCoreClient client) async {
  try {
    await client.sendChat(
      const CoreChatRequest(message: 'hello', conversationId: null),
    );
  } on CoreClientException catch (error) {
    return error;
  }
  throw TestFailure('Expected CoreClientException');
}

http.Response _chatResponse({bool memoryDegraded = false}) {
  return http.Response(
    jsonEncode({
      'reply': '那就先慢一点，我在。',
      'conversation_id': 'core-conversation-1',
      'request_id': 'request-1',
    }),
    200,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'x-request-id': 'request-1',
      'x-model': 'qwen-flash',
      'x-memory-retrieved-count': '6',
      'x-memory-degraded': memoryDegraded.toString(),
    },
  );
}
