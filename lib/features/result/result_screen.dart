import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_config.dart';
import '../../core/maps/route_map_preview.dart';
import '../../core/navigation/route_launcher.dart';
import '../../data/models/shipping_option.dart';
import '../calculator/calculator_controller.dart';

enum _ResultFocus { all, cheapest, fastest }

class ResultScreen extends StatefulWidget {
  final CalculatorController controller;

  const ResultScreen({super.key, required this.controller});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  _ResultFocus _focus = _ResultFocus.all;
  String _courierFilter = 'Semua kurir';

  CalculatorController get controller => widget.controller;

  List<String> get _courierFilters {
    final names = controller.options.map((option) => option.courierName).toSet()
      ..removeWhere((name) => name.trim().isEmpty);
    return ['Semua kurir', ...names.toList()..sort()];
  }

  List<ShippingOption> get _visibleOptions {
    final filteredByCourier = controller.options
        .where(
          (option) =>
              _courierFilter == 'Semua kurir' ||
              option.courierName == _courierFilter,
        )
        .toList();
    if (filteredByCourier.isEmpty) return filteredByCourier;

    final cheapest = filteredByCourier
        .map((option) => option.cost)
        .reduce((first, second) => first < second ? first : second);
    final fastest = filteredByCourier
        .map((option) => _etdScore(option.etd))
        .reduce((first, second) => first < second ? first : second);
    final options = switch (_focus) {
      _ResultFocus.all => filteredByCourier,
      _ResultFocus.cheapest =>
        filteredByCourier.where((option) => option.cost == cheapest).toList(),
      _ResultFocus.fastest =>
        filteredByCourier
            .where((option) => _etdScore(option.etd) == fastest)
            .toList(),
    };
    options.sort((first, second) {
      final costOrder = first.cost.compareTo(second.cost);
      final speedOrder = _etdScore(first.etd).compareTo(_etdScore(second.etd));
      return _focus == _ResultFocus.fastest
          ? speedOrder != 0
                ? speedOrder
                : costOrder
          : costOrder != 0
          ? costOrder
          : speedOrder;
    });
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final visibleOptions = _visibleOptions;
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Ongkos Kirim')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            _buildSummary(),
            const SizedBox(height: 12),
            _buildRouteCard(),
            const SizedBox(height: 20),
            if (controller.status == CalculationStatus.empty)
              _buildEmpty(context)
            else ...[
              _buildControls(),
              const SizedBox(height: 16),
              if (visibleOptions.isEmpty)
                _buildFilteredEmpty()
              else
                ...visibleOptions.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOptionCard(option, formatter),
                  ),
                ),
            ],
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
              '${controller.origin?.name ?? '-'} → '
              '${controller.destination?.name ?? '-'}',
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

  Widget _buildRouteCard() {
    final origin = controller.origin?.hierarchyLabel ?? controller.origin?.name;
    final destination =
        controller.destination?.hierarchyLabel ?? controller.destination?.name;
    final canOpenRoute = origin != null && destination != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map_outlined, color: Color(0xFF1D4ED8)),
              SizedBox(width: 8),
              Text(
                'Rute perjalanan',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Lihat rute kendaraan dan estimasi perjalanan di Google Maps. Estimasi paket tetap mengikuti RajaOngkir.',
            style: TextStyle(color: Color(0xFF334155), height: 1.4),
          ),
          if (canOpenRoute && AppConfig.hasGoogleMapsEmbedKey) ...[
            const SizedBox(height: 12),
            RouteMapPreview(origin: origin, destination: destination),
            const SizedBox(height: 8),
            const Text(
              'Mode mobil ditampilkan sebagai pratinjau. Untuk pilihan kendaraan lain, buka Google Maps.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: 12),
            _buildMapSetupHint(),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canOpenRoute
                  ? () => openDrivingRoute(
                      origin: origin,
                      destination: destination,
                    )
                  : null,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Buka rute di Google Maps'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSetupHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(170),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 19, color: Color(0xFF1D4ED8)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Peta tertanam aktif jika build dijalankan dengan GOOGLE_MAPS_EMBED_KEY. Tanpa key, tombol di bawah tetap membuka rute Google Maps.',
              style: TextStyle(color: Color(0xFF334155), fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bandingkan pilihan',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Semua hasil'),
              avatar: const Icon(Icons.list_alt_rounded, size: 17),
              selected: _focus == _ResultFocus.all,
              onSelected: (_) => setState(() {
                _focus = _ResultFocus.all;
              }),
            ),
            FilterChip(
              label: const Text('Termurah'),
              avatar: const Icon(Icons.payments_outlined, size: 17),
              selected: _focus == _ResultFocus.cheapest,
              onSelected: (_) => setState(() {
                _focus = _ResultFocus.cheapest;
              }),
            ),
            FilterChip(
              label: const Text('Tercepat'),
              avatar: const Icon(Icons.bolt_rounded, size: 17),
              selected: _focus == _ResultFocus.fastest,
              onSelected: (_) => setState(() {
                _focus = _ResultFocus.fastest;
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _courierFilter,
          decoration: const InputDecoration(
            labelText: 'Filter kurir',
            prefixIcon: Icon(Icons.filter_alt_outlined),
          ),
          items: _courierFilters
              .map(
                (courier) =>
                    DropdownMenuItem(value: courier, child: Text(courier)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _courierFilter = value);
          },
        ),
      ],
    );
  }

  Widget _buildOptionCard(ShippingOption option, NumberFormat formatter) {
    final highlighted = option.isCheapest;
    final fastest =
        _etdScore(option.etd) ==
        _visibleOptions
            .map((item) => _etdScore(item.etd))
            .fold<int>(999, (best, value) => value < best ? value : best);
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        '${option.courierName} · ${option.service}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (highlighted) const _Badge(label: 'Termurah'),
                    if (fastest) const _Badge(label: 'Tercepat'),
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
                  'Estimasi kirim ${option.etd}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                if (option.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
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

  Widget _buildFilteredEmpty() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'Tidak ada layanan yang cocok dengan filter ini.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  int _etdScore(String etd) {
    final match = RegExp(r'\d+').firstMatch(etd);
    return int.tryParse(match?.group(0) ?? '') ?? 999;
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF92400E),
        ),
      ),
    );
  }
}
