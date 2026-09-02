import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/chat/chat_message.dart';

class StoredConversation {
  const StoredConversation({
    required this.coreConversationId,
    required this.messages,
  });

  final String? coreConversationId;
  final List<ChatMessage> messages;
}

class ConversationStore {
  ConversationStore(this._preferences);

  static const _conversationIdKey = 'xiaxia.chat.conversation_id';
  static const _messagesKey = 'xiaxia.chat.messages.v1';
  final SharedPreferences _preferences;

  Future<StoredConversation> load() async {
    final savedId = _preferences.getString(_conversationIdKey)?.trim();
    final coreConversationId = savedId == null ||
            savedId.isEmpty ||
            savedId.startsWith('app-')
        ? null
        : savedId;
    if (savedId != null && coreConversationId == null) {
      await _preferences.remove(_conversationIdKey);
    }
    final encoded = _preferences.getStringList(_messagesKey) ?? const [];
    final messages = <ChatMessage>[];
    for (final item in encoded) {
      try {
        final json = jsonDecode(item);
        if (json is Map<String, dynamic>) messages.add(ChatMessage.fromJson(json));
      } on FormatException {
        // Keep the healthy messages; a corrupt local row is not authoritative.
      }
    }
    return StoredConversation(
      coreConversationId: coreConversationId,
      messages: messages,
    );
  }

  Future<void> save(StoredConversation conversation) async {
    final coreConversationId = conversation.coreConversationId;
    if (coreConversationId == null) {
      await _preferences.remove(_conversationIdKey);
    } else {
      await _preferences.setString(_conversationIdKey, coreConversationId);
    }
    await _preferences.setStringList(
      _messagesKey,
      conversation.messages.map((message) => message.encode()).toList(),
    );
  }
}
