import 'package:flutter/material.dart';

import '../../design_system/xiaxia_tokens.dart';
import '../../domain/chat/chat_message.dart';
import 'chat_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.controller,
    required this.onOpenSettings,
  });

  final ChatController controller;
  final VoidCallback onOpenSettings;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: XiaxiaMotion.gentle,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _send() async {
    final value = _textController.text;
    if (value.trim().isEmpty || widget.controller.sending) return;
    _textController.clear();
    await widget.controller.send(value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _ChatHeader(onOpenSettings: widget.onOpenSettings),
          const Divider(height: 1),
          Expanded(
            child: controller.messages.isEmpty
                ? const _EmptyConversation()
                : ListView.separated(
                    key: const Key('message-list'),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      XiaxiaSpacing.md,
                      XiaxiaSpacing.lg,
                      XiaxiaSpacing.md,
                      XiaxiaSpacing.xl,
                    ),
                    itemCount: controller.messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: XiaxiaSpacing.md),
                    itemBuilder: (_, index) => _MessageLine(message: controller.messages[index]),
                  ),
          ),
          if (controller.errorMessage != null)
            _CoreErrorBar(
              message: controller.errorMessage!,
              canRetry: controller.canRetry,
              onRetry: controller.retry,
              onSettings: widget.onOpenSettings,
            ),
          _Composer(
            controller: _textController,
            sending: controller.sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        XiaxiaSpacing.lg,
        XiaxiaSpacing.sm,
        XiaxiaSpacing.sm,
        XiaxiaSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco_outlined, color: Theme.of(context).colorScheme.primary, size: 18),
          ),
          const SizedBox(width: XiaxiaSpacing.sm),
          Expanded(
            child: Text('夏夏', style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton(
            tooltip: '连接设置',
            onPressed: onOpenSettings,
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(XiaxiaSpacing.xl),
        child: Text(
          '这里会留下你们的对话。',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _MessageLine extends StatelessWidget {
  const _MessageLine({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.author == ChatAuthor.user;
    final surface = Theme.of(context).brightness == Brightness.dark
        ? (fromUser ? const Color(0xFF394037) : const Color(0xFF292C28))
        : (fromUser ? XiaxiaColors.sagePale : XiaxiaColors.warmWhiteRaised);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(message.timestamp.toLocal()),
      alwaysUse24HourFormat: true,
    );

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Column(
          crossAxisAlignment: fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!fromUser)
              Padding(
                padding: const EdgeInsets.only(left: XiaxiaSpacing.xs, bottom: XiaxiaSpacing.xxs),
                child: Text('夏夏', style: Theme.of(context).textTheme.bodySmall),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(160)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: XiaxiaSpacing.md,
                  vertical: XiaxiaSpacing.sm,
                ),
                child: Text(message.text, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: XiaxiaSpacing.xxs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: Theme.of(context).textTheme.bodySmall),
                if (message.deliveryState == DeliveryState.sending) ...[
                  const SizedBox(width: 6),
                  const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5)),
                ],
                if (message.deliveryState == DeliveryState.failed) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.error_outline, size: 14, color: Theme.of(context).colorScheme.error),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoreErrorBar extends StatelessWidget {
  const _CoreErrorBar({
    required this.message,
    required this.canRetry,
    required this.onRetry,
    required this.onSettings,
  });

  final String message;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('core-error-state'),
      width: double.infinity,
      color: Theme.of(context).colorScheme.error.withAlpha(18),
      padding: const EdgeInsets.symmetric(horizontal: XiaxiaSpacing.md, vertical: XiaxiaSpacing.xs),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: XiaxiaSpacing.xs),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
          if (canRetry)
            TextButton(onPressed: onRetry, child: const Text('重试')),
          TextButton(onPressed: onSettings, child: const Text('连接')),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          XiaxiaSpacing.sm,
          XiaxiaSpacing.xs,
          XiaxiaSpacing.sm,
          XiaxiaSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const Key('chat-input'),
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: '说点什么…',
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: XiaxiaSpacing.xs),
            IconButton.filled(
              key: const Key('send-message-button'),
              tooltip: '发送',
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
