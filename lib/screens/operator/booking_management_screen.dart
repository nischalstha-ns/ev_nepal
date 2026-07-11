import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';

class BookingManagementScreen extends StatelessWidget {
  final String stationId;
  const BookingManagementScreen({super.key, required this.stationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Booking Management', showBackButton: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/operator/qr-scan'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: RealtimeService.watchBookingsByStation(stationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data ?? [];
          final active = bookings
              .where((b) =>
                  ['confirmed', 'charging'].contains(b['status']))
              .toList();

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: RealtimeService.watchBatteries(stationId),
            builder: (context, batSnap) {
              final batteries = batSnap.data ?? [];
              final reserved = batteries
                  .where((b) => b['status'] == 'reserved')
                  .toList();

              if (active.isEmpty && reserved.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_online,
                          size: 56, color: AppColors.lightText),
                      SizedBox(height: 12),
                      Text('No active bookings or swaps'),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (active.isNotEmpty) ...[
                    const Text('Active Bookings',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 10),
                    ...active.map((b) => _BookingCard(booking: b)),
                  ],
                  if (reserved.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Battery Swaps',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 10),
                    ...reserved.map((b) => _SwapCard(battery: b)),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      await ApiService.startCharging(widget.booking['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Charging started!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _complete() async {
    setState(() => _loading = true);
    try {
      await ApiService.completeCharging(widget.booking['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Charging completed!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed': return AppColors.secondaryBlue;
      case 'charging': return AppColors.success;
      case 'completed': return AppColors.lightText;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final status = b['status'] ?? 'confirmed';
    final shortId = (b['id'] as String).substring(0, 8).toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Booking #$shortId', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.lightText),
                const SizedBox(width: 4),
                Text('Target: ${b['target_percent']}%', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 16),
                const Icon(Icons.currency_rupee, size: 14, color: AppColors.lightText),
                Text('Rs. ${(b['estimated_cost'] ?? 0).toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: SizedBox(height: 32, width: 32, child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Row(
                children: [
                  if (status == 'confirmed')
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Start Charging'),
                        onPressed: _start,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      ),
                    ),
                  if (status == 'charging') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.stop_circle, size: 18),
                        label: const Text('Complete'),
                        onPressed: _complete,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SwapCard extends StatefulWidget {
  final Map<String, dynamic> battery;
  const _SwapCard({required this.battery});

  @override
  State<_SwapCard> createState() => _SwapCardState();
}

class _SwapCardState extends State<_SwapCard> {
  bool _loading = false;

  Future<void> _complete(String action) async {
    setState(() => _loading = true);
    try {
      await ApiService.completeSwap(
        batteryId: widget.battery['id'] as String,
        userId: widget.battery['reserved_by'] as String? ?? AuthService.currentUserId ?? '',
        stationId: widget.battery['station_id'] as String? ?? '',
        action: action,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(action == 'picked' ? 'Swap completed!' : 'Battery returned!'),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.battery;
    final rawId = (b['battery_code'] as String? ?? b['id'] as String? ?? '--------');
    final code = rawId.length >= 8 ? rawId.substring(0, 8).toUpperCase() : rawId.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.battery_charging_full,
                    color: AppColors.secondaryBlue, size: 20),
                const SizedBox(width: 8),
                Text('Battery #$code',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Reserved',
                      style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Capacity: ${b['capacity_kwh'] ?? b['capacity'] ?? '—'} kWh',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                  child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Complete Swap'),
                      onPressed: () => _complete('picked'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.keyboard_return, size: 16),
                      label: const Text('Mark Returned'),
                      onPressed: () => _complete('dropped'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
