import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/branded_app_bar.dart';

class QRScreen extends StatefulWidget {
  final Booking booking;
  const QRScreen({super.key, required this.booking});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  bool _charging = false;
  bool _completed = false;
  double _progress = 0.0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Simulate charging: target percent reached in ~60s for demo
  int get _targetPercent => widget.booking.targetPercent;
  double get _estimatedCost => widget.booking.estimatedCost;

  @override
  void initState() {
    super.initState();
    if (widget.booking.status == 'charging') _startCharging();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCharging() {
    setState(() { _charging = true; _progress = 0.0; _elapsedSeconds = 0; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _elapsedSeconds++;
        // Simulate: full charge in 60 seconds for demo
        _progress = (_elapsedSeconds / 60.0).clamp(0.0, 1.0);
        if (_progress >= 1.0) {
          t.cancel();
          _charging = false;
          _completed = true;
          _completeCharging();
        }
      });
    });
  }

  Future<void> _completeCharging() async {
    try {
      await ApiService.completeCharging(widget.booking.id);
    } catch (_) {}
  }

  Future<void> _onStartCharging() async {
    try {
      await ApiService.startCharging(widget.booking.id);
    } catch (_) {}
    _startCharging();
  }

  String get _elapsedFormatted {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _currentPercent =>
      '${(_progress * _targetPercent).round()}%';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: BrandedAppBar(
        title: _completed ? 'Charging Complete' : _charging ? 'Charging...' : 'Booking Confirmed',
        showBackButton: !_charging,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _completed ? _buildCompleted(tt) : _charging ? _buildCharging(tt) : _buildConfirmed(tt),
      ),
    );
  }

  // ── Confirmed (show QR) ────────────────────────────────────────────────────

  Widget _buildConfirmed(TextTheme tt) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
        ),
        const SizedBox(height: 12),
        Text('Booking Confirmed!', style: tt.headlineMedium),
        const SizedBox(height: 4),
        Text('Show this QR code at the charging station', style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 24),

        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              QrImageView(
                data: widget.booking.qrToken ?? widget.booking.id,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.booking.qrToken ?? widget.booking.id,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _InfoRow('Booking ID', widget.booking.id.substring(0, 8).toUpperCase()),
              _InfoRow('Charge Target', '$_targetPercent%'),
              _InfoRow('Estimated Cost', 'NPR ${_estimatedCost.toStringAsFixed(0)}'),
              _InfoRow('Payment', 'Paid ✓', valueColor: AppColors.success),
              _InfoRow('Status', 'Confirmed', valueColor: AppColors.warning),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _onStartCharging,
            icon: const Icon(Icons.bolt),
            label: const Text('Start Charging', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/user', (_) => false),
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }

  // ── Charging in progress ───────────────────────────────────────────────────

  Widget _buildCharging(TextTheme tt) {
    final currentKwh = (_progress * _targetPercent / 100 * 30.0);
    final currentCost = currentKwh * (widget.booking.estimatedCost / (_targetPercent / 100 * 30.0));

    return Column(
      children: [
        const SizedBox(height: 16),

        // Animated charging icon
        _ChargingAnimation(progress: _progress),

        const SizedBox(height: 24),

        Text('Charging in Progress', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Do not unplug your vehicle', style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),

        const SizedBox(height: 28),

        // Progress ring + percent
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.surfaceContainerLow,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPercent,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      Text('of $_targetPercent%', style: tt.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatTile(icon: Icons.timer_outlined, label: 'Elapsed', value: _elapsedFormatted),
                  Container(width: 1, height: 36, color: AppColors.outlineVariant),
                  _StatTile(icon: Icons.bolt, label: 'Energy', value: '${currentKwh.toStringAsFixed(1)} kWh'),
                  Container(width: 1, height: 36, color: AppColors.outlineVariant),
                  _StatTile(icon: Icons.currency_rupee, label: 'Cost', value: 'NPR ${currentCost.toStringAsFixed(0)}'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Charging will stop automatically when target is reached.',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Completed ──────────────────────────────────────────────────────────────

  Widget _buildCompleted(TextTheme tt) {
    final totalKwh = (_targetPercent / 100 * 30.0);

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
        ),
        const SizedBox(height: 16),
        Text('Charging Complete!', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Your vehicle is fully charged', style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 28),

        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatTile(icon: Icons.battery_charging_full, label: 'Charged to', value: '$_targetPercent%', color: AppColors.success),
                  Container(width: 1, height: 40, color: AppColors.outlineVariant),
                  _StatTile(icon: Icons.bolt, label: 'Energy', value: '${totalKwh.toStringAsFixed(1)} kWh', color: AppColors.primary),
                  Container(width: 1, height: 40, color: AppColors.outlineVariant),
                  _StatTile(icon: Icons.timer_outlined, label: 'Duration', value: _elapsedFormatted),
                ],
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Cost', style: tt.titleMedium),
                  Text(
                    'NPR ${_estimatedCost.toStringAsFixed(0)}',
                    style: tt.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Status', style: tt.bodySmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Paid', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'CO₂ saved: ${(totalKwh * 0.82).toStringAsFixed(1)} kg vs petrol',
                      style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/user', (_) => false),
            icon: const Icon(Icons.home),
            label: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ── Charging animation ─────────────────────────────────────────────────────────

class _ChargingAnimation extends StatefulWidget {
  final double progress;
  const _ChargingAnimation({required this.progress});

  @override
  State<_ChargingAnimation> createState() => _ChargingAnimationState();
}

class _ChargingAnimationState extends State<_ChargingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) => Transform.scale(
        scale: _pulse.value,
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 44),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatTile({required this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? AppColors.onSurface, fontSize: 14)),
        ],
      ),
    );
  }
}
