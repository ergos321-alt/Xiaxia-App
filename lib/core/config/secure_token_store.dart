import 'package:flutter/services.dart';

abstract interface class SecureTokenStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

/// Android implementation backed by Android Keystore AES-GCM in MainActivity.
class PlatformSecureTokenStore implements SecureTokenStore {
  const PlatformSecureTokenStore();

  static const _channel = MethodChannel('com.xiaxia.app/secure_storage');

  @override
  Future<String?> read() => _channel.invokeMethod<String>('readCoreToken');

  @override
  Future<void> write(String value) {
    return _channel.invokeMethod<void>('writeCoreToken', {'value': value});
  }

  @override
  Future<void> delete() => _channel.invokeMethod<void>('deleteCoreToken');
}

class MemorySecureTokenStore implements SecureTokenStore {
  String? value;

  @override
  Future<void> delete() async => value = null;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}
