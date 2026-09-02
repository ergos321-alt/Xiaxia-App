import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/core/api/core_client.dart';
import 'package:xiaxia_app/core/api/core_models.dart';
import 'package:xiaxia_app/core/persistence/conversation_store.dart';
import 'package:xiaxia_app/domain/chat/chat_message.dart';

import '../test_support.dart';

void main() {
  test('persists a local conversation and Core reply', () async {
    final stub = StubCoreClient(
      reply: const CoreChatReply(
        reply: '我在。',
        conversationId: 'core-conversation',
        requestId: 'core-request',
      ),
    );
    final harness = await createHarness(factory: StubCoreClientFactory(stub));

    await harness.controller.send('夏夏？');

    expect(harness.controller.messages, hasLength(2));
    expect(harness.controller.messages.last.author, ChatAuthor.xiaxia);
    expect(harness.controller.messages.last.text, '我在。');
    expect(harness.controller.lastIntegrationReceipt?.conversationId, 'core-conversation');
    expect(harness.controller.lastIntegrationReceipt?.requestId, 'core-request');
    expect(harness.controller.lastIntegrationReceipt?.replyNonEmpty, isTrue);
    final reloaded = await ConversationStore(harness.preferences).load();
    expect(reloaded.coreConversationId, 'core-conversation');
    expect(reloaded.messages, hasLength(2));
  });

  test('first request omits Core conversation ID and follow-up reuses it', () async {
    final stub = StubCoreClient(
      reply: const CoreChatReply(
        reply: '我在。',
        conversationId: 'core-issued-conversation',
        requestId: 'core-request',
      ),
    );
    final harness = await createHarness(factory: StubCoreClientFactory(stub));

    await harness.controller.send('第一句');
    await harness.controller.send('第二句');

    expect(stub.requests, hasLength(2));
    expect(stub.requests.first.conversationId, isNull);
    expect(
      stub.requests.last.conversationId,
      'core-issued-conversation',
    );
    expect(harness.controller.coreConversationId, 'core-issued-conversation');
  });

  test('exposes an auditable retry state without inventing a reply', () async {
    final stub = StubCoreClient(
      error: const CoreClientException(
        CoreFailureKind.unavailable,
        '暂时无法连接 Xiaxia Core。',
      ),
    );
    final harness = await createHarness(factory: StubCoreClientFactory(stub));

    await harness.controller.send('你在吗');

    expect(harness.controller.messages, hasLength(1));
    expect(harness.controller.messages.single.deliveryState, DeliveryState.failed);
    expect(harness.controller.canRetry, isTrue);
    expect(harness.controller.errorMessage, contains('无法连接'));

    stub
      ..error = null
      ..reply = CoreChatReply(
        reply: '在。',
        conversationId: stub.lastRequest!.conversationId ?? 'core-conversation',
        requestId: 'retry-request',
      );
    await harness.controller.retry();
    expect(harness.controller.messages, hasLength(2));
    expect(harness.controller.messages.last.text, '在。');
  });
}
