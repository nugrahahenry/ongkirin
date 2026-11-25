class ApiKeyStorage {
  Future<String?> read() async => null;

  Future<void> write(String value) async {}
}

ApiKeyStorage createApiKeyStorage([Object? storage]) => ApiKeyStorage();
