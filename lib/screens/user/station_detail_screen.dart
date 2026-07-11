import 'package:flutter/material.dart';
import '../../models/station_model.dart';
import '../../models/charger_model.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charger_status_chip.dart';
import '../../widgets/glass_card.dart';

class StationDetailScreen extends StatefulWidget {
  final Station station;
  const StationDetailScreen({super.key, required this.station});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.station;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              title: Text(
                s.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.secondaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.ev_station, size: 64, color: Colors.white),
                        const SizedBox(height: 8),
                        // Rating badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                              const SizedBox(width: 4),
                              Text(
                                s.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Chargers'),
                Tab(text: 'Info'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Chargers ──────────────────────────────────────────────
            _ChargersTab(station: s),

            // ── Tab 2: Info ──────────────────────────────────────────────────
            _InfoTab(station: s, tt: tt),
          ],
        ),
      ),
    );
  }
}

// ── Chargers tab ───────────────────────────────────────────────────────────────

class _ChargersTab extends StatelessWidget {
  final Station station;
  const _ChargersTab({required this.station});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: RealtimeService.watchChargersByStation(station.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final chargers =
            (snapshot.data ?? []).map((j) => Charger.fromJson(j)).toList();
        if (chargers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ev_station_outlined, size: 56, color: AppColors.outlineVariant),
                SizedBox(height: 12),
                Text('No chargers found', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ),
          );
        }

        // Group: available first
        final sorted = [...chargers]
          ..sort((a, b) => (b.isAvailable ? 1 : 0) - (a.isAvailable ? 1 : 0));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: sorted.length,
          itemBuilder: (_, i) => _ChargerCard(charger: sorted[i], station: station),
        );
      },
    );
  }
}

// ── Info tab ───────────────────────────────────────────────────────────────────

class _InfoTab extends StatefulWidget {
  final Station station;
  final TextTheme tt;
  const _InfoTab({required this.station, required this.tt});

  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> {
  List<Review> _reviews = [];
  bool _reviewsLoading = true;
  double _avgRating = 0;

  static IconData _amenityIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('wifi') || l.contains('wi-fi')) return Icons.wifi;
    if (l.contains('restroom') || l.contains('toilet') || l.contains('wc')) return Icons.wc;
    if (l.contains('cafe') || l.contains('café') || l.contains('coffee')) return Icons.local_cafe;
    if (l.contains('parking')) return Icons.local_parking;
    if (l.contains('cctv') || l.contains('security') || l.contains('camera')) return Icons.security;
    if (l.contains('food') || l.contains('restaurant')) return Icons.restaurant;
    if (l.contains('ev') || l.contains('charg')) return Icons.ev_station;
    return Icons.check_circle_outline;
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ApiService.getReviews(widget.station.id);
      if (mounted) {
        final reviews =
            data.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
        final avg = reviews.isEmpty
            ? 0.0
            : reviews.fold<double>(0, (s, r) => s + r.rating) / reviews.length;
        setState(() {
          _reviews = reviews;
          _avgRating = avg;
          _reviewsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.station;
    final tt = widget.tt;
    final hours = (s.openingTime != null && s.closingTime != null)
        ? '${s.openingTime} – ${s.closingTime}'
        : 'Open 24 hrs';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Station Details', style: tt.titleMedium),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: '${s.address}, ${s.city}',
              ),
              const Divider(height: 20),
              _DetailRow(
                icon: Icons.access_time_outlined,
                label: hours,
              ),
              const Divider(height: 20),
              _DetailRow(
                icon: Icons.star_outline_rounded,
                label: _reviewsLoading
                    ? '${s.rating.toStringAsFixed(1)} / 5.0 rating'
                    : _reviews.isEmpty
                        ? 'No reviews yet'
                        : '${_avgRating.toStringAsFixed(1)} / 5.0 (${_reviews.length} reviews)',
              ),
              if (s.contactNumber != null) ...[
                const Divider(height: 20),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${s.contactNumber}...')),
                    );
                  },
                  child: _DetailRow(
                    icon: Icons.phone_outlined,
                    label: s.contactNumber!,
                    actionColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (s.hasBatterySwap) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user/battery-swap'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6D28D9).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.battery_charging_full, color: Color(0xFF6D28D9), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Battery Swap Available',
                          style: TextStyle(
                            color: Color(0xFF6D28D9),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to view available batteries and reserve',
                          style: tt.bodySmall?.copyWith(color: const Color(0xFF6D28D9)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF6D28D9)),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amenities', style: tt.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: s.amenities.isNotEmpty
                    ? s.amenities.map((a) => _AmenityChip(icon: _amenityIcon(a), label: a)).toList()
                    : const [
                        _AmenityChip(icon: Icons.local_parking, label: 'Parking'),
                      ],
              ),
            ],
          ),
        ),

        // ── Reviews ──────────────────────────────────────────────────────────
        const SizedBox(height: 16),
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Reviews', style: tt.titleMedium),
                  const Spacer(),
                  if (!_reviewsLoading && _reviews.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          _avgRating.toStringAsFixed(1),
                          style: tt.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_reviewsLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ))
              else if (_reviews.isEmpty)
                const Text('No reviews yet. Be the first to review!',
                    style: TextStyle(color: AppColors.onSurfaceVariant))
              else
                ..._reviews.take(5).map((r) => _ReviewTile(review: r)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uid = AuthService.currentUserId ?? '';
                    final result = await Navigator.pushNamed(
                      context,
                      '/user/review',
                      arguments: {
                        'stationId': s.id,
                        'stationName': s.name,
                        'userId': uid,
                      },
                    );
                    if (result == true) _loadReviews();
                  },
                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                  label: const Text('Write a Review'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  String get _initials {
    final name = review.userName ?? 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String get _timeAgo {
    try {
      final dt = DateTime.parse(review.createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      return '${diff.inHours}h ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondaryContainer,
            child: Text(_initials,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.onSecondaryContainer)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.userName ?? 'User',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    Text(_timeAgo,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.outline)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(
                      5,
                      (i) => Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 13,
                            color: const Color(0xFFF59E0B),
                          )),
                ),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(review.comment!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.onSurface)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? actionColor;

  const _DetailRow({required this.icon, required this.label, this.actionColor});

  @override
  Widget build(BuildContext context) {
    final color = actionColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color ?? AppColors.onSurface,
              fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        if (color != null) Icon(Icons.phone_in_talk, size: 16, color: color),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

// ── Charger card ───────────────────────────────────────────────────────────────

class _ChargerCard extends StatelessWidget {
  final Charger charger;
  final Station station;

  const _ChargerCard({required this.charger, required this.station});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: charger.isAvailable
                        ? AppColors.primary.withValues(alpha: 0.10)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.bolt,
                    color: charger.isAvailable ? AppColors.primary : AppColors.outlineVariant,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(charger.name, style: tt.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${charger.chargerType} · ${charger.powerKw.toInt()} kW · ${charger.connectorType}',
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
                ChargerStatusChip(status: charger.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'NPR ${charger.pricePerKwh.toInt()}/kWh',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (charger.isAvailable)
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/user/booking',
                      arguments: {'station': station, 'charger': charger},
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Book Now'),
                  )
                else
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/user/queue',
                      arguments: {'station': station, 'charger': charger},
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Join Queue'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
