import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/xiaxia_app.dart';
import 'core/api/production_core_client_factory.dart';
import 'core/config/core_connection_repository.dart';
import 'core/config/secure_token_store.dart';
import 'core/persistence/conversation_store.dart';
import 'features/chat/chat_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final connectionRepository = CoreConnectionRepository(
    preferences: preferences,
    tokenStore: const PlatformSecureTokenStore(),
  );
  final chatController = ChatController(
    store: ConversationStore(preferences),
    connectionRepository: connectionRepository,
    clientFactory: const ProductionCoreClientFactory(),
  );
  await chatController.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(
    XiaxiaApp(
      chatController: chatController,
      connectionRepository: connectionRepository,
    ),
  );
}
