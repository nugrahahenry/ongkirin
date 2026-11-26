import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/errors/api_exception.dart';
import '../models/location_reference.dart';
import '../models/shipping_option.dart';

class RajaOngkirService {
  final http.Client client;
  final String baseUrl;

  RajaOngkirService({http.Client? client, String? baseUrl})
    : client = client ?? http.Client(),
      baseUrl = baseUrl ?? AppConfig.baseUrl;

  void close() => client.close();

  Future<List<LocationReference>> searchLocations({
    required String apiKey,
    required String query,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/destination/domestic-destination',
    ).replace(queryParameters: {'search': query, 'limit': '10', 'offset': '0'});
    final response = await _get(uri, apiKey);
    final payload = _decode(response);
    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) =>
                LocationReference.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.id > 0)
          .toList();
    }
    return const [];
  }

  Future<List<ShippingOption>> calculateCost({
    required String apiKey,
    required int originId,
    required int destinationId,
    required int weightGrams,
    required String courier,
  }) async {
    if (courier == AppConfig.allCouriers) {
      return _calculateForAllCouriers(
        apiKey: apiKey,
        originId: originId,
        destinationId: destinationId,
        weightGrams: weightGrams,
      );
    }
    return _calculateForCourier(
      apiKey: apiKey,
      originId: originId,
      destinationId: destinationId,
      weightGrams: weightGrams,
      courier: courier,
    );
  }

  Future<List<ShippingOption>> _calculateForAllCouriers({
    required String apiKey,
    required int originId,
    required int destinationId,
    required int weightGrams,
  }) async {
    final results = await Future.wait(
      AppConfig.supportedCourierCodes.map(
        (courier) => _calculateForCourierSafely(
          apiKey: apiKey,
          originId: originId,
          destinationId: destinationId,
          weightGrams: weightGrams,
          courier: courier,
        ),
      ),
    );
    return results.expand((options) => options).toList();
  }

  Future<List<ShippingOption>> _calculateForCourierSafely({
    required String apiKey,
    required int originId,
    required int destinationId,
    required int weightGrams,
    required String courier,
  }) async {
    try {
      return await _calculateForCourier(
        apiKey: apiKey,
        originId: originId,
        destinationId: destinationId,
        weightGrams: weightGrams,
        courier: courier,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 400 ||
          error.statusCode == 404 ||
          error.statusCode == 422) {
        return const [];
      }
      rethrow;
    }
  }

  Future<List<ShippingOption>> _calculateForCourier({
    required String apiKey,
    required int originId,
    required int destinationId,
    required int weightGrams,
    required String courier,
  }) async {
    final uri = Uri.parse('$baseUrl/calculate/domestic-cost');
    final response = await _runRequest(
      () => client.post(
        uri,
        headers: {
          'key': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'origin': '$originId',
          'destination': '$destinationId',
          'weight': '$weightGrams',
          'courier': courier,
          'price': 'lowest',
        },
      ),
      timeout: const Duration(seconds: 20),
    );
    final payload = _decode(response);
    final currentData = payload['data'];
    if (currentData is List) {
      return currentData
          .whereType<Map>()
          .map(
            (item) =>
                ShippingOption.fromCurrentJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    final legacyRoot = payload['rajaongkir'];
    if (legacyRoot is Map) {
      final results = legacyRoot['results'];
      if (results is List) {
        return results.whereType<Map>().expand((courierData) {
          final courierMap = Map<String, dynamic>.from(courierData);
          final costs = courierMap['costs'];
          if (costs is! List) return <ShippingOption>[];
          return costs.whereType<Map>().map((service) {
            return ShippingOption.fromLegacyJson(
              courierMap,
              Map<String, dynamic>.from(service),
            );
          });
        }).toList();
      }
    }
    return const [];
  }

  Future<http.Response> _get(Uri uri, String apiKey) {
    return _runRequest(
      () => client.get(uri, headers: {'key': apiKey}),
      timeout: const Duration(seconds: 15),
    );
  }

  Future<http.Response> _runRequest(
    Future<http.Response> Function() request, {
    required Duration timeout,
  }) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'Request terlalu lama. Periksa koneksi internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Chrome memblokir koneksi langsung ke API. Jalankan Ongkirin di Android atau Windows untuk menguji API.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? responseMessage;
      try {
        final body = jsonDecode(response.body);
        if (body is Map) {
          final meta = body['meta'];
          responseMessage = '${body['message'] ?? ''}'.trim();
          if (responseMessage.isEmpty && meta is Map) {
            responseMessage = '${meta['message'] ?? ''}'.trim();
          }
        }
      } on FormatException {
        responseMessage = null;
      }
      throw ApiException(
        responseMessage?.isNotEmpty == true
            ? responseMessage!
            : _messageForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const ApiException('Format response API tidak dikenali.');
      }
      final payload = Map<String, dynamic>.from(decoded);
      final meta = payload['meta'];
      if (meta is Map) {
        final status = '${meta['status'] ?? ''}'.toLowerCase();
        final code = int.tryParse('${meta['code'] ?? ''}');
        final failed =
            status == 'false' ||
            status == 'error' ||
            (code != null && code >= 400);
        if (failed) {
          throw ApiException(
            '${meta['message'] ?? 'Request API gagal.'}',
            statusCode: code,
          );
        }
      }
      return payload;
    } on FormatException {
      throw const ApiException('Response API tidak dapat dibaca.');
    }
  }

  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Parameter request tidak valid atau layanan tidak tersedia.';
      case 401:
        return 'API key tidak valid atau belum diisi.';
      case 404:
        return 'Endpoint RajaOngkir tidak ditemukan.';
      case 422:
        return 'Kurir atau parameter pengiriman tidak valid.';
      case 502:
        return 'Proxy tidak bisa menghubungi RajaOngkir. Periksa terminal proxy dan koneksi internet.';
      default:
        return 'Layanan RajaOngkir sedang bermasalah (HTTP $statusCode). Coba lagi.';
    }
  }
}
