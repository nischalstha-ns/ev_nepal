import 'dart:math';

class Station {
  final String id;
  final String name;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? openingTime;
  final String? closingTime;
  final String? contactNumber;
  final double rating;
  final bool isApproved;
  final bool hasBatterySwap;
  final List<String> amenities;
  int availableChargers;
  int totalChargers;
  int queueCount;
  int acChargerCount;
  int dcChargerCount;
  double? maxAcKw;
  double? maxDcKw;
  double? minPricePerKwh;

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.openingTime,
    this.closingTime,
    this.contactNumber,
    this.rating = 4.5,
    this.isApproved = false,
    this.hasBatterySwap = false,
    this.amenities = const [],
    this.availableChargers = 0,
    this.totalChargers = 0,
    this.queueCount = 0,
    this.acChargerCount = 0,
    this.dcChargerCount = 0,
    this.maxAcKw,
    this.maxDcKw,
    this.minPricePerKwh,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    int availableChargers = 0;
    int totalChargers = 0;
    int acChargerCount = 0;
    int dcChargerCount = 0;
    double? maxAcKw;
    double? maxDcKw;
    double? minPricePerKwh;

    final rawChargers = json['chargers'];
    if (rawChargers is List && rawChargers.isNotEmpty) {
      final cs = rawChargers.map((c) => c as Map<String, dynamic>).toList();
      totalChargers = cs.length;
      availableChargers = cs.where((c) => c['status'] == 'available').length;
      for (final c in cs) {
        final type = (c['charger_type'] as String?)?.toLowerCase() ?? '';
        final power = (c['power_kw'] as num?)?.toDouble();
        final price = (c['price_per_kwh'] as num?)?.toDouble();
        if (type == 'ac') {
          acChargerCount++;
          if (power != null) {
            maxAcKw = maxAcKw == null ? power : max(maxAcKw, power);
          }
        } else if (type == 'dc') {
          dcChargerCount++;
          if (power != null) {
            maxDcKw = maxDcKw == null ? power : max(maxDcKw, power);
          }
        }
        if (price != null) {
          minPricePerKwh = minPricePerKwh == null ? price : min(minPricePerKwh, price);
        }
      }
    }

    return Station(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['image_url'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      contactNumber: json['contact_number'],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      isApproved: json['is_approved'] ?? false,
      hasBatterySwap: json['has_battery_swap'] ?? false,
      amenities: (json['amenities'] as List?)?.cast<String>() ?? const [],
      availableChargers: availableChargers,
      totalChargers: totalChargers,
      acChargerCount: acChargerCount,
      dcChargerCount: dcChargerCount,
      maxAcKw: maxAcKw,
      maxDcKw: maxDcKw,
      minPricePerKwh: minPricePerKwh,
    );
  }
}
