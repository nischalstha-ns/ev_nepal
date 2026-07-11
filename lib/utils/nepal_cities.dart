import 'dart:math';

class NepalCity {
  final String name;
  final String province;
  final double latitude;
  final double longitude;

  const NepalCity({
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
  });
}

class NepalCities {
  static const List<NepalCity> cities = [
    // Province 1
    NepalCity(name: 'Biratnagar', province: 'Province 1', latitude: 26.4525, longitude: 87.2718),
    NepalCity(name: 'Dharan', province: 'Province 1', latitude: 26.8149, longitude: 87.2834),
    NepalCity(name: 'Itahari', province: 'Province 1', latitude: 26.6648, longitude: 87.2706),
    NepalCity(name: 'Damak', province: 'Province 1', latitude: 26.6602, longitude: 87.7009),

    // Province 2 (Madhesh)
    NepalCity(name: 'Janakpur', province: 'Madhesh', latitude: 26.7288, longitude: 85.9242),
    NepalCity(name: 'Birgunj', province: 'Madhesh', latitude: 27.0104, longitude: 84.8760),
    NepalCity(name: 'Kalaiya', province: 'Madhesh', latitude: 27.0323, longitude: 85.0007),

    // Bagmati Province
    NepalCity(name: 'Kathmandu', province: 'Bagmati', latitude: 27.7172, longitude: 85.3240),
    NepalCity(name: 'Lalitpur', province: 'Bagmati', latitude: 27.6767, longitude: 85.3240),
    NepalCity(name: 'Bhaktapur', province: 'Bagmati', latitude: 27.6710, longitude: 85.4298),
    NepalCity(name: 'Hetauda', province: 'Bagmati', latitude: 27.4287, longitude: 85.0326),
    NepalCity(name: 'Bharatpur', province: 'Bagmati', latitude: 27.6782, longitude: 84.4350),
    NepalCity(name: 'Chitwan', province: 'Bagmati', latitude: 27.5291, longitude: 84.3542),

    // Gandaki Province
    NepalCity(name: 'Pokhara', province: 'Gandaki', latitude: 28.2096, longitude: 83.9856),
    NepalCity(name: 'Gorkha', province: 'Gandaki', latitude: 28.2630, longitude: 84.6263),
    NepalCity(name: 'Lamjung', province: 'Gandaki', latitude: 28.2458, longitude: 84.3773),

    // Lumbini Province
    NepalCity(name: 'Butwal', province: 'Lumbini', latitude: 27.7005, longitude: 83.4480),
    NepalCity(name: 'Bhairahawa', province: 'Lumbini', latitude: 27.5077, longitude: 83.4503),
    NepalCity(name: 'Tansen', province: 'Lumbini', latitude: 27.8669, longitude: 83.5503),
    NepalCity(name: 'Nepalgunj', province: 'Lumbini', latitude: 28.0504, longitude: 81.6169),

    // Karnali Province
    NepalCity(name: 'Birendranagar', province: 'Karnali', latitude: 28.6009, longitude: 81.6296),
    NepalCity(name: 'Jumla', province: 'Karnali', latitude: 29.2747, longitude: 82.1838),

    // Sudurpashchim Province
    NepalCity(name: 'Dhangadhi', province: 'Sudurpashchim', latitude: 28.6942, longitude: 80.5897),
    NepalCity(name: 'Mahendranagar', province: 'Sudurpashchim', latitude: 28.9645, longitude: 80.1779),
    NepalCity(name: 'Dadeldhura', province: 'Sudurpashchim', latitude: 29.3000, longitude: 80.5833),
  ];

  static List<NepalCity> searchCities(String query) {
    if (query.isEmpty) return cities;

    final lowerQuery = query.toLowerCase();
    return cities.where((city) {
      return city.name.toLowerCase().contains(lowerQuery) ||
             city.province.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static NepalCity? findCity(String name) {
    try {
      return cities.firstWhere(
        (city) => city.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Calculate distance between two cities using Haversine formula
  static double calculateDistance(NepalCity from, NepalCity to) {
    const earthRadius = 6371.0; // Earth's radius in kilometers

    final lat1 = _toRadians(from.latitude);
    final lon1 = _toRadians(from.longitude);
    final lat2 = _toRadians(to.latitude);
    final lon2 = _toRadians(to.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Get popular routes (commonly traveled)
  static List<String> getPopularRoutes() {
    return [
      'Kathmandu → Pokhara',
      'Kathmandu → Chitwan',
      'Kathmandu → Butwal',
      'Kathmandu → Birgunj',
      'Pokhara → Butwal',
      'Pokhara → Chitwan',
      'Kathmandu → Biratnagar',
      'Kathmandu → Nepalgunj',
    ];
  }

  /// Get suggestions based on partial input
  static List<String> getSuggestions(String input) {
    if (input.isEmpty) return cities.take(5).map((c) => c.name).toList();

    final results = searchCities(input);
    return results.take(5).map((c) => c.name).toList();
  }
}
