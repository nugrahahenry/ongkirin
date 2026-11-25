import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/location_reference.dart';

class LocationHistoryStorage {
  static const _storageKey = 'ongkirin_recent_destinations';
  final FlutterSecureStorage _storage;

  LocationHistoryStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  Future<List<LocationReference>> read() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<Map>().map((item) {
        final value = Map<String, dynamic>.from(item);
        return LocationReference(
          id: value['id'] as int,
          name: '${value['name']}',
          hierarchyLabel: '${value['hierarchyLabel']}',
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> write(List<LocationReference> locations) async {
    final payload = locations
        .map(
          (location) => {
            'id': location.id,
            'name': location.name,
            'hierarchyLabel': location.hierarchyLabel,
          },
        )
        .toList();
    await _storage.write(key: _storageKey, value: jsonEncode(payload));
  }
}

LocationHistoryStorage createLocationHistoryStorage([Object? storage]) =>
    LocationHistoryStorage(storage is FlutterSecureStorage ? storage : null);
