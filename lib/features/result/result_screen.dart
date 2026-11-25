import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/shipping_option.dart';
import '../calculator/calculator_controller.dart';

class ResultScreen extends StatelessWidget {
  final CalculatorController controller;

  const ResultScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Ongkos Kirim')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            _buildSummary(),
            const SizedBox(height: 20),
            if (controller.status == CalculationStatus.empty)
              _buildEmpty(context)
            else
              ...controller.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOptionCard(option, formatter),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Ubah parameter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.route_rounded, color: Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${controller.origin?.name ?? '-'}  →  ${controller.destination?.name ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${controller.weightInGrams ?? 0} g',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(ShippingOption option, NumberFormat formatter) {
    final highlighted = option.isCheapest;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? const Color(0xFFF59E0B)
              : const Color(0xFFE2E8F0),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: highlighted
                ? const Color(0xFFFFEDD5)
                : const Color(0xFFE6FFFB),
            child: Icon(
              Icons.local_shipping_rounded,
              color: highlighted
                  ? const Color(0xFFB45309)
                  : const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${option.courierName} • ${option.service}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (highlighted) const _CheapestBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  formatter.format(option.cost),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estimasi ${option.etd}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: Color(0xFF64748B), size: 42),
          SizedBox(height: 12),
          Text(
            'Belum ada layanan tersedia',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          SizedBox(height: 6),
          Text(
            'Coba ubah rute, berat, atau pilihan kurir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _CheapestBadge extends StatelessWidget {
  const _CheapestBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Termurah',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF451A03),
        ),
      ),
    );
  }
}
