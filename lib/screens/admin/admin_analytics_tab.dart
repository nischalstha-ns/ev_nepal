import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../services/api_service.dart';

class AdminAnalyticsTab extends StatefulWidget {
  const AdminAnalyticsTab({super.key});

  @override
  State<AdminAnalyticsTab> createState() => _AdminAnalyticsTabState();
}

class _AdminAnalyticsTabState extends State<AdminAnalyticsTab> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getAdminDashboard();
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: 'Network Intelligence',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Live Analytics',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NetworkStatusHero(data: _data),
                    const SizedBox(height: 16),
                    _KpiGrid(data: _data),
                    const SizedBox(height: 16),
                    _ForecastCard(),
                    const SizedBox(height: 12),
                    _HeatmapCard(),
                    const SizedBox(height: 12),
                    _LiveHubScan(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Network Status Hero ────────────────────────────────────────────────────────

class _NetworkStatusHero extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _NetworkStatusHero({this.data});

  @override
  Widget build(BuildContext context) {
    final totalStations = data?['total_stations'] ?? 4;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00873a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Network Status',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$totalStations Stations Active',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Live monitoring enabled',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── KPI Grid ───────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _KpiGrid({this.data});

  @override
  Widget build(BuildContext context) {
    final totalStations = data?['total_stations'] ?? 0;
    final totalChargers = data?['total_chargers'] ?? 0;
    final availableChargers = data?['available_chargers'] ?? 0;
    final registeredUsers = data?['registered_users'] ?? 0;
    final activeBookings = data?['active_bookings'] ?? 0;
    final todayRevenue = (data?['today_revenue'] as num?)?.toDouble() ?? 0.0;
    final utilization = totalChargers > 0
        ? ((totalChargers - availableChargers) / totalChargers * 100).toStringAsFixed(1)
        : '0.0';

    return GridView.count(
      crossAxisCount: Responsive.gridCols(context),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        KpiCard(
          title: 'Active Stations',
          value: '$totalStations',
          icon: Icons.ev_station,
          iconColor: AppColors.primary,
          aiAccent: true,
        ),
        KpiCard(
          title: 'Utilization',
          value: '$utilization%',
          icon: Icons.percent,
          iconColor: AppColors.success,
        ),
        KpiCard(
          title: "Today's Revenue",
          value: 'NPR ${(todayRevenue / 1000).toStringAsFixed(1)}K',
          icon: Icons.currency_rupee,
          iconColor: AppColors.primary,
          aiAccent: true,
        ),
        KpiCard(
          title: 'Registered Users',
          value: '$registeredUsers',
          icon: Icons.people_outline,
          iconColor: AppColors.success,
        ),
        KpiCard(
          title: 'Active Bookings',
          value: '$activeBookings',
          icon: Icons.bolt,
          iconColor: AppColors.warning,
        ),
        KpiCard(
          title: 'Total Chargers',
          value: '$totalChargers',
          icon: Icons.electrical_services,
          iconColor: AppColors.onSurfaceVariant,
        ),
      ],
    );
  }
}

// ── Demand Forecast Chart ──────────────────────────────────────────────────────

