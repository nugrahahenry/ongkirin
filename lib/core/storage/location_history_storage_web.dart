import 'dart:convert';
import 'dart:html' as html;

import '../../data/models/location_reference.dart';

class LocationHistoryStorage {
  static const _storageKey = 'ongkirin_recent_destinations';

  Future<List<LocationReference>> read() async {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null || raw.isEmpty) return const [];
    return _decode(raw);
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
    html.window.localStorage[_storageKey] = jsonEncode(payload);
  }

  List<LocationReference> _decode(String raw) {
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
}

LocationHistoryStorage createLocationHistoryStorage([Object? storage]) =>
    LocationHistoryStorage();
