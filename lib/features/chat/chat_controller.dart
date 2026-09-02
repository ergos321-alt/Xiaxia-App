import 'package:flutter/foundation.dart';

import '../../core/api/core_client.dart';
import '../../core/api/core_models.dart';
import '../../core/config/core_connection_repository.dart';
import '../../core/persistence/conversation_store.dart';
import '../../domain/chat/chat_message.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required ConversationStore store,
    required CoreConnectionRepository connectionRepository,
    required CoreClientFactory clientFactory,
  })  : _store = store,
        _connectionRepository = connectionRepository,
        _clientFactory = clientFactory;

  final ConversationStore _store;
  final CoreConnectionRepository _connectionRepository;
  final CoreClientFactory _clientFactory;

  final List<ChatMessage> _messages = [];
  String? _coreConversationId;
  bool _sending = false;
  String? _errorMessage;
  String? _failedMessageId;
  CoreIntegrationReceipt? _lastIntegrationReceipt;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;
  String? get errorMessage => _errorMessage;
  bool get canRetry => _failedMessageId != null && !_sending;
  String? get coreConversationId => _coreConversationId;
  CoreIntegrationReceipt? get lastIntegrationReceipt => _lastIntegrationReceipt;

  Future<void> initialize() async {
    final stored = await _store.load();
    _coreConversationId = stored.coreConversationId;
    _messages
      ..clear()
      ..addAll(stored.messages);
    notifyListeners();
  }

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _sending) return;

    final message = ChatMessage(
      id: _newId('user'),
      author: ChatAuthor.user,
      text: text,
      timestamp: DateTime.now(),
      deliveryState: DeliveryState.sending,
    );
    _messages.add(message);
    _errorMessage = null;
    _failedMessageId = null;
    await _persist();
    notifyListeners();
    await _requestReply(message);
  }

  Future<void> retry() async {
    final failedId = _failedMessageId;
    if (failedId == null || _sending) return;
    final message = _messages.where((item) => item.id == failedId).firstOrNull;
    if (message == null) return;
    await _requestReply(message.copyWith(deliveryState: DeliveryState.sending));
  }

  Future<void> _requestReply(ChatMessage userMessage) async {
    _replace(userMessage.copyWith(deliveryState: DeliveryState.sending));
    _sending = true;
    _errorMessage = null;
    notifyListeners();

    CoreClient? client;
    try {
      final config = await _connectionRepository.load();
      if (!config.isConfigured) {
        throw const CoreClientException(
          CoreFailureKind.missingConfiguration,
          '请先完成 Core 连接配置。',
        );
      }
      client = _clientFactory.create(config);
      final reply = await client.sendChat(
        CoreChatRequest(
          message: userMessage.text,
          conversationId: _coreConversationId,
        ),
      );
      _coreConversationId = reply.conversationId;
      _lastIntegrationReceipt = CoreIntegrationReceipt(
        httpStatus: reply.diagnostics.httpStatus,
        conversationId: reply.conversationId,
        requestId: reply.requestId,
        replyNonEmpty: reply.reply.trim().isNotEmpty,
      );
      if (kDebugMode) {
        debugPrint(
          'Core integration receipt: '
          'status=${reply.diagnostics.httpStatus ?? 'unknown'} '
          'conversation_id=${reply.conversationId} '
          'request_id=${reply.requestId} '
          'reply_non_empty=${reply.reply.trim().isNotEmpty}',
        );
      }
      _replace(userMessage.copyWith(deliveryState: DeliveryState.sent));
      _messages.add(
        ChatMessage(
          id: _newId('xiaxia'),
          author: ChatAuthor.xiaxia,
          text: reply.reply,
          timestamp: DateTime.now(),
        ),
      );
      _failedMessageId = null;
    } on CoreClientException catch (error) {
      _replace(userMessage.copyWith(deliveryState: DeliveryState.failed));
      _failedMessageId = userMessage.id;
      _errorMessage = error.userMessage;
    } catch (_) {
      _replace(userMessage.copyWith(deliveryState: DeliveryState.failed));
      _failedMessageId = userMessage.id;
      _errorMessage = '连接出现了意外问题。';
    } finally {
      client?.close();
      _sending = false;
      await _persist();
      notifyListeners();
    }
  }

  void _replace(ChatMessage updated) {
    final index = _messages.indexWhere((message) => message.id == updated.id);
    if (index >= 0) _messages[index] = updated;
  }

  Future<void> _persist() => _store.save(
        StoredConversation(
          coreConversationId: _coreConversationId,
          messages: _messages,
        ),
      );

  static String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}

class CoreIntegrationReceipt {
  const CoreIntegrationReceipt({
    required this.httpStatus,
    required this.conversationId,
    required this.requestId,
    required this.replyNonEmpty,
  });

  final int? httpStatus;
  final String conversationId;
  final String requestId;
  final bool replyNonEmpty;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
