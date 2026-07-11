import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'admin_analytics_tab.dart';
import 'admin_network_tab.dart';
import 'admin_users_tab.dart';
import 'membership_plans_tab.dart';
import 'station_approval_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const List<Widget> _bodies = [
    AdminAnalyticsTab(),
    AdminNetworkTab(),
    MembershipPlansTab(),
    AdminUsersTab(),
    StationApprovalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  extended: constraints.maxWidth >= 1024,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  backgroundColor: AppColors.surfaceContainerLowest,
                  indicatorColor: AppColors.secondaryContainer,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: Text('Analytics'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map),
                      label: Text('Network'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.card_membership_outlined),
                      selectedIcon: Icon(Icons.card_membership),
                      label: Text('Plans'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.group_outlined),
                      selectedIcon: Icon(Icons.group),
                      label: Text('Users'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.approval_outlined),
                      selectedIcon: Icon(Icons.approval),
                      label: Text('Stations'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _bodies,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _bodies,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: 'Network',
              ),
              NavigationDestination(
                icon: Icon(Icons.card_membership_outlined),
                selectedIcon: Icon(Icons.card_membership),
                label: 'Plans',
              ),
              NavigationDestination(
                icon: Icon(Icons.group_outlined),
                selectedIcon: Icon(Icons.group),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.approval_outlined),
                selectedIcon: Icon(Icons.approval),
                label: 'Stations',
              ),
            ],
          ),
        );
      },
    );
  }
}
