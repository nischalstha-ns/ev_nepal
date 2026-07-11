import 'package:supabase_flutter/supabase_flutter.dart';

final _db = Supabase.instance.client;

class ApiService {
  // ── Stations ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getStations() async {
    final res = await _db
        .from('stations')
        .select('*, chargers(id, status, charger_type, power_kw, price_per_kwh)')
        .eq('is_approved', true)
        .order('name');
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getStation(String id) async {
    final res = await _db
        .from('stations')
        .select('*, chargers(*)')
        .eq('id', id)
        .single();
    return res;
  }

  // ── Chargers ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getChargers(String stationId) async {
    final res = await _db
        .from('chargers')
        .select()
        .eq('station_id', stationId)
        .order('name');
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateChargerStatus(
      String chargerId, String status) async {
    final res = await _db
        .from('chargers')
        .update({'status': status})
        .eq('id', chargerId)
        .select()
        .single();
    return res;
  }

  // ── Bookings ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createBooking({
    required String stationId,
    required String chargerId,
    required int targetPercent,
    required String chargingOption,
    required double estimatedCost,
    required String userId,
  }) async {
    // Generate a QR token locally — no backend needed
    final qrToken = 'EVC-${chargerId.substring(0, 4).toUpperCase()}-'
        '${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final booking = await _db.from('bookings').insert({
      'user_id': userId,
      'station_id': stationId,
      'charger_id': chargerId,
      'target_percent': targetPercent,
      'charging_option': chargingOption,
      'estimated_cost': estimatedCost,
      'status': 'confirmed',
      'payment_status': 'paid',
      'qr_token': qrToken,
    }).select().single();

    // Mark charger reserved
    await _db
        .from('chargers')
        .update({'status': 'reserved'})
        .eq('id', chargerId);

    return booking;
  }

  static Future<List<dynamic>> getBookings({String? stationId, String? userId}) async {
    var query = _db.from('bookings').select();
    if (stationId != null && userId != null) {
      final res = await query
          .eq('station_id', stationId)
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return res as List<dynamic>;
    } else if (stationId != null) {
      final res = await query
          .eq('station_id', stationId)
          .order('created_at', ascending: false);
      return res as List<dynamic>;
    } else if (userId != null) {
      final res = await query
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return res as List<dynamic>;
    }
    final res = await query.order('created_at', ascending: false);
    return res as List<dynamic>;
  }

  static Future<void> startCharging(String bookingId) async {
    final booking = await _db
        .from('bookings')
        .select('charger_id')
        .eq('id', bookingId)
        .single();

    await _db.from('bookings').update({
      'status': 'charging',
      'start_time': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', bookingId);

    await _db
        .from('chargers')
        .update({'status': 'occupied'})
        .eq('id', booking['charger_id']);
  }

  static Future<void> completeCharging(String bookingId) async {
    final booking = await _db
        .from('bookings')
        .select('charger_id')
        .eq('id', bookingId)
        .single();

    await _db
        .from('bookings')
        .update({'status': 'completed'})
        .eq('id', bookingId);

    await _db
        .from('chargers')
        .update({'status': 'available'})
        .eq('id', booking['charger_id']);
  }

  // ── Queue ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> joinQueue({
    required String stationId,
    required String chargerId,
    required String userId,
  }) async {
    // Count existing waiting entries for position
    final waiting = await _db
        .from('queues')
        .select('id')
        .eq('charger_id', chargerId)
        .eq('status', 'waiting');
    final position = (waiting as List).length + 1;
    final estimatedWait = position * 30;

    final entry = await _db.from('queues').insert({
      'user_id': userId,
      'station_id': stationId,
      'charger_id': chargerId,
      'position': position,
      'status': 'waiting',
    }).select().single();

    return {
      ...entry,
      'position': position,
      'estimated_wait_minutes': estimatedWait,
    };
  }

  static Future<void> callNextInQueue(String queueEntryId) async {
    await _db
        .from('queues')
        .update({'status': 'called'})
        .eq('id', queueEntryId);
  }

  // ── Admin Dashboard ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAdminDashboard() async {
    final stations = await _db.from('stations').select('id, is_approved');
    final chargers = await _db.from('chargers').select('id, status');
    final bookings = await _db.from('bookings').select('id, status, estimated_cost, created_at');
    final users = await _db.from('users').select('id');
    final swapStations = await _db
        .from('stations')
        .select('id')
        .eq('has_battery_swap', true);

    final stationList = stations as List;
    final chargerList = chargers as List;
    final bookingList = bookings as List;

    final today = DateTime.now();
    final todayBookings = bookingList.where((b) {
      final created = DateTime.tryParse(b['created_at'] ?? '');
      return created != null &&
          created.year == today.year &&
          created.month == today.month &&
          created.day == today.day;
    }).toList();

    final todayRevenue = todayBookings.fold<double>(
        0, (sum, b) => sum + ((b['estimated_cost'] as num?)?.toDouble() ?? 0));

    return {
      'total_stations': stationList.length,
      'total_chargers': chargerList.length,
      'available_chargers':
          chargerList.where((c) => c['status'] == 'available').length,
      'occupied_chargers':
          chargerList.where((c) => c['status'] == 'occupied').length,
      'active_bookings':
          bookingList.where((b) => b['status'] == 'charging').length,
      'today_revenue': todayRevenue,
      'battery_swap_points': (swapStations as List).length,
      'registered_users': (users as List).length,
    };
  }

  // ── Battery Swap ───────────────────────────────────────────────────────────

  static Future<List<dynamic>> getBatterySwapStations() async {
    final stations = await _db
        .from('stations')
        .select('id, name, city, address')
        .eq('has_battery_swap', true)
        .eq('is_approved', true);

    final result = <Map<String, dynamic>>[];
    for (final station in stations as List) {
      final batteries = await _db
          .from('batteries')
          .select()
          .eq('station_id', station['id'])
          .order('battery_code');
      result.add({...station, 'batteries': batteries});
    }
    return result;
  }

  static Future<Map<String, dynamic>> reserveBattery(String batteryId) async {
    final battery = await _db
        .from('batteries')
        .select('battery_code, battery_type')
        .eq('id', batteryId)
        .single();

    final code = battery['battery_code'] as String;
    final reservationCode =
        'SWAP-${code.replaceAll('-', '')}-'
        '${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    await _db
        .from('batteries')
        .update({'status': 'reserved'})
        .eq('id', batteryId);

    return {
      'battery_id': batteryId,
      'battery_code': code,
      'reservation_code': reservationCode,
      'status': 'reserved',
    };
  }

  // ── Admin Stations / Chargers ──────────────────────────────────────────────

  // Returns the first station owned by this operator, null if none registered yet.
  static Future<String?> getOperatorStationId(String ownerId) async {
    // Try owner_id first (schema v2), fall back to operator_id (original schema)
    var res = await _db
        .from('stations')
        .select('id')
        .eq('owner_id', ownerId)
        .order('created_at')
        .limit(1);
    var list = res as List;
    if (list.isNotEmpty) return list.first['id'] as String?;

    res = await _db
        .from('stations')
        .select('id')
        .eq('operator_id', ownerId)
        .order('created_at')
        .limit(1);
    list = res as List;
    if (list.isEmpty) return null;
    return list.first['id'] as String?;
  }

  static Future<List<dynamic>> getAllStationsAdmin() async {
    final res = await _db
        .from('stations')
        .select('*, chargers(id), users!stations_operator_id_fkey(full_name, email)')
        .order('created_at', ascending: false);
    return res as List<dynamic>;
  }

  static Future<void> approveStation(String stationId) async {
    await _db
        .from('stations')
        .update({'is_approved': true})
        .eq('id', stationId);
  }

  static Future<void> rejectStation(String stationId) async {
    await _db
        .from('stations')
        .update({'is_approved': false})
        .eq('id', stationId);
  }

  static Future<List<dynamic>> getAllChargersAdmin() async {
    final res = await _db
        .from('chargers')
        .select('*, stations(name)')
        .order('created_at', ascending: false);
    return res as List<dynamic>;
  }

  static Future<List<dynamic>> getUsers() async {
    final res = await _db
        .from('users')
        .select('id, full_name, email, phone, tier, role, status, created_at')
        .order('created_at', ascending: false);
    return res as List<dynamic>;
  }

  static Future<void> updateUserStatus(String userId, String status) async {
    await _db.from('users').update({'status': status}).eq('id', userId);
  }

  // ── User Profile ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final res = await _db
          .from('users')
          .select('id, full_name, email, phone, tier, role, status, created_at, profile_image_url, address, bio')
          .eq('id', userId)
          .single();
      return res;
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String phone,
    String? address,
    String? bio,
    String? profileImageUrl,
  }) async {
    final updates = <String, dynamic>{
      'full_name': name,
      'phone': phone,
    };
    if (address != null) updates['address'] = address;
    if (bio != null) updates['bio'] = bio;
    if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;
    await _db.from('users').update(updates).eq('id', userId);
  }

  // ── Vehicles ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getVehicles(String userId) async {
    final res = await _db
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .order('is_primary', ascending: false);
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> addVehicle({
    required String userId,
    required String modelName,
    String? plateNumber,
    required String connectorType,
    required double batteryCapacity,
    bool isPrimary = false,
  }) async {
    if (isPrimary) {
      await _db
          .from('vehicles')
          .update({'is_primary': false})
          .eq('user_id', userId);
    }
    final res = await _db.from('vehicles').insert({
      'user_id': userId,
      'model_name': modelName,
      'plate_number': plateNumber,
      'connector_type': connectorType,
      'battery_capacity': batteryCapacity,
      'is_primary': isPrimary,
    }).select().single();
    return res;
  }

  static Future<void> deleteVehicle(String vehicleId) async {
    await _db.from('vehicles').delete().eq('id', vehicleId);
  }

  // ── Reviews ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getReviews(String stationId) async {
    final res = await _db
        .from('reviews')
        .select('*, users(full_name)')
        .eq('station_id', stationId)
        .order('created_at', ascending: false);
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> submitReview({
    required String userId,
    required String stationId,
    required int rating,
    String? comment,
  }) async {
    final res = await _db.from('reviews').upsert({
      'user_id': userId,
      'station_id': stationId,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'user_id,station_id').select().single();
    return res;
  }

  // ── Membership ─────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getMembershipPlans({String? forRole}) async {
    var query = _db
        .from('membership_plans')
        .select()
        .eq('is_active', true);
    if (forRole != null) {
      final res = await query.eq('for_role', forRole).order('price_monthly');
      return res as List<dynamic>;
    }
    final res = await query.order('price_monthly');
    return res as List<dynamic>;
  }

  static Future<void> subscribeToPlan({
    required String userId,
    required String planId,
    required String billing,
  }) async {
    await _db.from('user_memberships').upsert({
      'user_id': userId,
      'plan_id': planId,
      'billing': billing,
      'status': 'active',
    }, onConflict: 'user_id,plan_id');
  }

  static Future<Map<String, dynamic>?> getCurrentMembership(String userId) async {
    try {
      final res = await _db
          .from('user_memberships')
          .select('*, membership_plans(*)')
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  static Future<List<dynamic>> getNotifications(String userId) async {
    final res = await _db
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return res as List<dynamic>;
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await _db
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // ── Station Registration ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> registerStation({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    required String openingTime,
    required String closingTime,
    String? contactNumber,
    String? description,
    List<String> amenities = const [],
    String? ownerId,
  }) async {
    final res = await _db.from('stations').insert({
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'contact_number': contactNumber,
      'description': description,
      'amenities': amenities,
      'is_approved': false,
      'operator_id': ownerId,
      'owner_id': ownerId,
    }).select().single();
    return res;
  }

  static Future<List<dynamic>> getStationsByOwner(String ownerId) async {
    final res = await _db
        .from('stations')
        .select('*, chargers(id, status)')
        .eq('operator_id', ownerId)
        .order('created_at', ascending: false);
    return res as List<dynamic>;
  }

  static Future<void> updateStation({
    required String id,
    String? name,
    String? address,
    String? openingTime,
    String? closingTime,
    String? contactNumber,
    String? description,
    List<String>? amenities,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (address != null) updates['address'] = address;
    if (openingTime != null) updates['opening_time'] = openingTime;
    if (closingTime != null) updates['closing_time'] = closingTime;
    if (contactNumber != null) updates['contact_number'] = contactNumber;
    if (description != null) updates['description'] = description;
    if (amenities != null) updates['amenities'] = amenities;
    if (updates.isEmpty) return;
    await _db.from('stations').update(updates).eq('id', id);
  }

  static Future<void> rejectStationWithReason(String stationId, String reason) async {
    await _db.from('stations').update({
      'is_approved': false,
      'rejection_reason': reason,
    }).eq('id', stationId);
  }

  // ── Charger management ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> addCharger({
    required String stationId,
    required String name,
    required String chargerType,
    required String connectorType,
    required double powerKw,
    required double pricePerKwh,
  }) async {
    final res = await _db.from('chargers').insert({
      'station_id': stationId,
      'name': name,
      'charger_type': chargerType,
      'connector_type': connectorType,
      'power_kw': powerKw,
      'price_per_kwh': pricePerKwh,
      'status': 'available',
    }).select().single();
    return res;
  }

  static Future<void> deleteCharger(String chargerId) async {
    await _db.from('chargers').delete().eq('id', chargerId);
  }

  // ── Booking by QR token ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getBookingByQrToken(String token) async {
    try {
      final res = await _db
          .from('bookings')
          .select('*, users(full_name, phone), stations(name), chargers(name, power_kw)')
          .eq('qr_token', token)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  // ── Charging progress ──────────────────────────────────────────────────────

  static Future<void> updateBookingStartTime(String bookingId) async {
    await _db.from('bookings').update({
      'status': 'charging',
      'start_time': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', bookingId);
  }

  // ── Battery swap completion ────────────────────────────────────────────────

  static Future<void> completeSwap({
    required String batteryId,
    required String userId,
    required String stationId,
    required String action,
    String? qrToken,
  }) async {
    await _db.from('swap_transactions').insert({
      'user_id': userId,
      'battery_id': batteryId,
      'station_id': stationId,
      'action': action,
      'qr_token': qrToken,
    });

    final newStatus = action == 'picked' ? 'in_use' : 'available';
    await _db
        .from('batteries')
        .update({'status': newStatus})
        .eq('id', batteryId);
  }
}
