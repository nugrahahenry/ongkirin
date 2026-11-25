import 'dart:html' as html;

class ApiKeyStorage {
  static const _storageKey = 'rajaongkir_api_key';

  Future<String?> read() async => html.window.localStorage[_storageKey];

  Future<void> write(String value) async {
    html.window.localStorage[_storageKey] = value;
  }
}

ApiKeyStorage createApiKeyStorage([Object? storage]) => ApiKeyStorage();
