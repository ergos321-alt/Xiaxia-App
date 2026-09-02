import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/app/xiaxia_app.dart';

import '../test_support.dart';

void main() {
  testWidgets('shows a retryable Core error without a fabricated Xiaxia message', (tester) async {
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
  });
}
