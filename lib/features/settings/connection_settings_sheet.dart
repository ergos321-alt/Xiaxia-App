import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/api/core_client.dart';
import '../../core/api/core_diagnostics_client.dart';
import '../../core/api/production_core_contract_adapter.dart';
import '../../core/config/core_connection_config.dart';
import '../../core/config/core_connection_repository.dart';
import '../../design_system/xiaxia_tokens.dart';

class ConnectionSettingsSheet extends StatefulWidget {
  const ConnectionSettingsSheet({
    super.key,
    required this.repository,
  });

  final CoreConnectionRepository repository;

  @override
  State<ConnectionSettingsSheet> createState() => _ConnectionSettingsSheetState();
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
                    Text('连接 Xiaxia Core', style: Theme.of(context).textTheme.headlineSmall),
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
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: XiaxiaSpacing.sm),
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    if (kDebugMode) ...[
                      const SizedBox(height: XiaxiaSpacing.md),
                      OutlinedButton.icon(
                        key: const Key('verify-core-button'),
                        onPressed: _checking ? null : _checkCore,
                        icon: const Icon(Icons.health_and_safety_outlined),
                        label: Text(_checking ? '正在验证…' : 'Developer · 验证 Core'),
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

Future<void> showConnectionSettings(
  BuildContext context,
  CoreConnectionRepository repository,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ConnectionSettingsSheet(repository: repository),
  );
}
