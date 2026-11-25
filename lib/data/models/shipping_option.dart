class ShippingOption {
  final String courierName;
  final String courierCode;
  final String service;
  final String description;
  final int cost;
  final String etd;
  final bool isCheapest;

  const ShippingOption({
    required this.courierName,
    required this.courierCode,
    required this.service,
    required this.description,
    required this.cost,
    required this.etd,
    this.isCheapest = false,
  });

  ShippingOption copyWith({bool? isCheapest}) {
    return ShippingOption(
      courierName: courierName,
      courierCode: courierCode,
      service: service,
      description: description,
      cost: cost,
      etd: etd,
      isCheapest: isCheapest ?? this.isCheapest,
    );
  }

  factory ShippingOption.fromCurrentJson(Map<String, dynamic> json) {
    final rawCost = json['cost'] ?? 0;
    return ShippingOption(
      courierName: '${json['name'] ?? ''}',
      courierCode: '${json['code'] ?? ''}',
      service: '${json['service'] ?? 'Layanan'}',
      description: '${json['description'] ?? ''}',
      cost: rawCost is int ? rawCost : int.tryParse('$rawCost') ?? 0,
      etd: '${json['etd'] ?? '-'}',
    );
  }

  factory ShippingOption.fromLegacyJson(
    Map<String, dynamic> courier,
    Map<String, dynamic> service,
  ) {
    final costList = service['cost'] as List<dynamic>? ?? const [];
    final firstCost = costList.isNotEmpty && costList.first is Map
        ? costList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final rawValue = firstCost['value'] ?? 0;
    return ShippingOption(
      courierName: '${courier['name'] ?? ''}',
      courierCode: '${courier['code'] ?? ''}',
      service: '${service['service'] ?? 'Layanan'}',
      description: '${service['description'] ?? ''}',
      cost: rawValue is int ? rawValue : int.tryParse('$rawValue') ?? 0,
      etd: '${firstCost['etd'] ?? '-'}',
    );
  }
}
