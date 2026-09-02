import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaxia_app/core/persistence/conversation_store.dart';

void main() {
  test('new local cache has no invented Core conversation ID', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final stored = await ConversationStore(preferences).load();

    expect(stored.coreConversationId, isNull);
  });

  test('legacy app-generated placeholder is discarded', () async {
    SharedPreferences.setMockInitialValues({
      'xiaxia.chat.conversation_id': 'app-123456',
    });
    final preferences = await SharedPreferences.getInstance();

    final stored = await ConversationStore(preferences).load();

    expect(stored.coreConversationId, isNull);
    expect(preferences.containsKey('xiaxia.chat.conversation_id'), isFalse);
  });

  test('Core-issued conversation ID persists unchanged', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ConversationStore(preferences);

    await store.save(
      const StoredConversation(
        coreConversationId: 'core-issued-id',
        messages: [],
      ),
    );
    final stored = await store.load();

    expect(stored.coreConversationId, 'core-issued-id');
  });
}
