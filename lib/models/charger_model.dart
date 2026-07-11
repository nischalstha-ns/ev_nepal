class Charger {
  final String id;
  final String stationId;
  final String name;
  final String chargerType;
  final String connectorType;
  final double powerKw;
  final double pricePerKwh;
  String status;

  Charger({
    required this.id,
    required this.stationId,
    required this.name,
    required this.chargerType,
    required this.connectorType,
    required this.powerKw,
    required this.pricePerKwh,
    required this.status,
  });

  factory Charger.fromJson(Map<String, dynamic> json) => Charger(
        id: json['id'] ?? '',
        stationId: json['station_id'] ?? '',
        name: json['name'] ?? '',
        chargerType: json['charger_type'] ?? 'DC',
        connectorType: json['connector_type'] ?? 'CCS2',
        powerKw: (json['power_kw'] as num?)?.toDouble() ?? 0,
        pricePerKwh: (json['price_per_kwh'] as num?)?.toDouble() ?? 0,
        status: json['status'] ?? 'available',
      );

  bool get isAvailable => status == 'available';
}
