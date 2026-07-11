import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/station_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Station> _stations = [];
  bool _loading = true;
  LatLng? _userLocation;
  bool _locationLoading = false;
  StreamSubscription<Position>? _locationSubscription;
  String _locationError = '';

  static const _nepalCenter = LatLng(27.7172, 85.3240);

  @override
  void initState() {
    super.initState();
    _loadStations();
    _getUserLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadStations() async {
    try {
      final data = await ApiService.getStations();
      if (mounted) {
        setState(() {
          _stations = data
              .map((j) => Station.fromJson(j as Map<String, dynamic>))
              .where((s) => s.latitude != null && s.longitude != null)
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationError = 'Location services disabled';
            _locationLoading = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _locationError = 'Location permission denied';
              _locationLoading = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationError = 'Location permission permanently denied';
            _locationLoading = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _locationLoading = false;
        });
        _mapController.move(_userLocation!, 14.0);
      }

      _startLocationTracking();
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Could not get location';
          _locationLoading = false;
        });
      }
    }
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 14.0);
    } else {
      _getUserLocation();
    }
  }

  double _calculateDistance(LatLng from, LatLng to) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, from, to);
  }

  void _showStationSheet(Station station) {
    String distanceText = '';
    if (_userLocation != null && station.latitude != null && station.longitude != null) {
      final dist = _calculateDistance(
        _userLocation!,
        LatLng(station.latitude!, station.longitude!),
      );
      distanceText = '${dist.toStringAsFixed(1)} km away';
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.ev_station, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(station.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(station.city,
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: station.availableChargers > 0
                        ? const Color(0xFFDCFCE7)
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${station.availableChargers} free',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: station.availableChargers > 0
                          ? AppColors.success
                          : AppColors.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (distanceText.isNotEmpty) ...[
                  const Icon(Icons.directions_walk, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    distanceText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                const Icon(Icons.access_time_outlined,
                    size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  station.openingTime != null && station.closingTime != null
                      ? '${station.openingTime} – ${station.closingTime}'
                      : 'Open 24 hrs',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  station.rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            if (station.hasBatterySwap) ...[
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.battery_charging_full, size: 14, color: Color(0xFF6D28D9)),
                  SizedBox(width: 4),
                  Text('Battery Swap Available',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6D28D9))),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    '/user/station',
                    arguments: {'station': station},
                  );
                },
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('View Details & Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? _nepalCenter,
              initialZoom: _userLocation != null ? 14.0 : 7.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.evnepal.app',
              ),
              // Station markers
              MarkerLayer(
                markers: [
                  // User location marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Station markers
                  ..._stations.map((station) {
                    final isAvailable = station.availableChargers > 0;
                    return Marker(
                      point: LatLng(station.latitude!, station.longitude!),
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => _showStationSheet(station),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.ev_station,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/user/profile'),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Station Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          '${_stations.length} stations nearby',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_userLocation != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gps_fixed, size: 12, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _loading = true);
                      _loadStations();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_loading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
              right: 0,
              child: const Center(
                child: SurfaceCard(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Loading stations...', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

          // Location error banner
          if (_locationError.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_off, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationError,
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                      ),
                    ),
                    GestureDetector(
                      onTap: _getUserLocation,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right side controls
          Positioned(
            bottom: 120,
            right: 16,
            child: Column(
              children: [
                // My Location button
                FloatingActionButton.small(
                  heroTag: 'map_my_location',
                  backgroundColor: _userLocation != null ? Colors.blue : Colors.white,
                  onPressed: _centerOnUser,
                  child: _locationLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          Icons.my_location,
                          color: _userLocation != null ? Colors.white : Colors.grey,
                        ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'map_zoom_in',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                  child: const Icon(Icons.add, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'map_zoom_out',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                  child: const Icon(Icons.remove, color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
          ),

          // Bottom info card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildInfoChip(
                    Icons.ev_station,
                    '${_stations.length}',
                    'Stations',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.check_circle,
                    '${_stations.where((s) => s.availableChargers > 0).length}',
                    'Available',
                    AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.cancel,
                    '${_stations.where((s) => s.availableChargers == 0).length}',
                    'Occupied',
                    AppColors.outlineVariant,
                  ),
                  const Spacer(),
                  // Legend
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendDot(color: AppColors.primary, label: 'Available'),
                      const SizedBox(height: 4),
                      _LegendDot(color: AppColors.outlineVariant, label: 'Occupied'),
                      if (_userLocation != null) ...[
                        const SizedBox(height: 4),
                        _LegendDot(color: Colors.blue, label: 'You'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
