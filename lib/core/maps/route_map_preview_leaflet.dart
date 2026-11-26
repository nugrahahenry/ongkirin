import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

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
    _viewType = 'ongkirin-leaflet-route-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final iframe = html.IFrameElement()
        ..title = 'Pratinjau rute Ongkirin'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..attributes['allow'] = 'fullscreen'
        ..attributes['srcdoc'] = _document;
      return iframe;
    });
  }

  String get _routeEndpoint {
    final page = Uri.base;
    return Uri(
      scheme: page.scheme.isEmpty ? 'http' : page.scheme,
      host: page.host.isEmpty ? '127.0.0.1' : page.host,
      port: 8787,
      path: '/maps/route',
    ).toString();
  }

  String get _document {
    final endpoint = jsonEncode(_routeEndpoint);
    final origin = jsonEncode(widget.origin);
    final destination = jsonEncode(widget.destination);
    return '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
<style>
html, body, #map { width: 100%; height: 100%; margin: 0; }
body { overflow: hidden; font-family: Arial, sans-serif; }
#status { position: absolute; z-index: 1000; top: 12px; left: 12px; right: 12px; padding: 9px 11px; border-radius: 9px; background: rgba(255,255,255,.94); color: #334155; font-size: 12px; box-shadow: 0 2px 8px rgba(15,23,42,.18); }
</style>
</head>
<body>
<div id="map"></div>
<div id="status">Memuat rute...</div>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const endpoint = $endpoint;
const origin = $origin;
const destination = $destination;
const status = document.getElementById('status');
const map = L.map('map').setView([-2.5, 118], 5);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);

function formatDistance(meters) {
  return meters >= 1000 ? (meters / 1000).toFixed(1) + ' km' : Math.round(meters) + ' m';
}

function formatDuration(seconds) {
  const minutes = Math.round(seconds / 60);
  if (minutes < 60) return minutes + ' menit';
  const hours = Math.floor(minutes / 60);
  const remaining = minutes % 60;
  return hours + ' jam' + (remaining ? ' ' + remaining + ' menit' : '');
}

fetch(endpoint + '?origin=' + encodeURIComponent(origin) + '&destination=' + encodeURIComponent(destination))
  .then(response => response.json().then(payload => ({ ok: response.ok, payload })))
  .then(result => {
    if (!result.ok) throw new Error(result.payload.message || 'Rute tidak tersedia.');
    const data = result.payload;
    const start = [data.origin.latitude, data.origin.longitude];
    const end = [data.destination.latitude, data.destination.longitude];
    const points = data.route.geometry.coordinates.map(pair => [pair[1], pair[0]]);
    L.marker(start).addTo(map).bindPopup('Asal<br>' + data.origin.label);
    L.marker(end).addTo(map).bindPopup('Tujuan<br>' + data.destination.label);
    const line = L.polyline(points, { color: '#0f766e', weight: 5, opacity: .85 }).addTo(map);
    map.fitBounds(line.getBounds(), { padding: [24, 24] });
    status.textContent = formatDistance(data.route.distanceMeters) + ' · ' + formatDuration(data.route.durationSeconds) + ' · rute mobil';
  })
  .catch(error => {
    status.textContent = error.message || 'Rute peta belum tersedia.';
  });
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(height: 230, child: HtmlElementView(viewType: _viewType)),
    );
  }
}
