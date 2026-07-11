import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  int _activeFilter = 0;
  static const _filters = ['All Drivers', 'Active', 'Platinum', 'Suspended'];

  List<dynamic> _liveUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final result = await ApiService.getUsers();
      if (mounted) setState(() { _liveUsers = result; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_DriverData> get _allDrivers {
    if (_liveUsers.isEmpty) return _drivers;
    return _liveUsers.map((u) {
      final name = u['full_name'] as String? ?? 'Unknown';
      final email = u['email'] as String? ?? '';
      final tier = u['tier'] as String? ?? 'standard';
      final status = u['status'] as String? ?? 'active';
      final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
      _Tier driverTier;
      if (tier == 'platinum') {
        driverTier = _Tier.platinum;
      } else if (tier == 'gold') {
        driverTier = _Tier.gold;
      } else {
        driverTier = _Tier.silver;
      }
      return _DriverData(
        id: u['id'] as String? ?? '',
        name: name,
        email: email,
        initials: initials.isEmpty ? '?' : initials,
        tier: driverTier,
        status: status == 'suspended' ? _DriverStatus.suspended : _DriverStatus.active,
        sessions: 0,
        energyKwh: 0,
      );
    }).toList();
  }

  List<_DriverData> get _displayDrivers {
    final all = _allDrivers;
    switch (_activeFilter) {
      case 1: // Active
        return all.where((d) => d.status == _DriverStatus.active).toList();
      case 2: // Platinum
        return all.where((d) => d.tier == _Tier.platinum).toList();
      case 3: // Suspended
        return all.where((d) => d.status == _DriverStatus.suspended).toList();
      default:
        return all;
    }
  }

  static const _drivers = [
    _DriverData(
      name: 'Aarav Sharma',
      email: 'aarav.sharma@email.com',
      initials: 'AS',
      tier: _Tier.platinum,
      status: _DriverStatus.active,
      sessions: 142,
      energyKwh: 3240,
    ),
    _DriverData(
      name: 'Bina Thapa',
      email: 'bina.thapa@email.com',
      initials: 'BT',
      tier: _Tier.gold,
      status: _DriverStatus.active,
      sessions: 89,
      energyKwh: 1890,
    ),
    _DriverData(
      name: 'Dipendra Karki',
      email: 'dipendra.karki@email.com',
      initials: 'DK',
      tier: _Tier.silver,
      status: _DriverStatus.suspended,
      sessions: 12,
      energyKwh: 245,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: 'Driver Management',
        actions: [
          IconButton(
              icon: const Icon(Icons.search_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // ── Filter pills ───────────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final active = i == _activeFilter;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Driver list ────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const ShimmerList(count: 3)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    itemCount: _displayDrivers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final d = _displayDrivers[i];
                      return _DriverCard(
                        driver: d,
                        onToggleStatus: d.id.isEmpty ? null : () async {
                          final newStatus = d.status == _DriverStatus.suspended ? 'active' : 'suspended';
                          await ApiService.updateUserStatus(d.id, newStatus);
                          _loadUsers();
                        },
                      );
                    },
                  ),
          ),

          // ── Quick actions grid ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _QuickAction(icon: Icons.person_add, label: 'Add Driver'),
                _QuickAction(icon: Icons.electric_car, label: 'Register EV'),
                _QuickAction(icon: Icons.mail_outline, label: 'Broadcast'),
                _QuickAction(icon: Icons.download, label: 'Export'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Driver card ────────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  final _DriverData driver;
  final VoidCallback? onToggleStatus;
  const _DriverCard({required this.driver, this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Text(
                  driver.initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(driver.email,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              _TierBadge(tier: driver.tier),
            ],
          ),

          const Divider(height: 20),

          // Stats row
          Row(
            children: [
              _StatChip(label: '${driver.sessions} Sessions'),
              const SizedBox(width: 8),
              _StatChip(label: '${driver.energyKwh} kWh'),
              const Spacer(),
              _StatusChip(status: driver.status),
            ],
          ),

          const SizedBox(height: 12),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined,
                    size: 20, color: AppColors.onSurfaceVariant),
                onPressed: () {},
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.mail_outline,
                    size: 20, color: AppColors.onSurfaceVariant),
                onPressed: () {},
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  driver.status == _DriverStatus.suspended
                      ? Icons.play_arrow_outlined
                      : Icons.block_outlined,
                  size: 20,
                  color: driver.status == _DriverStatus.suspended
                      ? AppColors.success
                      : AppColors.danger,
                ),
                onPressed: onToggleStatus,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tier badge ─────────────────────────────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  final _Tier tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    switch (tier) {
      case _Tier.platinum:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.workspace_premium,
                  size: 13, color: AppColors.warning),
              SizedBox(width: 3),
              Text('Platinum',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning)),
            ],
          ),
        );
      case _Tier.gold:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star, size: 13, color: AppColors.warning),
              SizedBox(width: 3),
              Text('Gold',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning)),
            ],
          ),
        );
      case _Tier.silver:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star_border, size: 13, color: AppColors.onSurfaceVariant),
              SizedBox(width: 3),
              Text('Silver',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant)),
            ],
          ),
        );
    }
  }
}

// ── Status chip ────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final _DriverStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == _DriverStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFDCFCE7)
            : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Suspended',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.onErrorContainer,
        ),
      ),
    );
  }
}

// ── Stat chip ──────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

// ── Quick action ───────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────────────────────

enum _Tier { platinum, gold, silver }

enum _DriverStatus { active, suspended }

class _DriverData {
  final String id;
  final String name;
  final String email;
  final String initials;
  final _Tier tier;
  final _DriverStatus status;
  final int sessions;
  final int energyKwh;

  const _DriverData({
    this.id = '',
    required this.name,
    required this.email,
    required this.initials,
    required this.tier,
    required this.status,
    required this.sessions,
    required this.energyKwh,
  });
}
