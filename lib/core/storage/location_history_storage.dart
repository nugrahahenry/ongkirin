export 'location_history_storage_stub.dart'
    if (dart.library.html) 'location_history_storage_web.dart'
    if (dart.library.io) 'location_history_storage_io.dart';
