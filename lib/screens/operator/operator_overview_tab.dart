import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/realtime_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/charger_status_chip.dart';

class OperatorOverviewTab extends StatefulWidget {
  final String stationId;
  const OperatorOverviewTab({super.key, required this.stationId});

  @override
  State<OperatorOverviewTab> createState() => _OperatorOverviewTabState();
}

class _OperatorOverviewTabState extends State<OperatorOverviewTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String get _stationId => widget.stationId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final chargers = await ApiService.getChargers(_stationId);
      final bookings = await ApiService.getBookings(stationId: _stationId);
      final available = chargers.where((c) => c['status'] == 'available').length;
      final occupied = chargers.where((c) => c['status'] == 'occupied').length;
      final active = bookings.where((b) => b['status'] == 'charging').length;
      final revenue = bookings
          .where((b) => b['payment_status'] == 'paid')
          .fold<double>(0, (sum, b) => sum + ((b['estimated_cost'] ?? 0) as num).toDouble());
      setState(() {
        _stats = {
          'total': chargers.length,
          'available': available,
          'occupied': occupied,
          'bookings_today': bookings.length,
          'active': active,
          'revenue': revenue.toStringAsFixed(0),
        };
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _stats = {
          'total': 0,
          'available': 0,
          'occupied': 0,
          'bookings_today': 0,
          'active': 0,
          'revenue': '0',
        };
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: 'Nepal Grid Solutions',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/operator/register-station'),
        icon: const Icon(Icons.add_business),
        label: const Text('Register Station'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── System Overview header ──────────────────────────────
                Row(
                  children: [
                    Text('System Overview', style: tt.titleLarge),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {},
                      child: const Text('Export'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── KPI 2×2 grid ───────────────────────────────────────
                GridView.count(
                  crossAxisCount: Responsive.gridCols(context),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    // Total Stations
                    KpiCard(
                      title: 'Total Stations',
                      value: '12',
                      icon: Icons.location_on,
                      iconColor: AppColors.primary,
                    ),
                    // Active Sessions — aiAccent + pulse dot
                    SurfaceCard(
                      aiAccent: true,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.bolt,
                                    size: 18, color: AppColors.success),
                              ),
                              const Spacer(),
                              _PulseDot(color: AppColors.success),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('${_stats!['active']}',
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface)),
                          const SizedBox(height: 2),
                          const Text('Active Sessions',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    // Revenue Today + trend chip
                    KpiCard(
                      title: 'Revenue Today',
                      value: 'NPR ${_stats!['revenue']}',
                      icon: Icons.currency_rupee,
                      iconColor: AppColors.success,
                      trailing: _TrendChip(label: '+15%'),
                    ),
                    // Energy + progress bar
                    SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.energy_savings_leaf,
                                    size: 18, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('1.2 MWh',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface)),
                          const SizedBox(height: 2),
                          const Text('Energy',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.6,
                              minHeight: 5,
                              backgroundColor: AppColors.surfaceContainerLow,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Live Utilization chart ──────────────────────────────
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Station Utilization', style: tt.titleMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: CustomPaint(
                          painter: _LineChartPainter(
                              [0.3, 0.5, 0.4, 0.7, 0.85, 0.65]),
                          size: Size.infinite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['08:00', '10:00', '12:00', '14:00', '16:00', 'Now']
                            .map((l) => Text(l,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant)))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // ── Revenue 7-day bars ──────────────────────────────────
                const SizedBox(height: 12),
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Revenue Trends (7 days)', style: tt.titleMedium),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 80,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: () {
                            const days = [
                              'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                            ];
                            const heights = [
                              0.4, 0.55, 0.45, 0.7, 0.6, 0.9, 0.5
                            ];
                            return List.generate(7, (i) {
                              final isLast = i == 6;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: 28,
                                        height: 60 * heights[i],
                                        decoration: BoxDecoration(
                                          color: isLast
                                              ? AppColors.primary
                                              : AppColors.primary
                                                  .withValues(alpha: 0.35),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(4)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(days[i],
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.onSurfaceVariant)),
                                ],
                              );
                            });
                          }(),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Live Chargers panel ─────────────────────────────────
                const SizedBox(height: 12),
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Live Chargers', style: tt.titleMedium),
                          const SizedBox(width: 8),
                          StatusBadge.online('Live'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: RealtimeService.watchChargersByStation(
                            _stationId),
                        builder: (context, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          final chargers = snap.data ?? [];
                          if (chargers.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('No chargers found.',
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant)),
                            );
                          }
                          return Column(
                            children: chargers.map((c) {
                              final isOccupied = c['status'] == 'occupied';
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.ev_station,
                                            size: 18,
                                            color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                              c['name'] ?? 'Charger',
                                              style: tt.labelLarge),
                                        ),
                                        ChargerStatusChip(
                                            status:
                                                c['status'] ?? 'available'),
                                      ],
                                    ),
                                    if (isOccupied) ...[
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: const LinearProgressIndicator(
                                          value: 0.68,
                                          minHeight: 5,
                                          backgroundColor:
                                              AppColors.surfaceContainerLow,
                                          valueColor:
                                              AlwaysStoppedAnimation(
                                                  AppColors.success),
                                        ),
                                      ),
                                    ],
                                    const Divider(height: 16),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

// ── Trend chip ──────────────────────────────────────────────────────────────

class _TrendChip extends StatelessWidget {
  final String label;
  const _TrendChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, size: 11, color: AppColors.success),
          const SizedBox(width: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success)),
        ],
      ),
    );
  }
}

// ── Pulse dot ───────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}

// ── Line chart painter ───────────────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final List<double> data; // 0.0–1.0 normalised
  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const hPad = 8.0;
    const vPad = 8.0;
    final chartW = size.width - hPad * 2;
    final chartH = size.height - vPad * 2;

    // ── Grid lines ────────────────────────────────────────────────────────────
    final dashPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.4)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 4; i++) {
      final y = vPad + (chartH / 4) * i;
      _drawDashedLine(canvas, Offset(hPad, y), Offset(hPad + chartW, y),
          dashPaint);
    }

    // ── Area fill ─────────────────────────────────────────────────────────────
    final areaPath = Path();
    final pts = _getPoints(hPad, vPad, chartW, chartH);
    areaPath.moveTo(pts.first.dx, size.height - vPad);
    for (final p in pts) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(pts.last.dx, size.height - vPad);
    areaPath.close();

    final areaGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.20),
          AppColors.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaGrad);

    // ── Line ──────────────────────────────────────────────────────────────────
    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // ── Dots ──────────────────────────────────────────────────────────────────
    final dotFill = Paint()
      ..color = AppColors.surfaceContainerLowest
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final p in pts) {
      canvas.drawCircle(p, 4, dotFill);
      canvas.drawCircle(p, 4, dotBorder);
    }
  }

  List<Offset> _getPoints(
      double hPad, double vPad, double chartW, double chartH) {
    return List.generate(data.length, (i) {
      final x = hPad + (chartW / (data.length - 1)) * i;
      final y = vPad + chartH * (1.0 - data[i]);
      return Offset(x, y);
    });
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 4.0;
    const gapLen = 4.0;
    final total = (end.dx - start.dx).abs();
    double dist = 0;
    while (dist < total) {
      final segEnd = (dist + dashLen).clamp(0.0, total);
      canvas.drawLine(
        Offset(start.dx + dist, start.dy),
        Offset(start.dx + segEnd, start.dy),
        paint,
      );
      dist += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
