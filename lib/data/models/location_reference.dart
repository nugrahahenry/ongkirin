class LocationReference {
  final int id;
  final String name;
  final String hierarchyLabel;

  const LocationReference({
    required this.id,
    required this.name,
    required this.hierarchyLabel,
  });

  factory LocationReference.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['id'] ??
        json['subdistrict_id'] ??
        json['district_id'] ??
        json['city_id'] ??
        json['province_id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    final name = _firstMeaningful([
      json['label'],
      json['name'],
      json['subdistrict_name'],
      json['district_name'],
      json['city_name'],
      'Lokasi',
    ]);
    final parts = <String>[
      if (json['subdistrict_name'] != null) '${json['subdistrict_name']}',
      if (json['district_name'] != null) '${json['district_name']}',
      if (json['city_name'] != null) '${json['city_name']}',
      if (json['province_name'] != null) '${json['province_name']}',
    ];
    return LocationReference(
      id: id,
      name: name,
      hierarchyLabel: parts.isEmpty ? name : parts.join(', '),
    );
  }

  static String _firstMeaningful(Iterable<Object?> values) {
    for (final value in values) {
      final text = '$value'.trim();
      if (text.isNotEmpty && text != '-') return text;
    }
    return 'Lokasi';
  }
}
