import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyStorage {
  static const _storageKey = 'rajaongkir_api_key';
  final FlutterSecureStorage _storage;

  ApiKeyStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> read() => _storage.read(key: _storageKey);

  Future<void> write(String value) =>
      _storage.write(key: _storageKey, value: value);
}

ApiKeyStorage createApiKeyStorage([Object? storage]) =>
    ApiKeyStorage(storage is FlutterSecureStorage ? storage : null);
