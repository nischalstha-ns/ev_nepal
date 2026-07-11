class Booking {
  final String id;
  final String userId;
  final String stationId;
  final String chargerId;
  final int targetPercent;
  final String chargingOption;
  final double estimatedCost;
  final String status;
  final String paymentStatus;
  final String? qrToken;
  final String createdAt;
  final DateTime? startTime;

  Booking({
    required this.id,
    required this.userId,
    required this.stationId,
    required this.chargerId,
    required this.targetPercent,
    required this.chargingOption,
    required this.estimatedCost,
    required this.status,
    required this.paymentStatus,
    this.qrToken,
    required this.createdAt,
    this.startTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] ?? '',
        userId: json['user_id'] ?? '',
        stationId: json['station_id'] ?? '',
        chargerId: json['charger_id'] ?? '',
        targetPercent: json['target_percent'] ?? 80,
        chargingOption: json['charging_option'] ?? '80%',
        estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0,
        status: json['status'] ?? 'confirmed',
        paymentStatus: json['payment_status'] ?? 'paid',
        qrToken: json['qr_token'],
        createdAt: json['created_at'] ?? '',
        startTime: json['start_time'] != null
            ? DateTime.tryParse(json['start_time'] as String)
            : null,
      );
}
