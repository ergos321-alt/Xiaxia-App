import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/app/xiaxia_app.dart';

import '../test_support.dart';

void main() {
  testWidgets('Home is presence-first and only exposes two navigation destinations', (tester) async {
    final harness = await createHarness();
    await tester.pumpWidget(
      XiaxiaApp(
        chatController: harness.controller,
        connectionRepository: harness.repository,
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pump();

    expect(find.text('Xiaxia'), findsOneWidget);
    expect(find.bySemanticsLabel('窗边留着书与杯子的安静房间'), findsOneWidget);
    expect(find.byKey(const Key('nav-home')), findsOneWidget);
    expect(find.byKey(const Key('nav-chat')), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(2));
  });
}
