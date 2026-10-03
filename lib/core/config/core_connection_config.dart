class CoreConnectionConfig {
  const CoreConnectionConfig({
    required this.baseUrl,
    required this.bearerToken,
  });

  static final productionBaseUrl = Uri.parse('https://browser.linzhixia.cn');

  final Uri? baseUrl;
  final String bearerToken;

  bool get isConfigured => baseUrl != null && bearerToken.trim().isNotEmpty;

  static Uri? parseBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
    if (uri.scheme != 'https') return null;
    return uri.replace(path: uri.path.replaceFirst(RegExp(r'/$'), ''));
  }
}
