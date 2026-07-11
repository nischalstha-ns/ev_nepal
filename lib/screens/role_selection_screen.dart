import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../services/auth_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const Color _primary = Color(0xFF006b2c);
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _warning = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    const AppLogo.splash(),
                    const SizedBox(height: 6),
                    const Text(
                      'Select your role to continue',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4A3D),
                      ),
                    ),

                    // Role cards
                    const SizedBox(height: 32),
                    _RoleCard(
                      leadingBg: _primary.withValues(alpha: 0.1),
                      leadingIcon: Icons.ev_station,
                      leadingIconColor: _primary,
                      title: 'EV User',
                      subtitle: 'Find stations, book chargers & track charging',
                      onTap: () {
                        AuthService.setMockUser('user');
                        Navigator.pushReplacementNamed(context, '/user');
                      },
                      borderColor: cs.outlineVariant,
                    ),
                    const SizedBox(height: 12),
                    _RoleCard(
                      leadingBg: _blue.withValues(alpha: 0.1),
                      leadingIcon: Icons.dashboard,
                      leadingIconColor: _blue,
                      title: 'Station Operator',
                      subtitle: 'Manage your stations, chargers & revenue',
                      onTap: () {
                        AuthService.setMockUser('operator');
                        Navigator.pushReplacementNamed(context, '/operator');
                      },
                      borderColor: cs.outlineVariant,
                    ),
                    const SizedBox(height: 12),
                    _RoleCard(
                      leadingBg: _warning.withValues(alpha: 0.1),
                      leadingIcon: Icons.admin_panel_settings,
                      leadingIconColor: _warning,
                      title: 'Super Admin',
                      subtitle:
                          'Network analytics, user management & oversight',
                      onTap: () {
                        AuthService.setMockUser('admin');
                        Navigator.pushReplacementNamed(context, '/admin');
                      },
                      borderColor: cs.outlineVariant,
                    ),

                    // Footer
                    const SizedBox(height: 40),
                    const Text(
                      'Demo App • EVCharging Hackathon 2025',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Color leadingBg;
  final IconData leadingIcon;
  final Color leadingIconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color borderColor;

  const _RoleCard({
    required this.leadingBg,
    required this.leadingIcon,
    required this.leadingIconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 96,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: leadingBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(leadingIcon, color: leadingIconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
