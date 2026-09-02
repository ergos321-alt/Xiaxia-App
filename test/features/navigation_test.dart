import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/app/xiaxia_app.dart';

import '../test_support.dart';

void main() {
  testWidgets('opens Chat from the mobile navigation', (tester) async {
    final harness = await createHarness();
    await tester.pumpWidget(
      XiaxiaApp(
        chatController: harness.controller,
        connectionRepository: harness.repository,
      ),
    );

    await tester.tap(find.byKey(const Key('nav-chat')));
    await tester.pumpAndSettle();

    expect(find.text('夏夏'), findsOneWidget);
    expect(find.byKey(const Key('chat-input')), findsOneWidget);
  });
}
