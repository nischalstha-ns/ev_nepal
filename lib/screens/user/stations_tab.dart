import 'package:flutter/material.dart';
import '../../models/station_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/branded_app_bar.dart';

class StationsTab extends StatefulWidget {
  const StationsTab({super.key});

  @override
  State<StationsTab> createState() => _StationsTabState();
}

class _StationsTabState extends State<StationsTab> {
  List<Station> _stations = [];
  bool _loading = true;
  String? _error;
  String _filterQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadStations();
    _searchController.addListener(() {
      setState(() => _filterQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getStations();
      final stations = data.map((j) => Station.fromJson(j as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _stations = stations; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Station> get _filtered {
    if (_filterQuery.isEmpty) return _stations;
    return _stations.where((s) {
      return s.name.toLowerCase().contains(_filterQuery) ||
          s.city.toLowerCase().contains(_filterQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: 'Stations',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _searchFocus.requestFocus(),
            tooltip: 'Search',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStations,
        color: AppColors.primary,
        child: Column(
          children: [
            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
                  hintText: 'Search stations...',
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  suffixIcon: _filterQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),

            // ── Body ───────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Padding(
                      padding: Responsive.screenPadding(context),
                      child: const ShimmerList(count: 4, itemHeight: 110),
                    )
                  : _error != null
                      ? _ErrorView(error: _error!, onRetry: _loadStations)
                      : _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.ev_station_outlined,
                                      size: 56, color: AppColors.outlineVariant),
                                  const SizedBox(height: 12),
                                  Text(
                                    _filterQuery.isEmpty
                                        ? 'No stations found'
                                        : 'No results for "$_filterQuery"',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth >= 1024) {
                                  return GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.1,
                                    ),
                                    itemCount: _filtered.length,
                                    itemBuilder: (_, i) => _StationListCard(
                                      station: _filtered[i],
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/user/station',
                                        arguments: {'station': _filtered[i]},
                                      ),
                                    ),
                                  );
                                } else if (constraints.maxWidth >= 600) {
                                  return GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.1,
                                    ),
                                    itemCount: _filtered.length,
                                    itemBuilder: (_, i) => _StationListCard(
                                      station: _filtered[i],
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/user/station',
                                        arguments: {'station': _filtered[i]},
                                      ),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                    itemCount: _filtered.length,
                                    itemBuilder: (_, i) => _StationListCard(
                                      station: _filtered[i],
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/user/station',
                                        arguments: {'station': _filtered[i]},
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Station list card ──────────────────────────────────────────────────────────

class _StationListCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const _StationListCard({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hours = (station.openingTime != null && station.closingTime != null)
        ? '${station.openingTime} – ${station.closingTime}'
        : 'Open 24 hrs';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon + name/city + rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.ev_station, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(station.name, style: tt.titleMedium, maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(station.city, style: tt.bodyMedium, maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          station.rating.toStringAsFixed(1),
                          style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Bottom row: chips + hours + CTA
                Row(
                  children: [
                    _Chip(
                      label: '${station.availableChargers}/${station.totalChargers} Available',
                      bg: station.availableChargers > 0
                          ? const Color(0xFFDCFCE7)
                          : AppColors.errorContainer,
                      fg: station.availableChargers > 0
                          ? AppColors.success
                          : AppColors.onErrorContainer,
                    ),
                    const SizedBox(width: 6),
                    if (station.hasBatterySwap)
                      const _Chip(
                        label: 'Battery Swap',
                        bg: Color(0xFFEDE9FE),
                        fg: Color(0xFF6D28D9),
                      ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(hours, style: tt.bodySmall),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'View →',
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            Text('Could not load stations', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
