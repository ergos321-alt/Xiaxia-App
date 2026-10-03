import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/app/xiaxia_app.dart';
import 'package:xiaxia_app/core/api/core_models.dart';
import 'package:xiaxia_app/features/chat/chat_page.dart';

import '../test_support.dart';

void main() {
  testWidgets(
    'shows a retryable Core error without a fabricated Xiaxia message',
    (tester) async {
      final harness = await createHarness();
      await tester.pumpWidget(
        XiaxiaApp(
          chatController: harness.controller,
          connectionRepository: harness.repository,
        ),
      );
      await tester.tap(find.byKey(const Key('nav-chat')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('chat-input')), '你在吗');
      await tester.tap(find.byKey(const Key('send-message-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('core-error-state')), findsOneWidget);
      expect(find.text('暂时无法连接 Xiaxia Core。'), findsOneWidget);
      expect(harness.controller.messages, hasLength(1));
    },
  );

  testWidgets('startup resume and manual refresh use one deduplicated sync', (
    tester,
  ) async {
    final stub = StubCoreClient(
      reply: const CoreChatReply(
        reply: '我在。',
        conversationId: 'shared-conversation',
        requestId: 'request-1',
      ),
      proactiveMessages: [
        CoreProactiveMessage(
          id: 42,
          content: '主动消息',
          createdAt: DateTime.now(),
        ),
      ],
    );
    final harness = await createHarness(factory: StubCoreClientFactory(stub));
    await harness.controller.send('先建立共享对话');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatPage(controller: harness.controller, onOpenSettings: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(stub.registeredConversations, hasLength(1));

    await tester.tap(find.byKey(const Key('refresh-proactive-messages')));
    await tester.pumpAndSettle();
    expect(stub.registeredConversations, hasLength(2));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(stub.registeredConversations, hasLength(3));
    expect(find.text('主动消息'), findsOneWidget);
    expect(
      harness.controller.messages.where(
        (message) => message.id == 'proactive-42',
      ),
      hasLength(1),
    );
  });
}
