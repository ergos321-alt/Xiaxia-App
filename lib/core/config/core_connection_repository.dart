import 'package:shared_preferences/shared_preferences.dart';

import 'core_connection_config.dart';
import 'secure_token_store.dart';

class CoreConnectionRepository {
  CoreConnectionRepository({
    required SharedPreferences preferences,
    required SecureTokenStore tokenStore,
  }) : _preferences = preferences,
       _tokenStore = tokenStore;

  static const _baseUrlKey = 'xiaxia.core.base_url';

  final SharedPreferences _preferences;
  final SecureTokenStore _tokenStore;

  Future<CoreConnectionConfig> load() async {
    final savedUrl = _preferences.getString(_baseUrlKey);
    final token = await _tokenStore.read() ?? '';
    return CoreConnectionConfig(
      baseUrl: savedUrl == null
          ? CoreConnectionConfig.productionBaseUrl
          : CoreConnectionConfig.parseBaseUrl(savedUrl),
      bearerToken: token,
    );
  }

  Future<void> save({
    required String baseUrl,
    required String bearerToken,
  }) async {
    final parsed = CoreConnectionConfig.parseBaseUrl(baseUrl);
    if (parsed == null) throw const FormatException('请输入有效的 Core 地址');
    await _preferences.setString(_baseUrlKey, parsed.toString());
    if (bearerToken.trim().isEmpty) {
      await _tokenStore.delete();
    } else {
      await _tokenStore.write(bearerToken.trim());
    }
  }
}
