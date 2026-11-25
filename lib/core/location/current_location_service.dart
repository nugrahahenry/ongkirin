import '../../core/errors/api_exception.dart';
import '../../data/models/location_reference.dart';
import '../../data/services/rajaongkir_service.dart';
import 'geo_location.dart';

class CurrentLocationService {
  final GeoLocationProvider provider;

  CurrentLocationService({GeoLocationProvider? provider})
    : provider = provider ?? createGeoLocationProvider();

  Future<LocationReference> resolveOrigin({
    required String apiKey,
    required RajaOngkirService service,
  }) async {
    final address = await provider.resolveAddress();
    for (final term in address.searchTerms) {
      final results = await service.searchLocations(
        apiKey: apiKey,
        query: term,
      );
      if (results.isNotEmpty) return results.first;
    }
    throw const ApiException(
      'Lokasi terdeteksi, tetapi wilayahnya belum cocok dengan data RajaOngkir. Cari asal secara manual.',
    );
  }
}
