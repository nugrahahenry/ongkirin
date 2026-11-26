import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

class RouteMapPreview extends StatefulWidget {
  final String origin;
  final String destination;

  const RouteMapPreview({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<RouteMapPreview> createState() => _RouteMapPreviewState();
}

class _RouteMapPreviewState extends State<RouteMapPreview> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'ongkirin-route-map-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final iframe = html.IFrameElement()
        ..src = _embedUrl
        ..title = 'Pratinjau rute Google Maps'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      return iframe;
    });
  }

  String get _embedUrl {
    final uri = Uri.https('www.google.com', '/maps/embed/v1/directions', {
      'key': AppConfig.googleMapsEmbedKey,
      'origin': widget.origin,
      'destination': widget.destination,
      'mode': 'driving',
    });
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasGoogleMapsEmbedKey) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(height: 230, child: HtmlElementView(viewType: _viewType)),
    );
  }
}
