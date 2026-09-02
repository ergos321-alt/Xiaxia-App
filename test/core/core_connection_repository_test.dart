import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaxia_app/core/config/core_connection_repository.dart';
import 'package:xiaxia_app/core/config/secure_token_store.dart';

void main() {
  test('stores the URL separately and keeps credentials in secure storage', () async {
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
  });
}
