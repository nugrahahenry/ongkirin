import '../../data/models/location_reference.dart';

class LocationHistoryStorage {
  Future<List<LocationReference>> read() async => const [];

  Future<void> write(List<LocationReference> locations) async {}
}

LocationHistoryStorage createLocationHistoryStorage([Object? storage]) =>
    LocationHistoryStorage();
