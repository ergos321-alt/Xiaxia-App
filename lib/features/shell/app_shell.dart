import 'package:flutter/material.dart';

import '../../core/config/core_connection_repository.dart';
import '../chat/chat_controller.dart';
import '../chat/chat_page.dart';
import '../home/home_page.dart';
import '../settings/connection_settings_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.chatController,
    required this.connectionRepository,
  });

  final ChatController chatController;
  final CoreConnectionRepository connectionRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _openChat() => setState(() => _index = 1);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onOpenChat: _openChat,
        connectionRepository: widget.connectionRepository,
      ),
      ChatPage(
        controller: widget.chatController,
        onOpenSettings: () => showConnectionSettings(context, widget.connectionRepository),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            key: Key('nav-home'),
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            key: Key('nav-chat'),
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
