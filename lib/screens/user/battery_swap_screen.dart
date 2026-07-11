import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';

class BatterySwapScreen extends StatefulWidget {
  const BatterySwapScreen({super.key});

  @override
  State<BatterySwapScreen> createState() => _BatterySwapScreenState();
}

class _BatterySwapScreenState extends State<BatterySwapScreen> {
  List<dynamic> _stations = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getBatterySwapStations();
      setState(() { _stations = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _reserve(String batteryId, String batteryCode) async {
    try {
      final res = await ApiService.reserveBattery(batteryId);
      if (!mounted) return;
      _showReservationDialog(res, batteryCode);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showReservationDialog(Map<String, dynamic> res, String batteryCode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Battery Reserved!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: res['reservation_code'] ?? batteryCode, size: 160),
            const SizedBox(height: 12),
            Text(res['reservation_code'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(height: 8),
            Text('Battery: ${res['battery_code']}', style: const TextStyle(color: AppColors.lightText)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _load(); },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Battery Swap', showBackButton: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stations.isEmpty
              ? const Center(child: Text('No battery swap stations available'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondaryBlue, AppColors.primaryGreen],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.battery_charging_full, color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text('Battery Swap Demo', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Reserve a charged battery instantly', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      ..._stations.map((station) => _StationBatteryCard(
                        station: station,
                        onReserve: _reserve,
                      )),
                    ],
                  ),
                ),
    );
  }
}

class _StationBatteryCard extends StatelessWidget {
  final Map<String, dynamic> station;
  final Function(String, String) onReserve;

  const _StationBatteryCard({required this.station, required this.onReserve});

  @override
  Widget build(BuildContext context) {
    final batteries = (station['batteries'] as List?) ?? [];
    final available = batteries.where((b) => b['status'] == 'available').toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(station['name'] ?? '', style: Theme.of(context).textTheme.titleLarge),
            Text(station['city'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(icon: Icons.battery_full, label: '${available.length} Available', color: AppColors.success),
                const SizedBox(width: 8),
                _StatChip(icon: Icons.currency_rupee, label: 'Swap Fee: Rs. 150', color: AppColors.primaryGreen),
              ],
            ),
            if (available.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Available Batteries', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...available.map((b) => _BatteryTile(battery: b, onReserve: onReserve)),
            ] else ...[
              const SizedBox(height: 12),
              const Text('No batteries currently available', style: TextStyle(color: AppColors.lightText)),
            ],
          ],
        ),
      ),
    );
  }
}

class _BatteryTile extends StatelessWidget {
  final Map<String, dynamic> battery;
  final Function(String, String) onReserve;

  const _BatteryTile({required this.battery, required this.onReserve});

  @override
  Widget build(BuildContext context) {
    final health = battery['health_percent'] ?? 95;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.battery_charging_full, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(battery['battery_code'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${battery['battery_type']} • ${battery['capacity']} • Health: $health%',
                    style: const TextStyle(fontSize: 12, color: AppColors.lightText)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onReserve(battery['id'], battery['battery_code']),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            child: const Text('Reserve', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
