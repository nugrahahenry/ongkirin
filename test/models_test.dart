import 'package:flutter_test/flutter_test.dart';

import 'package:ongkirin/data/models/location_reference.dart';
import 'package:ongkirin/data/models/shipping_option.dart';

void main() {
  group('LocationReference', () {
    test('maps current destination response fields', () {
      final location = LocationReference.fromJson({
        'id': 501,
        'label': 'Kebayoran Baru',
        'district_name': 'Kebayoran Baru',
        'city_name': 'Jakarta Selatan',
        'province_name': 'DKI Jakarta',
      });

      expect(location.id, 501);
      expect(location.name, 'Kebayoran Baru');
      expect(
        location.hierarchyLabel,
        'Kebayoran Baru, Jakarta Selatan, DKI Jakarta',
      );
    });

    test('accepts legacy city id and name fields', () {
      final location = LocationReference.fromJson({
        'city_id': '39',
        'city_name': 'Bandung',
        'province_name': 'Jawa Barat',
      });

      expect(location.id, 39);
      expect(location.name, 'Bandung');
      expect(location.hierarchyLabel, 'Bandung, Jawa Barat');
    });

    test('ignores placeholder label when parsing a location', () {
      final location = LocationReference.fromJson({
        'id': 99,
        'label': '-',
        'subdistrict_name': 'Coblong',
        'city_name': 'Bandung',
        'province_name': 'Jawa Barat',
      });

      expect(location.name, 'Coblong');
      expect(location.hierarchyLabel, 'Coblong, Bandung, Jawa Barat');
    });
  });

  test('ShippingOption parses current cost response', () {
    final option = ShippingOption.fromCurrentJson({
      'name': 'JNE',
      'code': 'jne',
      'service': 'REG',
      'description': 'Layanan reguler',
      'cost': 18000,
      'etd': '2-3',
    });

    expect(option.courierName, 'JNE');
    expect(option.courierCode, 'jne');
    expect(option.service, 'REG');
    expect(option.cost, 18000);
    expect(option.etd, '2-3');
  });

  test('ShippingOption parses legacy cost response', () {
    final option = ShippingOption.fromLegacyJson(
      {'name': 'JNE', 'code': 'jne'},
      {
        'service': 'REG',
        'description': 'Layanan reguler',
        'cost': [
          {'value': 18000, 'etd': '2-3'},
        ],
      },
    );

    expect(option.courierName, 'JNE');
    expect(option.service, 'REG');
    expect(option.cost, 18000);
    expect(option.etd, '2-3');
  });
}
