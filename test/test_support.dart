import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaxia_app/core/api/core_client.dart';
import 'package:xiaxia_app/core/api/core_models.dart';
import 'package:xiaxia_app/core/config/core_connection_config.dart';
import 'package:xiaxia_app/core/config/core_connection_repository.dart';
import 'package:xiaxia_app/core/config/secure_token_store.dart';
import 'package:xiaxia_app/core/persistence/conversation_store.dart';
import 'package:xiaxia_app/features/chat/chat_controller.dart';

class TestHarness {
  TestHarness({
    required this.preferences,
    required this.tokenStore,
    required this.repository,
    required this.controller,
  });

  final SharedPreferences preferences;
  final MemorySecureTokenStore tokenStore;
  final CoreConnectionRepository repository;
  final ChatController controller;
}

Future<TestHarness> createHarness({
  CoreClientFactory? factory,
  bool configured = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final tokenStore = MemorySecureTokenStore();
  final repository = CoreConnectionRepository(
    preferences: preferences,
    tokenStore: tokenStore,
  );
  if (configured) {
    await repository.save(
      baseUrl: 'https://core.example.test',
      bearerToken: 'test-token',
    );
  }
  final controller = ChatController(
    store: ConversationStore(preferences),
    connectionRepository: repository,
    clientFactory:
        factory ??
        StubCoreClientFactory(
          StubCoreClient(
            error: const CoreClientException(
              CoreFailureKind.unavailable,
              '暂时无法连接 Xiaxia Core。',
            ),
          ),
        ),
  );
  await controller.initialize();
  return TestHarness(
    preferences: preferences,
    tokenStore: tokenStore,
    repository: repository,
    controller: controller,
  );
}

class StubCoreClientFactory implements CoreClientFactory {
  StubCoreClientFactory(this.client);
  final CoreClient client;

  @override
  CoreClient create(CoreConnectionConfig config) => client;
}

class StubCoreClient implements CoreClient {
  StubCoreClient({
    this.reply,
    this.error,
    this.proactiveMessages = const [],
    this.lifeStatus,
  });
  CoreChatReply? reply;
  CoreClientException? error;
  List<CoreProactiveMessage> proactiveMessages;
  LifeRuntimeStatusSnapshot? lifeStatus;
  CoreChatRequest? lastRequest;
  final List<CoreChatRequest> requests = [];
  final List<String> registeredConversations = [];

  @override
  Future<CoreChatReply> sendChat(CoreChatRequest request) async {
    lastRequest = request;
    requests.add(request);
    final failure = error;
    if (failure != null) throw failure;
    return reply ??
        CoreChatReply(
          reply: '我在。',
          conversationId: request.conversationId ?? 'core-conversation-1',
          requestId: 'request-${requests.length}',
        );
  }

  @override
  Future<void> registerSharedConversation(String conversationId) async {
    final failure = error;
    if (failure != null) throw failure;
    registeredConversations.add(conversationId);
  }

  @override
  Future<List<CoreProactiveMessage>> fetchProactiveMessages(
    String conversationId, {
    int afterId = 0,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    return proactiveMessages
        .where((message) => message.id > afterId)
        .toList(growable: false);
  }

  @override
  Future<LifeRuntimeStatusSnapshot> fetchLifeStatus() async {
    final failure = error;
    if (failure != null) throw failure;
    return lifeStatus ??
        LifeRuntimeStatusSnapshot(
          mode: 'idle',
          lastWakeAt: null,
          nextWakeAt: DateTime.utc(2026, 9, 21, 12),
          wakeCount: 0,
          cognitionCount: 0,
          tokenUsage: 0,
          proactiveDeliveryCount: 0,
          activeActivityCount: 0,
          privateThoughtCount: 0,
          candidateCount: 0,
          lastOutcomeType: null,
          lastOutcomeAt: null,
          sharedConversationReady: false,
        );
  }

  @override
  void close() {}
}
