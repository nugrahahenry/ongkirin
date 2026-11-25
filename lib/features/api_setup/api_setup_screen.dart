import 'package:flutter/material.dart';

import '../calculator/calculator_controller.dart';

class ApiSetupScreen extends StatefulWidget {
  final CalculatorController controller;

  const ApiSetupScreen({super.key, required this.controller});

  @override
  State<ApiSetupScreen> createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends State<ApiSetupScreen> {
  late final TextEditingController _keyController;
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(
      text: widget.controller.apiKey ?? '',
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.saveApiKey(_keyController.text);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan API')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE6FFFB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                color: Color(0xFF0F766E),
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hubungkan RajaOngkir',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan API key Shipping Cost dari dashboard RajaOngkir. Key disimpan secara lokal di perangkat.',
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _keyController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'API key RajaOngkir',
                hintText: 'Tempel API key di sini',
                errorText: _error,
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Tampilkan key' : 'Sembunyikan key',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: Color(0xFF0F766E),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jangan memasukkan key ke GitHub, screenshot, atau source code.',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan API Key'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
