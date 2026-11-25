import 'dart:convert';
import 'dart:html' as html;

import 'package:http/http.dart' as http;

class GeoAddress {
  final List<String> searchTerms;

  const GeoAddress({required this.searchTerms});
}

class GeoLocationProvider {
  Future<GeoAddress> resolveAddress() async {
    late final html.Geoposition position;
    try {
      position = await html.window.navigator.geolocation.getCurrentPosition();
    } catch (_) {
      throw StateError(
        'Izin lokasi ditolak atau Chrome membutuhkan HTTPS untuk membaca lokasi. Cari asal secara manual.',
      );
    }
    final latitude = position.coords?.latitude;
    final longitude = position.coords?.longitude;
    if (latitude == null || longitude == null) {
      throw StateError('Koordinat lokasi tidak tersedia.');
    }

    final page = Uri.base;
    final uri = Uri(
      scheme: page.scheme.isEmpty ? 'http' : page.scheme,
      host: page.host.isEmpty ? '127.0.0.1' : page.host,
      port: 8787,
      path: '/geocode/reverse',
      queryParameters: {'lat': '$latitude', 'lon': '$longitude'},
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Reverse geocoding gagal.');
    }
    final payload = jsonDecode(response.body);
    if (payload is! Map) throw StateError('Alamat lokasi tidak dikenali.');
    final address = payload['address'];
    if (address is! Map) throw StateError('Alamat lokasi tidak ditemukan.');

    final searchTerms = <String>[];
    for (final key in const [
      'suburb',
      'village',
      'neighbourhood',
      'city_district',
      'town',
      'city',
      'municipality',
      'state_district',
    ]) {
      final value = '${address[key] ?? ''}'.trim();
      if (value.isNotEmpty && !searchTerms.contains(value)) {
        searchTerms.add(value);
      }
    }
    if (searchTerms.isEmpty) {
      throw StateError('Nama wilayah dari lokasi tidak ditemukan.');
    }
    return GeoAddress(searchTerms: searchTerms);
  }
}

GeoLocationProvider createGeoLocationProvider() => GeoLocationProvider();
