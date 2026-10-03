import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/api/core_client.dart';
import '../../core/api/core_diagnostics_client.dart';
import '../../core/api/core_models.dart';
import '../../core/api/production_core_contract_adapter.dart';
import '../../core/api/production_core_client_factory.dart';
import '../../core/config/core_connection_config.dart';
import '../../core/config/core_connection_repository.dart';
import '../../design_system/xiaxia_tokens.dart';

class ConnectionSettingsSheet extends StatefulWidget {
  const ConnectionSettingsSheet({
    super.key,
    required this.repository,
    this.clientFactory = const ProductionCoreClientFactory(),
  });

  final CoreConnectionRepository repository;
  final CoreClientFactory clientFactory;

  @override
  State<ConnectionSettingsSheet> createState() =>
      _ConnectionSettingsSheetState();
}

class _ConnectionSettingsSheetState extends State<ConnectionSettingsSheet> {
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _checking = false;
  bool _obscure = true;
  String? _error;
  String? _diagnosticsMessage;
  bool _lifeChecking = false;
  String? _lifeError;
  LifeRuntimeStatusSnapshot? _lifeStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final config = await widget.repository.load();
      _urlController.text = config.baseUrl?.toString() ?? '';
      _tokenController.text = config.bearerToken;
    } catch (_) {
      _error = '无法读取这台设备上的连接信息。';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.save(
        baseUrl: _urlController.text,
        bearerToken: _tokenController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = '连接信息没有保存成功。');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _checkCore() async {
    final baseUrl = CoreConnectionConfig.parseBaseUrl(_urlController.text);
    if (baseUrl == null) {
      setState(() => _diagnosticsMessage = '请先填写有效的 Core 地址。');
      return;
    }
    setState(() {
      _checking = true;
      _diagnosticsMessage = null;
    });
    final client = CoreDiagnosticsClient(
      config: CoreConnectionConfig(
        baseUrl: baseUrl,
        bearerToken: _tokenController.text.trim(),
      ),
      adapter: const ProductionCoreContractAdapter(),
    );
    try {
      final health = await client.checkHealth();
      if (health.status != 'ok') {
        throw const CoreClientException(
          CoreFailureKind.unavailable,
          'Core health 当前不是可用状态。',
        );
      }
      if (_tokenController.text.trim().isNotEmpty) {
        await client.checkStatus();
        _diagnosticsMessage = 'Core health 与受保护状态接口验证成功。';
      } else {
        _diagnosticsMessage = 'Core health 验证成功；未验证受保护状态接口。';
      }
    } on CoreClientException catch (error) {
      _diagnosticsMessage = error.userMessage;
    } finally {
      client.close();
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _refreshLifeStatus() async {
    final baseUrl = CoreConnectionConfig.parseBaseUrl(_urlController.text);
    final token = _tokenController.text.trim();
    if (baseUrl == null || token.isEmpty) {
      setState(() => _lifeError = '请先填写 Core 地址和访问凭证。');
      return;
    }
    setState(() {
      _lifeChecking = true;
      _lifeError = null;
    });
    CoreClient? client;
    try {
      client = widget.clientFactory.create(
        CoreConnectionConfig(baseUrl: baseUrl, bearerToken: token),
      );
      final status = await client.fetchLifeStatus();
      if (mounted) setState(() => _lifeStatus = status);
    } on CoreClientException catch (error) {
      if (mounted) setState(() => _lifeError = error.userMessage);
    } catch (_) {
      if (mounted) setState(() => _lifeError = '无法读取 Life Runtime 状态。');
    } finally {
      client?.close();
      if (mounted) setState(() => _lifeChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          XiaxiaSpacing.lg,
          XiaxiaSpacing.lg,
          XiaxiaSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + XiaxiaSpacing.lg,
        ),
        child: _loading
            ? const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '连接 Xiaxia Core',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: XiaxiaSpacing.xs),
                    Text(
                      '地址保存在本机；访问凭证由 Android 安全存储保护。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: XiaxiaSpacing.lg),
                    TextField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Core 地址',
                        hintText: 'https://core.example.com',
                      ),
                    ),
                    const SizedBox(height: XiaxiaSpacing.sm),
                    TextField(
                      controller: _tokenController,
                      obscureText: _obscure,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: '访问凭证',
                        suffixIcon: IconButton(
                          tooltip: _obscure ? '显示' : '隐藏',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: XiaxiaSpacing.sm),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (kDebugMode) ...[
                      const SizedBox(height: XiaxiaSpacing.md),
                      OutlinedButton.icon(
                        key: const Key('verify-core-button'),
                        onPressed: _checking ? null : _checkCore,
                        icon: const Icon(Icons.health_and_safety_outlined),
                        label: Text(
                          _checking ? '正在验证…' : 'Developer · 验证 Core',
                        ),
                      ),
                      if (_diagnosticsMessage != null) ...[
                        const SizedBox(height: XiaxiaSpacing.xs),
                        Text(
                          _diagnosticsMessage!,
                          key: const Key('core-diagnostics-result'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                    const SizedBox(height: XiaxiaSpacing.lg),
                    _LifeRuntimePanel(
                      status: _lifeStatus,
                      error: _lifeError,
                      loading: _lifeChecking,
                      onRefresh: _refreshLifeStatus,
                    ),
                    const SizedBox(height: XiaxiaSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? '正在保存…' : '保存'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LifeRuntimePanel extends StatelessWidget {
  const _LifeRuntimePanel({
    required this.status,
    required this.error,
    required this.loading,
    required this.onRefresh,
  });

  final LifeRuntimeStatusSnapshot? status;
  final String? error;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final value = status;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(XiaxiaSpacing.md),
        child: Column(
          key: const Key('life-runtime-status'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Life Runtime',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: const Key('refresh-life-status'),
                  tooltip: '刷新 Runtime 状态',
                  onPressed: loading ? null : onRefresh,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (value == null)
              Text(
                '点击刷新查看最近一次 wake。',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else ...[
              Text('Mode: ${value.mode}', key: const Key('life-mode')),
              Text('Last wake: ${_formatTime(value.lastWakeAt)}'),
              Text('Next wake: ${value.nextWakeAt == null ? '—' : _formatTime(value.nextWakeAt!)}'),
              const SizedBox(height: XiaxiaSpacing.xs),
              Text(
                'Today · Wakes ${value.wakeCount} · Cognitions ${value.cognitionCount} '
                '· Tokens ${value.tokenUsage} · Proactive ${value.proactiveDeliveryCount}',
                key: const Key('life-today'),
              ),
              Text('Active activities: ${value.activeActivityCount}'),
              Text(
                'Private thoughts: ${value.privateThoughtCount} · '
                'Candidates: ${value.candidateCount}',
              ),
              Text(
                'Last outcome: ${value.lastOutcomeType ?? 'none'} '
                '(${_formatTime(value.lastOutcomeAt)})',
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime? value) {
    if (value == null) return 'none';
    final local = value.toLocal();
    String two(int part) => part.toString().padLeft(2, '0');
    return '${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}

Future<void> showConnectionSettings(
  BuildContext context,
  CoreConnectionRepository repository, {
  CoreClientFactory clientFactory = const ProductionCoreClientFactory(),
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ConnectionSettingsSheet(
      repository: repository,
      clientFactory: clientFactory,
    ),
  );
}
