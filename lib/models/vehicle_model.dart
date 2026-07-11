class Vehicle {
  final String id;
  final String userId;
  final String modelName;
  final String? plateNumber;
  final String connectorType;
  final double batteryCapacity;
  final bool isPrimary;
  final String createdAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.modelName,
    this.plateNumber,
    required this.connectorType,
    required this.batteryCapacity,
    required this.isPrimary,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] ?? '',
        userId: json['user_id'] ?? '',
        modelName: json['model_name'] ?? '',
        plateNumber: json['plate_number'] as String?,
        connectorType: json['connector_type'] ?? 'CCS2',
        batteryCapacity: (json['battery_capacity'] as num?)?.toDouble() ?? 40.5,
        isPrimary: json['is_primary'] == true,
        createdAt: json['created_at'] ?? '',
      );
}
