import 'package:flutter/material.dart';

import '../../core/config/core_connection_repository.dart';
import '../../design_system/xiaxia_tokens.dart';
import '../../domain/presence/presence_state.dart';
import '../settings/connection_settings_sheet.dart';
import 'widgets/presence_scene.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onOpenChat,
    required this.connectionRepository,
    this.presence,
  });

  final VoidCallback onOpenChat;
  final CoreConnectionRepository connectionRepository;
  final PresenceState? presence;

  @override
  Widget build(BuildContext context) {
    final state = presence ?? PresenceDemoFixture.fromEnvironment();
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              XiaxiaSpacing.lg,
              XiaxiaSpacing.sm,
              XiaxiaSpacing.lg,
              XiaxiaSpacing.xxl,
            ),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Xiaxia', style: Theme.of(context).textTheme.displaySmall),
                    ),
                    IconButton(
                      key: const Key('connection-settings-button'),
                      tooltip: '连接设置',
                      onPressed: () => showConnectionSettings(context, connectionRepository),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: XiaxiaSpacing.lg),
                PresenceScene(presence: state),
                if (state.traceLine case final line?) ...[
                  const SizedBox(height: XiaxiaSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: XiaxiaSpacing.xs),
                    child: Text(line, style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ] else
                  const SizedBox(height: XiaxiaSpacing.sm),
                const SizedBox(height: XiaxiaSpacing.xl),
                Text('最近', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: XiaxiaSpacing.xs),
                _LifeRow(
                  key: const Key('open-chat-row'),
                  icon: Icons.chat_bubble_outline_rounded,
                  title: '聊天',
                  subtitle: '你们的对话留在这里',
                  onTap: onOpenChat,
                ),
                const Divider(height: 1),
                const _LifeRow(
                  icon: Icons.menu_book_outlined,
                  title: '一起读',
                  subtitle: 'Reading House · 预留',
                ),
                const Divider(height: 1),
                const _LifeRow(
                  icon: Icons.edit_note_rounded,
                  title: '日记',
                  subtitle: 'Diary House · 预留',
                ),
                const Divider(height: 1),
                const _LifeRow(
                  icon: Icons.photo_outlined,
                  title: '小瞬间',
                  subtitle: 'Moments · 预留',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeRow extends StatelessWidget {
  const _LifeRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: XiaxiaSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: XiaxiaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}
