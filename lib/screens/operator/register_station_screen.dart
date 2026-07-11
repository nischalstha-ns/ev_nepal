import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';

class RegisterStationScreen extends StatefulWidget {
  const RegisterStationScreen({super.key});

  @override
  State<RegisterStationScreen> createState() => _RegisterStationScreenState();
}

class _RegisterStationScreenState extends State<RegisterStationScreen> {
  int _step = 0;
  bool _submitting = false;

  // Step 1: Basic Info
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Step 2: Location
  final _latCtrl = TextEditingController(text: '27.7172');
  final _lngCtrl = TextEditingController(text: '85.3240');
  final MapController _mapController = MapController();

  // Step 3: Hours & Contact
  String _openingTime = '06:00';
  String _closingTime = '22:00';
  final _contactCtrl = TextEditingController();

  // Step 4: Amenities
  final Map<String, bool> _amenities = {
    'WiFi': false,
    'Restroom': false,
    'Parking': false,
    'CCTV': false,
    'Café': false,
  };

  // Step 5: Chargers
  final List<Map<String, dynamic>> _chargers = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isOpening) async {
    final parts = (isOpening ? _openingTime : _closingTime).split(':');
    final initial = TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final str =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isOpening) {
          _openingTime = str;
        } else {
          _closingTime = str;
        }
      });
    }
  }

  void _addCharger() {
    setState(() {
      _chargers.add({
        'name': 'Charger ${_chargers.length + 1}',
        'charger_type': 'AC',
        'connector_type': 'Type2',
        'power_kw': 7.4,
        'price_per_kwh': 15.0,
      });
    });
  }

  bool _canProceed() {
    switch (_step) {
      case 0:
        return _nameCtrl.text.trim().isNotEmpty &&
            _addressCtrl.text.trim().isNotEmpty &&
            _cityCtrl.text.trim().isNotEmpty;
      case 1:
        return double.tryParse(_latCtrl.text) != null &&
            double.tryParse(_lngCtrl.text) != null;
      case 2:
        return _contactCtrl.text.trim().isNotEmpty;
      case 3:
        return true;
      case 4:
        return _chargers.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final station = await ApiService.registerStation(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        latitude: double.parse(_latCtrl.text),
        longitude: double.parse(_lngCtrl.text),
        openingTime: _openingTime,
        closingTime: _closingTime,
        contactNumber: _contactCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        amenities: _amenities.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        ownerId: AuthService.currentUserId,
      );

      for (final c in _chargers) {
        await ApiService.addCharger(
          stationId: station['id'] as String,
          name: c['name'] as String,
          chargerType: c['charger_type'] as String,
          connectorType: c['connector_type'] as String,
          powerKw: (c['power_kw'] as num).toDouble(),
          pricePerKwh: (c['price_per_kwh'] as num).toDouble(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Station submitted for approval!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Basic Info',
      'Location',
      'Hours & Contact',
      'Amenities',
      'Chargers',
      'Review',
    ];

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Register Station',
        showBackButton: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / steps.length,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceContainerHigh,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Step ${_step + 1} of ${steps.length}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  '— ${steps[_step]}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: [
                _buildStep0(),
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
              ][_step],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _canProceed()
                        ? (_step < steps.length - 1
                            ? () => setState(() => _step++)
                            : _submitting
                                ? null
                                : _submit)
                        : null,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_step < steps.length - 1 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep0() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Station Name *'),
          _field(_nameCtrl, 'e.g. Kathmandu EV Hub', Icons.business),
          const SizedBox(height: 14),
          _FieldLabel('Address *'),
          _field(_addressCtrl, 'Street / Tole', Icons.location_on_outlined),
          const SizedBox(height: 14),
          _FieldLabel('City *'),
          _field(_cityCtrl, 'e.g. Kathmandu', Icons.location_city),
          const SizedBox(height: 14),
          _FieldLabel('Description'),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: _inputDecoration(
                'Brief description of the station...', Icons.notes),
          ),
        ],
      );

  Widget _buildStep1() {
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    final point = (lat != null && lng != null)
        ? LatLng(lat, lng)
        : const LatLng(27.7172, 85.3240);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set your station\'s GPS coordinates. You can enter them manually or tap "Use Nepal Center" to start.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _FieldLabel('Latitude *'),
              _field(_latCtrl, '27.7172', Icons.gps_fixed, number: true,
                  onChanged: (_) => setState(() {})),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _FieldLabel('Longitude *'),
              _field(_lngCtrl, '85.3240', Icons.gps_not_fixed, number: true,
                  onChanged: (_) => setState(() {})),
            ])),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: point, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.evnepal.app',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: point,
                    child: const Icon(Icons.location_pin,
                        color: AppColors.danger, size: 36),
                  ),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _latCtrl.text = '27.7172';
              _lngCtrl.text = '85.3240';
            });
            _mapController.move(const LatLng(27.7172, 85.3240), 13);
          },
          icon: const Icon(Icons.my_location, size: 16),
          label: const Text('Use Nepal Center'),
        ),
      ],
    );
  }

  Widget _buildStep2() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Opening Time'),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(_openingTime,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                    onPressed: () => _pickTime(true),
                    child: const Text('Change')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel('Closing Time'),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled,
                    size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(_closingTime,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                    onPressed: () => _pickTime(false),
                    child: const Text('Change')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel('Contact Number *'),
          _field(_contactCtrl, '+977 01-XXXXXXX', Icons.phone_outlined),
        ],
      );

  Widget _buildStep3() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select available amenities at your station:',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          ..._amenities.entries.map((e) => CheckboxListTile(
                title: Text(e.key),
                value: e.value,
                onChanged: (v) =>
                    setState(() => _amenities[e.key] = v ?? false),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              )),
        ],
      );

  Widget _buildStep4() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_chargers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Add at least one charger to proceed.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          ..._chargers.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurfaceCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Charger ${i + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger),
                          onPressed: () =>
                              setState(() => _chargers.removeAt(i)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: c['charger_type'] as String?,
                            decoration:
                                const InputDecoration(labelText: 'Type'),
                            items: ['AC', 'DC']
                                .map((t) => DropdownMenuItem(
                                    value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => c['charger_type'] = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: c['connector_type'] as String?,
                            decoration: const InputDecoration(
                                labelText: 'Connector'),
                            items: [
                              'Type2',
                              'CCS',
                              'CHAdeMO',
                              'GB/T',
                              'CCS2'
                            ]
                                .map((t) => DropdownMenuItem(
                                    value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => c['connector_type'] = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('pw_$i'),
                            initialValue: c['power_kw'].toString(),
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'kW'),
                            onChanged: (v) => c['power_kw'] =
                                double.tryParse(v) ?? c['power_kw'],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('price_$i'),
                            initialValue: c['price_per_kwh'].toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'NPR/kWh'),
                            onChanged: (v) => c['price_per_kwh'] =
                                double.tryParse(v) ?? c['price_per_kwh'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addCharger,
            icon: const Icon(Icons.add),
            label: const Text('Add Charger'),
          ),
        ],
      );

  Widget _buildStep5() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review your station details before submitting.',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewRow('Name', _nameCtrl.text),
                _ReviewRow('Address', '${_addressCtrl.text}, ${_cityCtrl.text}'),
                _ReviewRow('Location',
                    '${_latCtrl.text}, ${_lngCtrl.text}'),
                _ReviewRow('Hours', '$_openingTime – $_closingTime'),
                _ReviewRow('Contact', _contactCtrl.text),
                _ReviewRow(
                    'Amenities',
                    _amenities.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .join(', ')
                        .ifEmpty('None')),
                _ReviewRow('Chargers', '${_chargers.length} charger(s)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SurfaceCard(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: AppColors.secondaryBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your station will be reviewed by an admin before going live.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool number = false,
    void Function(String)? onChanged,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        decoration: _inputDecoration(hint, icon),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.outline),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface)),
      );
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 84,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      );
}

extension _StringX on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
