import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/core/api/core_models.dart';
import 'package:xiaxia_app/features/settings/connection_settings_sheet.dart';

import '../test_support.dart';

void main() {
  testWidgets('renders machine status counts without private thought content', (
    tester,
  ) async {
    final harness = await createHarness();
    final stub = StubCoreClient(
      lifeStatus: LifeRuntimeStatusSnapshot(
        mode: 'idle',
        lastWakeAt: DateTime.utc(2026, 9, 21, 8),
        nextWakeAt: DateTime.utc(2026, 9, 21, 10),
        wakeCount: 2,
        cognitionCount: 1,
        tokenUsage: 3269,
        proactiveDeliveryCount: 1,
        activeActivityCount: 0,
        privateThoughtCount: 2,
        candidateCount: 0,
        lastOutcomeType: 'DELIVERY',
        lastOutcomeAt: DateTime.utc(2026, 9, 21, 8),
        sharedConversationReady: true,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConnectionSettingsSheet(
            repository: harness.repository,
            clientFactory: StubCoreClientFactory(stub),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('refresh-life-status')));
    await tester.tap(find.byKey(const Key('refresh-life-status')));
    await tester.pumpAndSettle();

    expect(find.text('Mode: idle'), findsOneWidget);
    expect(find.textContaining('Wakes 2'), findsOneWidget);
    expect(find.textContaining('Private thoughts: 2'), findsOneWidget);
    expect(find.textContaining('私人念头内容'), findsNothing);
  });

  testWidgets('renders no next wake without exposing private content', (
    tester,
  ) async {
    final harness = await createHarness();
    final stub = StubCoreClient(
      lifeStatus: LifeRuntimeStatusSnapshot(
        mode: 'idle',
        lastWakeAt: DateTime.utc(2026, 9, 21, 8),
        nextWakeAt: null,
        wakeCount: 0,
        cognitionCount: 0,
        tokenUsage: 0,
        proactiveDeliveryCount: 0,
        activeActivityCount: 0,
        privateThoughtCount: 1,
        candidateCount: 0,
        lastOutcomeType: 'REST',
        lastOutcomeAt: DateTime.utc(2026, 9, 21, 8),
        sharedConversationReady: true,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConnectionSettingsSheet(
            repository: harness.repository,
            clientFactory: StubCoreClientFactory(stub),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('refresh-life-status')));
    await tester.tap(find.byKey(const Key('refresh-life-status')));
    await tester.pumpAndSettle();

    expect(find.text('Next wake: —'), findsOneWidget);
    expect(find.textContaining('私人念头内容'), findsNothing);
  });
}
