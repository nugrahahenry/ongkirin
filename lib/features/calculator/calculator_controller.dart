import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/api_exception.dart';
import '../../core/location/current_location_service.dart';
import '../../core/storage/api_key_storage.dart';
import '../../core/storage/location_history_storage.dart';
import '../../data/models/location_reference.dart';
import '../../data/models/shipping_option.dart';
import '../../data/services/rajaongkir_service.dart';

enum CalculationStatus { idle, loading, success, empty, failure }

class CalculatorController extends ChangeNotifier {
  final RajaOngkirService service;
  final FlutterSecureStorage secureStorage;
  final ApiKeyStorage apiKeyStorage;
  final LocationHistoryStorage locationHistoryStorage;
  final CurrentLocationService currentLocationService;

  CalculatorController({
    RajaOngkirService? service,
    FlutterSecureStorage? secureStorage,
    LocationHistoryStorage? locationHistoryStorage,
    CurrentLocationService? currentLocationService,
  }) : service = service ?? RajaOngkirService(),
       secureStorage = secureStorage ?? const FlutterSecureStorage(),
       apiKeyStorage = createApiKeyStorage(secureStorage),
       locationHistoryStorage =
           locationHistoryStorage ??
           createLocationHistoryStorage(secureStorage),
       currentLocationService =
           currentLocationService ?? CurrentLocationService();

  String? apiKey;
  LocationReference? origin;
  LocationReference? destination;
  String weightText = '';
  String weightUnit = 'kg';
  CourierChoice selectedCourier = AppConfig.courierOptions.first;
  CalculationStatus status = CalculationStatus.idle;
  String? errorMessage;
  List<ShippingOption> options = const [];
  List<LocationReference> recentDestinations = const [];

  bool get hasApiKey =>
      AppConfig.usesWebProxy || (apiKey != null && apiKey!.trim().isNotEmpty);
  bool get isLoading => status == CalculationStatus.loading;

  Future<void> loadSavedApiKey() async {
    apiKey = await apiKeyStorage.read();
    recentDestinations = await locationHistoryStorage.read();
    notifyListeners();
  }

  Future<void> saveApiKey(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const ApiException('API key belum diisi.');
    }
    await apiKeyStorage.write(trimmed);
    apiKey = trimmed;
    errorMessage = null;
    notifyListeners();
  }

  void setOrigin(LocationReference value) {
    origin = value;
    _clearError();
    notifyListeners();
  }

  void setDestination(LocationReference value) {
    destination = value;
    recentDestinations = [
      value,
      ...recentDestinations.where((item) => item.id != value.id),
    ].take(5).toList();
    unawaited(locationHistoryStorage.write(recentDestinations));
    _clearError();
    notifyListeners();
  }

  Future<LocationReference> resolveCurrentOrigin() {
    return currentLocationService.resolveOrigin(
      apiKey: apiKey ?? '',
      service: service,
    );
  }

  void swapLocations() {
    final currentOrigin = origin;
    origin = destination;
    destination = currentOrigin;
    _clearError();
    notifyListeners();
  }

  void setWeight(String value) {
    weightText = value;
    _clearError();
    notifyListeners();
  }

  void setWeightUnit(String value) {
    weightUnit = value;
    notifyListeners();
  }

  void setWeightPreset(int grams) {
    _setWeightFromGrams(grams);
    _clearError();
    notifyListeners();
  }

  void addWeight(int grams) {
    final currentGrams = weightInGrams ?? 0;
    _setWeightFromGrams(currentGrams + grams);
    _clearError();
    notifyListeners();
  }

  void _setWeightFromGrams(int grams) {
    if (grams >= 1000) {
      weightUnit = 'kg';
      final kilograms = grams / 1000;
      weightText = kilograms == kilograms.roundToDouble()
          ? kilograms.toInt().toString()
          : kilograms.toString();
    } else {
      weightUnit = 'gram';
      weightText = '$grams';
    }
  }

  void setCourier(CourierChoice value) {
    selectedCourier = value;
    notifyListeners();
  }

  int? get weightInGrams {
    final parsed = double.tryParse(weightText.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return null;
    final grams = weightUnit == 'kg' ? parsed * 1000 : parsed;
    return grams.round() > 0 ? grams.round() : null;
  }

  String? get validationMessage {
    if (!AppConfig.usesWebProxy && !hasApiKey) {
      return 'Tambahkan API key RajaOngkir terlebih dahulu.';
    }
    if (origin == null) return 'Pilih kota asal pengiriman.';
    if (destination == null) return 'Pilih kota tujuan pengiriman.';
    if (weightInGrams == null) {
      return 'Masukkan berat paket yang lebih besar dari nol.';
    }
    return null;
  }

  Future<void> calculate() async {
    final validation = validationMessage;
    if (validation != null) {
      errorMessage = validation;
      status = CalculationStatus.failure;
      notifyListeners();
      return;
    }

    status = CalculationStatus.loading;
    errorMessage = null;
    options = const [];
    notifyListeners();

    try {
      final result = await service.calculateCost(
        apiKey: apiKey ?? '',
        originId: origin!.id,
        destinationId: destination!.id,
        weightGrams: weightInGrams!,
        courier: selectedCourier.code,
      );
      options = _markCheapest(result);
      status = options.isEmpty
          ? CalculationStatus.empty
          : CalculationStatus.success;
    } on ApiException catch (error) {
      status = CalculationStatus.failure;
      errorMessage = error.message;
    } on Exception {
      status = CalculationStatus.failure;
      errorMessage = 'Koneksi gagal. Periksa internet lalu coba lagi.';
    }
    notifyListeners();
  }

  void resetResult() {
    status = CalculationStatus.idle;
    errorMessage = null;
    options = const [];
    notifyListeners();
  }

  List<ShippingOption> _markCheapest(List<ShippingOption> input) {
    if (input.isEmpty) return input;
    final cheapest = input
        .map((item) => item.cost)
        .reduce((value, item) => value < item ? value : item);
    return input
        .map((item) => item.copyWith(isCheapest: item.cost == cheapest))
        .toList();
  }

  void _clearError() {
    if (status == CalculationStatus.failure) {
      status = CalculationStatus.idle;
      errorMessage = null;
    }
  }

  @override
  void dispose() {
    service.close();
    super.dispose();
  }
}
