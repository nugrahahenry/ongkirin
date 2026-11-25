class GeoAddress {
  final List<String> searchTerms;

  const GeoAddress({required this.searchTerms});
}

class GeoLocationProvider {
  Future<GeoAddress> resolveAddress() async {
    throw StateError(
      'Lokasi otomatis hanya tersedia saat izin lokasi didukung.',
    );
  }
}

GeoLocationProvider createGeoLocationProvider() => GeoLocationProvider();
