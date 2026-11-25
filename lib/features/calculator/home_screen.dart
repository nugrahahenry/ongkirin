import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../data/models/location_reference.dart';
import '../location_search/location_search_sheet.dart';
import '../result/result_screen.dart';
import 'calculator_controller.dart';

class HomeScreen extends StatelessWidget {
  final CalculatorController controller;
  final VoidCallback onOpenApiSetup;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.onOpenApiSetup,
  });

  Future<void> _pickLocation(
    BuildContext context, {
    required bool origin,
  }) async {
    if (!controller.hasApiKey) {
      onOpenApiSetup();
      return;
    }
    final result = await showModalBottomSheet<LocationReference>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8FAFC),
      builder: (_) => LocationSearchSheet(
        apiKey: controller.apiKey ?? '',
        service: controller.service,
        title: origin ? 'Pilih kota asal' : 'Pilih kota tujuan',
      ),
    );
    if (result == null) return;
    if (origin) {
      controller.setOrigin(result);
    } else {
      controller.setDestination(result);
    }
  }

  Future<void> _calculate(BuildContext context) async {
    await controller.calculate();
    if (!context.mounted) return;
    if (controller.status == CalculationStatus.success ||
        controller.status == CalculationStatus.empty) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(controller: controller)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final validation = controller.validationMessage;
    final canCalculate = validation == null && !controller.isLoading;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Ongkirin', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          if (!AppConfig.usesWebProxy)
            IconButton(
              tooltip: 'Pengaturan API',
              onPressed: onOpenApiSetup,
              icon: const Icon(Icons.settings_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _buildHeroCard(),
            if (!controller.hasApiKey) ...[
              const SizedBox(height: 16),
              _buildApiWarning(context),
            ],
            const SizedBox(height: 24),
            const Text(
              'Detail pengiriman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _buildLocationField(
              context,
              label: 'Asal pengiriman',
              value: controller.origin,
              icon: Icons.my_location_rounded,
              onTap: () => _pickLocation(context, origin: true),
            ),
            const SizedBox(height: 12),
            _buildLocationField(
              context,
              label: 'Tujuan pengiriman',
              value: controller.destination,
              icon: Icons.location_on_rounded,
              onTap: () => _pickLocation(context, origin: false),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: controller.setWeight,
              decoration: InputDecoration(
                labelText: 'Berat paket',
                hintText: 'Masukkan berat',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.weightUnit,
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'gram', child: Text('gram')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setWeightUnit(value);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CourierChoice>(
              initialValue: controller.selectedCourier,
              decoration: const InputDecoration(
                labelText: 'Kurir',
                prefixIcon: Icon(Icons.local_shipping_outlined),
              ),
              items: AppConfig.courierOptions
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) controller.setCourier(value);
              },
            ),
            if (controller.errorMessage != null &&
                controller.status == CalculationStatus.failure) ...[
              const SizedBox(height: 16),
              _buildErrorCard(context),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: canCalculate ? () => _calculate(context) : null,
                icon: controller.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate_rounded),
                label: Text(
                  controller.isLoading
                      ? 'Menghitung...'
                      : 'Hitung Ongkos Kirim',
                ),
              ),
            ),
            if (validation != null && controller.hasApiKey) ...[
              const SizedBox(height: 10),
              Text(
                validation,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF123E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.route_rounded, color: Color(0xFFF59E0B), size: 30),
          SizedBox(height: 18),
          Text(
            'Cek ongkos kirim',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Bandingkan tarif pengiriman antarkota di Indonesia.',
            style: TextStyle(color: Color(0xFFCBD5E1), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildApiWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(90)),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, color: Color(0xFFB45309)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'API key belum diatur.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(onPressed: onOpenApiSetup, child: const Text('Atur')),
        ],
      ),
    );
  }

  Widget _buildLocationField(
    BuildContext context, {
    required String label,
    required LocationReference? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Text(
          value?.name ?? 'Pilih lokasi',
          style: TextStyle(
            color: value == null
                ? const Color(0xFF94A3B8)
                : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final isKeyError = controller.errorMessage!.toLowerCase().contains(
      'api key',
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.errorMessage!,
              style: const TextStyle(color: Color(0xFF991B1B), height: 1.35),
            ),
          ),
          if (isKeyError)
            IconButton(
              onPressed: onOpenApiSetup,
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
    );
  }
}
