import 'package:flutter/material.dart';

import '../core/config/core_connection_repository.dart';
import '../design_system/xiaxia_theme.dart';
import '../features/chat/chat_controller.dart';
import '../features/shell/app_shell.dart';

class XiaxiaApp extends StatelessWidget {
  const XiaxiaApp({
    super.key,
    required this.chatController,
    required this.connectionRepository,
    this.themeMode = ThemeMode.system,
  });

  final ChatController chatController;
  final CoreConnectionRepository connectionRepository;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xiaxia',
      debugShowCheckedModeBanner: false,
      theme: XiaxiaTheme.light(),
      darkTheme: XiaxiaTheme.dark(),
      themeMode: themeMode,
      home: AppShell(
        chatController: chatController,
        connectionRepository: connectionRepository,
      ),
    );
  }
}
