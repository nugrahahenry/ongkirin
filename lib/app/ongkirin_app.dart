import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/api_setup/api_setup_screen.dart';
import '../features/calculator/calculator_controller.dart';
import '../features/calculator/home_screen.dart';

class OngkirinApp extends StatefulWidget {
  const OngkirinApp({super.key});

  @override
  State<OngkirinApp> createState() => _OngkirinAppState();
}

class _OngkirinAppState extends State<OngkirinApp> {
  late final CalculatorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalculatorController()..loadSavedApiKey();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ongkirin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => HomeScreen(
          controller: _controller,
          onOpenApiSetup: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ApiSetupScreen(controller: _controller),
            ),
          ),
        ),
      ),
    );
  }
}
