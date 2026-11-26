import 'package:flutter/material.dart';

class RouteMapPreview extends StatelessWidget {
  final String origin;
  final String destination;

  const RouteMapPreview({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'Pratinjau peta tertanam tersedia pada Web. Gunakan tombol Google Maps untuk membuka rute di perangkat ini.',
        style: TextStyle(color: Color(0xFF475569), fontSize: 12, height: 1.35),
      ),
    );
  }
}
