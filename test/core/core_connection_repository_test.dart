import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaxia_app/core/config/core_connection_config.dart';
import 'package:xiaxia_app/core/config/core_connection_repository.dart';
import 'package:xiaxia_app/core/config/secure_token_store.dart';

void main() {
  test('defaults a fresh install to the production HTTPS Core', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = CoreConnectionRepository(
      preferences: await SharedPreferences.getInstance(),
      tokenStore: MemorySecureTokenStore(),
    );

    final loaded = await repository.load();

    expect(loaded.baseUrl.toString(), 'https://browser.linzhixia.cn');
    expect(loaded.bearerToken, isEmpty);
  });

  test('rejects a cleartext Core URL', () {
    expect(CoreConnectionConfig.parseBaseUrl('http://43.108.8.99'), isNull);
  });

  test(
    'stores the URL separately and keeps credentials in secure storage',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final tokenStore = MemorySecureTokenStore();
      final repository = CoreConnectionRepository(
        preferences: preferences,
        tokenStore: tokenStore,
      );

      await repository.save(
        baseUrl: 'https://core.example.test/',
        bearerToken: 'private-token',
      );
      final loaded = await repository.load();

      expect(loaded.baseUrl.toString(), 'https://core.example.test');
      expect(loaded.bearerToken, 'private-token');
      expect(
        preferences.getKeys().map(preferences.get),
        isNot(contains('private-token')),
      );
    },
  );
}
