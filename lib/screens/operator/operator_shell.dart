import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'operator_dashboard.dart';
import 'live_station_monitor.dart';
import 'smart_queue_screen.dart';
import 'session_management_screen.dart';
import 'cctv_surveillance_screen.dart';
import 'operator_revenue_tab.dart';
import 'operator_settings_tab.dart';

class OperatorShell extends StatefulWidget {
  const OperatorShell({super.key});

  @override
  State<OperatorShell> createState() => _OperatorShellState();
}

class _OperatorShellState extends State<OperatorShell> {
  int _selectedIndex = 0;
  String? _stationId;
  bool _loadingStation = true;

  @override
  void initState() {
    super.initState();
    _resolveStation();
  }

  Future<void> _resolveStation() async {
    final uid = AuthService.currentUserId ?? '';
    if (uid.isNotEmpty) {
      final id = await ApiService.getOperatorStationId(uid);
      if (mounted) setState(() { _stationId = id; _loadingStation = false; });
    } else {
      if (mounted) setState(() => _loadingStation = false);
    }
  }

  List<Widget> get _tabs {
    final sid = _stationId ?? '';
    return [
      const OperatorDashboard(),
      const LiveStationMonitorScreen(),
      const SmartQueueScreen(),
      const SessionManagementScreen(),
      const CctvSurveillanceScreen(),
      OperatorRevenueTab(stationId: sid),
      const OperatorSettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingStation) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_stationId == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.ev_station_outlined, size: 64, color: AppColors.onSurfaceVariant),
                const SizedBox(height: 16),
                const Text('No Station Registered', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Register your charging station to start managing it.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Register Station'),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/operator/register-station');
                    _resolveStation();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  extended: constraints.maxWidth >= 1024,
                  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                  backgroundColor: AppColors.surfaceContainerLowest,
                  indicatorColor: AppColors.secondaryContainer,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.monitor_outlined),
                      selectedIcon: Icon(Icons.monitor),
                      label: Text('Live Monitor'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.queue_outlined),
                      selectedIcon: Icon(Icons.queue),
                      label: Text('Queue'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bolt_outlined),
                      selectedIcon: Icon(Icons.bolt),
                      label: Text('Sessions'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.videocam_outlined),
                      selectedIcon: Icon(Icons.videocam),
                      label: Text('CCTV'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.payments_outlined),
                      selectedIcon: Icon(Icons.payments),
                      label: Text('Revenue'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _tabs,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _tabs,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.monitor_outlined),
                selectedIcon: Icon(Icons.monitor),
                label: 'Monitor',
              ),
              NavigationDestination(
                icon: Icon(Icons.queue_outlined),
                selectedIcon: Icon(Icons.queue),
                label: 'Queue',
              ),
              NavigationDestination(
                icon: Icon(Icons.bolt_outlined),
                selectedIcon: Icon(Icons.bolt),
                label: 'Sessions',
              ),
              NavigationDestination(
                icon: Icon(Icons.videocam_outlined),
                selectedIcon: Icon(Icons.videocam),
                label: 'CCTV',
              ),
              NavigationDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: 'Revenue',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
