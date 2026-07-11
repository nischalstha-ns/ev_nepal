import 'package:flutter/material.dart';
import '../../models/station_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/nepal_cities.dart';

class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> {
  bool _showResults = false;
  bool _calculating = false;
  bool _inputChanged = false;

  final _originCtrl = TextEditingController(text: 'Kathmandu');
  final _destCtrl = TextEditingController(text: 'Pokhara');

  List<Station> _stations = [];
  List<Station> _recommendedStations = [];

  NepalCity? _originCity;
  NepalCity? _destCity;
  NepalCity? _lastCalculatedOrigin;
  NepalCity? _lastCalculatedDest;

  // Preview data (shown before calculation)
  double _previewDistance = 0.0;
  String _previewTime = '';
  double _previewCost = 0.0;

  // Result data (shown after calculation)
  int _chargingStops = 2;
  String _estArrivalTime = '4h 15m';
  int _arrivalBattery = 15;
  double _costEstimate = 850;
  int _reliabilityScore = 98;
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStations();
    _originCity = NepalCities.findCity('Kathmandu');
    _destCity = NepalCities.findCity('Pokhara');
    _calculatePreview();
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    try {
      final raw = await ApiService.getStations();
      if (mounted) {
        setState(() {
          _stations = raw.map((j) => Station.fromJson(j as Map<String, dynamic>)).toList();
        });
      }
    } catch (_) {}
  }

  void _calculatePreview() {
    if (_originCity == null || _destCity == null) {
      setState(() {
        _previewDistance = 0.0;
        _previewTime = '';
        _previewCost = 0.0;
      });
      return;
    }

    if (_originCity!.name == _destCity!.name) {
      setState(() {
        _previewDistance = 0.0;
        _previewTime = '';
        _previewCost = 0.0;
      });
      return;
    }

    // Calculate preview
    final distance = NepalCities.calculateDistance(_originCity!, _destCity!);
    final avgSpeed = _isHillyRoute() ? 50.0 : 60.0;
    final hours = (distance / avgSpeed).floor();
    final minutes = (((distance / avgSpeed) - hours) * 60).round();
    final cost = distance * 0.18 * 20;

    setState(() {
      _previewDistance = distance;
      _previewTime = '${hours}h ${minutes}m';
      _previewCost = cost;

      // Check if input changed from last calculation
      if (_showResults) {
        _inputChanged = _lastCalculatedOrigin?.name != _originCity?.name ||
                       _lastCalculatedDest?.name != _destCity?.name;
      }
    });
  }

  Future<void> _calculateRoute() async {
    final originText = _originCtrl.text.trim();
    final destText = _destCtrl.text.trim();

    if (originText.isEmpty || destText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both origin and destination')),
      );
      return;
    }

    // Find cities
    final originCity = NepalCities.findCity(originText);
    final destCity = NepalCities.findCity(destText);

    if (originCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Origin "$originText" not found. Please select from suggestions.')),
      );
      return;
    }

    if (destCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Destination "$destText" not found. Please select from suggestions.')),
      );
      return;
    }

    if (originCity.name == destCity.name) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Origin and destination cannot be the same')),
      );
      return;
    }

    setState(() {
      _calculating = true;
      _originCity = originCity;
      _destCity = destCity;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    // Calculate route based on real distance
    _calculateRouteDetails();

    if (mounted) {
      setState(() {
        _showResults = true;
        _calculating = false;
        _inputChanged = false;
        _lastCalculatedOrigin = originCity;
        _lastCalculatedDest = destCity;
      });
    }
  }

  void _calculateRouteDetails() {
    if (_originCity == null || _destCity == null) return;

    // Calculate real distance using Haversine formula
    _distance = NepalCities.calculateDistance(_originCity!, _destCity!);

    // Determine number of charging stops based on distance
    if (_distance < 120) {
      _chargingStops = 0;
    } else if (_distance < 240) {
      _chargingStops = 1;
    } else if (_distance < 360) {
      _chargingStops = 2;
    } else {
      _chargingStops = 3;
    }

    // Find recommended charging stations
    _recommendedStations = _stations.take(_chargingStops).toList();

    // Calculate arrival time
    final avgSpeed = _isHillyRoute() ? 50.0 : 60.0;
    final drivingHours = _distance / avgSpeed;
    final chargingHours = _chargingStops * 0.33;
    final totalHours = drivingHours + chargingHours;
    final hours = totalHours.floor();
    final minutes = ((totalHours - hours) * 60).round();
    _estArrivalTime = '${hours}h ${minutes}m';

    // Calculate cost
    final kwhNeeded = _distance * 0.18;
    _costEstimate = (kwhNeeded * 20).roundToDouble();

    // Calculate arrival battery
    final consumed = _distance * 0.15;
    final charged = _chargingStops * 85;
    _arrivalBattery = (100 - consumed + charged).clamp(10, 100).round();

    // Reliability score
    final avgChargers = _recommendedStations.isEmpty
        ? 0.0
        : _recommendedStations.map((s) => s.totalChargers).reduce((a, b) => a + b) / _recommendedStations.length;

    final routeComplexity = _isHillyRoute() ? -5 : 0;
    final stationQuality = (avgChargers * 1.5).round();

    _reliabilityScore = (85 + stationQuality + routeComplexity + (_chargingStops > 0 ? 5 : 0))
        .clamp(70, 100)
        .round();
  }

  bool _isHillyRoute() {
    if (_originCity == null || _destCity == null) return false;

    final hillyProvinces = ['Gandaki', 'Bagmati', 'Karnali'];
    return hillyProvinces.contains(_originCity!.province) ||
           hillyProvinces.contains(_destCity!.province);
  }

  void _startNavigation() {
    if (_originCity == null || _destCity == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚗 Navigation started from ${_originCity!.name} to ${_destCity!.name}!',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetRoute() {
    setState(() {
      _showResults = false;
      _inputChanged = false;
      _destCtrl.clear();
      _destCity = null;
      _lastCalculatedOrigin = null;
      _lastCalculatedDest = null;
      _calculatePreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'AI Route Planner',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Smart recommendation based on real-time grid data.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Current Location with Autocomplete
                    _buildAutocompleteField(
                      label: 'CURRENT LOCATION',
                      controller: _originCtrl,
                      icon: Icons.my_location,
                      iconColor: AppColors.primary,
                      onSelected: (city) {
                        setState(() {
                          _originCity = city;
                          _originCtrl.text = city.name;
                          _calculatePreview();
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Destination with Autocomplete
                    _buildAutocompleteField(
                      label: 'DESTINATION',
                      controller: _destCtrl,
                      icon: Icons.place,
                      iconColor: AppColors.danger,
                      onSelected: (city) {
                        setState(() {
                          _destCity = city;
                          _destCtrl.text = city.name;
                          _calculatePreview();
                        });
                      },
                    ),

                    // Preview Card (before calculation)
                    if (_previewDistance > 0 && !_showResults)
                      _buildPreviewCard(),

                    const SizedBox(height: 32),

                    // Calculate/Update Button or Results
                    if (!_showResults)
                      _buildCalculateButton()
                    else if (_inputChanged)
                      _buildUpdateButton()
                    else
                      _buildResultsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user/profile'),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 20),
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Text(
                'Route Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildPreviewItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${_previewDistance.toStringAsFixed(1)} km',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPreviewItem(
                  icon: Icons.access_time,
                  label: 'Est. Time',
                  value: _previewTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewItem(
            icon: Icons.currency_rupee,
            label: 'Est. Cost',
            value: 'NPR ${_previewCost.toStringAsFixed(0)}',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem({
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required Function(NepalCity) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Autocomplete<NepalCity>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<NepalCity>.empty();
            }
            return NepalCities.searchCities(textEditingValue.text);
          },
          displayStringForOption: (city) => city.name,
          onSelected: onSelected,
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            textController.text = controller.text;
            textController.selection = controller.selection;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                onChanged: (value) {
                  controller.text = value;
                },
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: iconColor, size: 22),
                  suffixIcon: Icon(Icons.search, color: const Color(0xFF9CA3AF), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintText: 'Search city...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final city = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(city),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.location_city, size: 20, color: iconColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      city.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Text(
                                      city.province,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _calculating ? null : _calculateRoute,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        ),
        child: _calculating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Calculate Optimized Route',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Column(
      children: [
        // Update notice banner
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Route details changed. Recalculate to see updated results.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Preview with new data
        if (_previewDistance > 0) _buildPreviewCard(),
        const SizedBox(height: 16),

        // Update button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _calculating ? null : _calculateRoute,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: _calculating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, size: 22),
            label: Text(
              _calculating ? 'Updating...' : 'Update Route',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Old results still shown below
        _buildResultsCard(),
      ],
    );
  }

  Widget _buildResultsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Optimized Route Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _resetRoute,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          // Route Info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.route, size: 18, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_originCity?.name} → ${_destCity?.name} • ${_distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'CHARGING STOPS',
                        value: _chargingStops == 0 ? 'None' : '$_chargingStops',
                        icon: Icons.ev_station,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        label: 'EST. ARRIVAL TIME',
                        value: _estArrivalTime,
                        icon: Icons.access_time,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'ARRIVAL BATTERY',
                        value: '$_arrivalBattery%',
                        icon: Icons.battery_charging_full,
                        trend: _arrivalBattery >= 20 ? TrendDirection.up : TrendDirection.down,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        label: 'COST ESTIMATE',
                        value: 'NPR ${_costEstimate.toStringAsFixed(0)}',
                        icon: Icons.currency_rupee,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recommendation Text
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _chargingStops == 0
                        ? 'Direct route recommended! Your EV has sufficient range to reach destination without charging stops.'
                        : _recommendedStations.isEmpty
                            ? 'Recommended stops based on battery health, elevation changes, and real-time charger availability.'
                            : 'Recommended charging stops: ${_recommendedStations.map((s) => s.name).join(', ')}. Route optimized for battery health and elevation changes.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reliability Score
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Icon(Icons.verified_user, size: 18, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                const Text(
                  'RELIABILITY SCORE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _reliabilityScore >= 90
                        ? AppColors.success
                        : _reliabilityScore >= 75
                            ? AppColors.warning
                            : AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_reliabilityScore/100',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Start Navigation Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _startNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.navigation, size: 20),
                label: const Text(
                  'Start Navigation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    TrendDirection? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 6),
                Icon(
                  trend == TrendDirection.up ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: trend == TrendDirection.up ? AppColors.success : AppColors.danger,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

enum TrendDirection { up, down }
