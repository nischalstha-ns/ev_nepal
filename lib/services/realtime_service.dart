import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  static final _client = Supabase.instance.client;

  static Stream<List<Map<String, dynamic>>> watchChargers() {
    return _client
        .from('chargers')
        .stream(primaryKey: ['id'])
        .order('created_at');
  }

  static Stream<List<Map<String, dynamic>>> watchChargersByStation(String stationId) {
    return _client
        .from('chargers')
        .stream(primaryKey: ['id'])
        .eq('station_id', stationId)
        .order('created_at');
  }

  static Stream<List<Map<String, dynamic>>> watchBookings() {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  static Stream<List<Map<String, dynamic>>> watchBookingsByStation(String stationId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('station_id', stationId)
        .order('created_at', ascending: false);
  }

  static Stream<List<Map<String, dynamic>>> watchQueues(String chargerId) {
    return _client
        .from('queues')
        .stream(primaryKey: ['id'])
        .eq('charger_id', chargerId)
        .order('position');
  }

  static Stream<List<Map<String, dynamic>>> watchBatteries(String stationId) {
    return _client
        .from('batteries')
        .stream(primaryKey: ['id'])
        .eq('station_id', stationId);
  }

  static Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  static Stream<List<Map<String, dynamic>>> watchStationsByOwner(String ownerId) {
    return _client
        .from('stations')
        .stream(primaryKey: ['id'])
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);
  }

  static Stream<List<Map<String, dynamic>>> watchUserBookings(String userId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