class _ForecastCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      aiAccent: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Demand Forecasting',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    color: AppColors.onSecondaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _ForecastPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendItem(color: AppColors.primary, label: 'Actual'),
              const SizedBox(width: 16),
              _LegendItem(
                  color: AppColors.outline, label: 'Predicted', dashed: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _LegendItem(
      {required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 10,
          child: CustomPaint(
            painter: _LineSamplePainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _LineSamplePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _LineSamplePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    if (dashed) {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
            Offset(x, size.height / 2),
            Offset(math.min(x + 4, size.width), size.height / 2),
            paint);
        x += 7;
      }
    } else {
      canvas.drawLine(
          Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ForecastPainter extends CustomPainter {
  static const _actual = [0.35, 0.5, 0.45, 0.75, 0.9, 0.6];
  static const _predicted = [0.3, 0.45, 0.5, 0.8, 0.95, 0.65];
  static const _labels = ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'];

  @override
  void paint(Canvas canvas, Size size) {
    const topPad = 8.0;
    const bottomPad = 24.0;
    const leftPad = 4.0;
    final chartH = size.height - topPad - bottomPad;
    final chartW = size.width - leftPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = topPad + chartH * (1 - i / 4);
      double x = leftPad;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), gridPaint);
        x += 8;
      }
    }

    Offset pt(int i, List<double> data) {
      final x = leftPad + (i / (data.length - 1)) * chartW;
      final y = topPad + chartH * (1 - data[i]);
      return Offset(x, y);
    }

    // Actual line (solid)
    final actualPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final actualPath = Path()..moveTo(pt(0, _actual).dx, pt(0, _actual).dy);
    for (int i = 1; i < _actual.length; i++) {
      actualPath.lineTo(pt(i, _actual).dx, pt(i, _actual).dy);
    }
    canvas.drawPath(actualPath, actualPaint);

    // Predicted line (dashed)
    final predPaint = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    for (int i = 0; i < _predicted.length - 1; i++) {
      final p1 = pt(i, _predicted);
      final p2 = pt(i + 1, _predicted);
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final len = math.sqrt(dx * dx + dy * dy);
      final steps = (len / 8).floor();
      for (int s = 0; s < steps; s++) {
        final t0 = s / steps;
        final t1 = (s + 0.45) / steps;
        canvas.drawLine(
          Offset(p1.dx + dx * t0, p1.dy + dy * t0),
          Offset(p1.dx + dx * t1, p1.dy + dy * t1),
          predPaint,
        );
      }
    }

    // "NOW" vertical dashed marker at index 3
    final nowX = pt(3, _actual).dx;
    final nowPaint = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 1.5;
    double ny = topPad;
    while (ny < topPad + chartH) {
      canvas.drawLine(Offset(nowX, ny), Offset(nowX, ny + 4), nowPaint);
      ny += 8;
    }
    final nowTp = TextPainter(
      text: const TextSpan(
        text: 'NOW',
        style: TextStyle(
            fontSize: 9, color: AppColors.warning, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    nowTp.paint(canvas, Offset(nowX - nowTp.width / 2, topPad - 1));

    // X-axis labels
    final labelStyle = const TextStyle(
        fontSize: 9,
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w400);
    for (int i = 0; i < _labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: _labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = leftPad + (i / (_labels.length - 1)) * chartW - tp.width / 2;
      tp.paint(canvas, Offset(x, size.height - bottomPad + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Heatmap ────────────────────────────────────────────────────────────────────

class _HeatmapCard extends StatelessWidget {
  static const _rows = [
    ('Mon', [0, 0, 0, 1, 1, 2, 3, 3, 2, 2, 1, 0]),
    ('Wed', [0, 0, 0, 1, 2, 2, 3, 3, 3, 2, 1, 0]),
    ('Fri', [0, 0, 1, 1, 2, 3, 3, 3, 2, 2, 1, 0]),
    ('Sat', [0, 0, 0, 0, 1, 2, 2, 3, 3, 2, 1, 0]),
  ];

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Peak Hours Heatmap',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _HeatmapRow(label: r.$1, intensities: r.$2),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Low',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.onSurfaceVariant)),
              const SizedBox(width: 4),
              for (int i = 0; i <= 3; i++) ...[
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _cellColor(i),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Text('High',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  static Color _cellColor(int intensity) {
    switch (intensity) {
      case 0:
        return AppColors.surfaceContainer;
      case 1:
        return AppColors.primary.withValues(alpha: 0.20);
      case 2:
        return AppColors.primary.withValues(alpha: 0.50);
      default:
        return AppColors.primary;
    }
  }
}

class _HeatmapRow extends StatelessWidget {
  final String label;
  final List<int> intensities;
  const _HeatmapRow({required this.label, required this.intensities});

  Color _cellColor(int intensity) {
    switch (intensity) {
      case 0:
        return AppColors.surfaceContainer;
      case 1:
        return AppColors.primary.withValues(alpha: 0.20);
      case 2:
        return AppColors.primary.withValues(alpha: 0.50);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: intensities
                .map(
                  (v) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: _cellColor(v),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Live Hub Scan ──────────────────────────────────────────────────────────────

class _LiveHubScan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Live Hub Scan',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusBadge.online('Live'),
            ],
          ),
          const SizedBox(height: 12),
          _StationRow(
            name: 'Kathmandu Central',
            utilization: 0.80,
            badge: StatusBadge.online('Online'),
          ),
          const Divider(height: 16),
          _StationRow(
            name: 'Pokhara Highway',
            utilization: 0.95,
            badge: StatusBadge.info('High Demand'),
          ),
          const Divider(height: 16),
          _StationRow(
            name: 'Lalitpur Plaza',
            utilization: null,
            badge: StatusBadge.warning('Maintenance'),
          ),
        ],
      ),
    );
  }
}

class _StationRow extends StatelessWidget {
  final String name;
  final double? utilization;
  final Widget badge;
  const _StationRow(
      {required this.name, required this.utilization, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: utilization == null
                ? AppColors.warning
                : (utilization! >= 0.9
                    ? AppColors.danger
                    : AppColors.success),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
              if (utilization != null)
                Text('${(utilization! * 100).toInt()}% utilization',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        badge,
      ],
    );
  }
}
