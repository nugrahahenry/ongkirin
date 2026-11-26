import 'package:flutter/foundation.dart';

class AppConfig {
  static const directBaseUrl = 'https://rajaongkir.komerce.id/api/v1';

  static bool get usesWebProxy => kIsWeb;

  static String get baseUrl {
    if (!kIsWeb) return directBaseUrl;
    final page = Uri.base;
    return Uri(
      scheme: page.scheme.isEmpty ? 'http' : page.scheme,
      host: page.host.isEmpty ? '127.0.0.1' : page.host,
      port: 8787,
      path: '/api/v1',
    ).toString();
  }

  static const allCouriers =
      'jne:sicepat:ide:sap:jnt:ninja:tiki:lion:pos:sentral:rex:wahana:spx';

  static const supportedCourierCodes = <String>[
    'jne',
    'sicepat',
    'ide',
    'sap',
    'jnt',
    'ninja',
    'tiki',
    'lion',
    'pos',
    'sentral',
    'rex',
    'wahana',
    'spx',
  ];

  static const courierOptions = <CourierChoice>[
    CourierChoice(label: 'Semua kurir', code: allCouriers),
    CourierChoice(label: 'JNE', code: 'jne'),
    CourierChoice(label: 'J&T', code: 'jnt'),
    CourierChoice(label: 'SiCepat', code: 'sicepat'),
    CourierChoice(label: 'Pos Indonesia', code: 'pos'),
  ];
}

class CourierChoice {
  final String label;
  final String code;

  const CourierChoice({required this.label, required this.code});
}
