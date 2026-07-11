import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';

class AdminNetworkTab extends StatefulWidget {
  const AdminNetworkTab({super.key});

  @override
  State<AdminNetworkTab> createState() => _AdminNetworkTabState();
}

class _AdminNetworkTabState extends State<AdminNetworkTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: 'Network Operations',
        actions: [
          IconButton(icon: const Icon(Icons.tune_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // ── Map background ────────────────────────────────────────────────
          _MapBackground(),

          // ── Network Health card ───────────────────────────────────────────
          Positioned(
            top: 16,
            left: 16,
            child: SizedBox(
              width: 220,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge.online('Live'),
                    const SizedBox(height: 10),
                    _StatLine(label: 'Active Sessions', value: '1,204'),
                    const SizedBox(height: 4),
                    _StatLine(label: 'Power Draw', value: '45.2 MW'),
                    const SizedBox(height: 4),
                    _StatLine(label: 'Grid Uptime', value: '99.9%'),
                  ],
                ),
              ),
            ),
          ),

          // ── Map markers ───────────────────────────────────────────────────
          _MapMarker(
            left: 120,
            top: 180,
            color: AppColors.success,
            label: 'Ktm Central',
            pulse: true,
            pulseAnim: _pulseAnim,
          ),
          _MapMarker(
            left: 220,
            top: 240,
            color: AppColors.success,
            label: 'Patan Hub',
            pulse: true,
            pulseAnim: _pulseAnim,
          ),
          _MapMarker(
            left: 170,
            top: 310,
            color: const Color(0xFF0B5FFF),
            label: 'Pokhara HW',
            pulse: false,
            pulseAnim: _pulseAnim,
          ),
          _MapMarker(
            left: 280,
            top: 170,
            color: AppColors.warning,
            label: 'Lalitpur',
            pulse: false,
            pulseAnim: _pulseAnim,
          ),

          // ── FABs ──────────────────────────────────────────────────────────
          Positioned(
            right: 16,
            top: 120,
            child: Column(
              children: [
                _MapFab(icon: Icons.layers, onTap: () {}),
                const SizedBox(height: 10),
                _MapFab(icon: Icons.tune, onTap: () {}),
                const SizedBox(height: 10),
                _MapFab(icon: Icons.my_location, onTap: () {}),
              ],
            ),
          ),

          // ── Bottom sheet ──────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassCard(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Live Hub Scan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _StationMiniCard(
                          name: 'Kathmandu Central',
                          chargerCount: 8,
                        ),
                        SizedBox(width: 12),
                        _StationMiniCard(
                          name: 'Pokhara Highway',
                          chargerCount: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map background ─────────────────────────────────────────────────────────────

class _MapBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8F4E8),
      child: Stack(
        children: [
          // Horizontal roads
          Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Container(height: 10, color: Colors.white70)),
          Positioned(
              top: 260,
              left: 0,
              right: 0,
              child: Container(height: 8, color: Colors.white70)),
          Positioned(
              top: 360,
              left: 0,
              right: 0,
              child: Container(height: 10, color: Colors.white70)),
          // Vertical roads
          Positioned(
              top: 0,
              bottom: 0,
              left: 100,
              child: Container(width: 8, color: Colors.white70)),
          Positioned(
              top: 0,
              bottom: 0,
              left: 220,
              child: Container(width: 10, color: Colors.white70)),
          Positioned(
              top: 0,
              bottom: 0,
              left: 310,
              child: Container(width: 8, color: Colors.white70)),
          // Green park blobs
          Positioned(
            top: 60,
            left: 130,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFA8D5A2),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: 240,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFA8D5A2),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          // Water body
          Positioned(
            top: 380,
            left: 50,
            child: Container(
              width: 110,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF90CAF9).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map marker ─────────────────────────────────────────────────────────────────

class _MapMarker extends StatelessWidget {
  final double left;
  final double top;
  final Color color;
  final String label;
  final bool pulse;
  final Animation<double> pulseAnim;

  const _MapMarker({
    required this.left,
    required this.top,
    required this.color,
    required this.label,
    required this.pulse,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (pulse)
                FadeTransition(
                  opacity: pulseAnim,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB button ─────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Station mini-card ──────────────────────────────────────────────────────────

class _StatLine extends StatelessWidget {
  final String label;
  final String value;
  const _StatLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.onSurfaceVariant)),
        Text(value,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
      ],
    );
  }
}

class _StationMiniCard extends StatelessWidget {
  final String name;
  final int chargerCount;
  const _StationMiniCard({required this.name, required this.chargerCount});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                const Icon(Icons.ev_station,
                    size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '$chargerCount chargers',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'AI Route Planner →',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
