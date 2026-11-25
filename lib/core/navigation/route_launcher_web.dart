import 'dart:html' as html;

Future<bool> openDrivingRoute({
  required String origin,
  required String destination,
}) async {
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'origin': origin,
    'destination': destination,
    'travelmode': 'driving',
  });
  html.window.open(uri.toString(), '_blank');
  return true;
}
