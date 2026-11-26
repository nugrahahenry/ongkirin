import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:ongkirin/core/config/app_config.dart';
import 'package:ongkirin/data/services/rajaongkir_service.dart';

void main() {
  test(
    'all couriers keeps valid results when one courier is unavailable',
    () async {
      final client = _CourierClient();
      final service = RajaOngkirService(
        client: client,
        baseUrl: 'https://example.test/api/v1',
      );

      final options = await service.calculateCost(
        apiKey: 'test-key',
        originId: 1,
        destinationId: 2,
        weightGrams: 250,
        courier: AppConfig.allCouriers,
      );

      expect(options, hasLength(1));
      expect(options.single.courierCode, 'jne');
      expect(client.requestedCouriers.length, greaterThan(1));
      service.close();
    },
  );
}

class _CourierClient extends http.BaseClient {
  final requestedCouriers = <String>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final requestBody = await request.finalize().bytesToString();
    final courier = Uri.splitQueryString(requestBody)['courier'] ?? '';
    requestedCouriers.add(courier);

    if (courier != 'jne') {
      return _response(request, 422, {
        'meta': {'message': 'Invalid Courier', 'code': 422, 'status': 'error'},
      });
    }
    return _response(request, 200, {
      'meta': {'message': 'Success', 'code': 200, 'status': 'success'},
      'data': [
        {
          'name': 'JNE',
          'code': 'jne',
          'service': 'REG',
          'description': 'Layanan reguler',
          'cost': 12000,
          'etd': '2-3',
        },
      ],
    });
  }

  http.StreamedResponse _response(
    http.BaseRequest request,
    int statusCode,
    Map<String, dynamic> payload,
  ) {
    final bytes = utf8.encode(jsonEncode(payload));
    return http.StreamedResponse(
      Stream.value(bytes),
      statusCode,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}
