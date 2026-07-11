class Battery {
  final String id;
  final String stationId;
  final String batteryCode;
  final String batteryType;
  final double capacity;
  final int healthPercent;
  final String status;

  Battery({
    required this.id,
    required this.stationId,
    required this.batteryCode,
    required this.batteryType,
    required this.capacity,  // kWh
    required this.healthPercent,
    required this.status,
  });

  factory Battery.fromJson(Map<String, dynamic> json) => Battery(
        id: json['id'] ?? '',
        stationId: json['station_id'] ?? '',
        batteryCode: json['battery_code'] ?? '',
        batteryType: json['battery_type'] ?? '',
        capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0,
        healthPercent: json['health_percent'] ?? 95,
        status: json['status'] ?? 'available',
      );

  bool get isAvailable => status == 'available';
}
