import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'driver_dashboard.dart';
import 'stations_tab.dart';
import 'map_screen.dart';
import 'ai_planner_screen.dart';
import 'user_history_tab.dart';
import 'user_profile_screen.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  List<Widget> get _tabs => [
        DriverDashboard(onSwitchTab: _switchTab),
        const StationsTab(),
        const MapScreen(),
        const AiPlannerScreen(),
        const UserHistoryTab(),
        const UserProfileScreen(),
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
                  selectedIndex: _currentIndex > 4 ? 0 : _currentIndex,
                  extended: constraints.maxWidth >= 1024,
                  onDestinationSelected: _switchTab,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  indicatorColor: AppColors.secondaryContainer,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.ev_station_outlined),
                      selectedIcon: Icon(Icons.ev_station),
                      label: Text('Stations'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map),
                      label: Text('Map'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(Icons.auto_awesome),
                      label: Text('AI Plan'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      selectedIcon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _tabs,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex > 4 ? 0 : _currentIndex,
            onDestinationSelected: _switchTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.ev_station_outlined),
                selectedIcon: Icon(Icons.ev_station),
                label: 'Stations',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: 'Map',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'AI Plan',
              ),
              NavigationDestination(
                icon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          ),
        );
      },
    );
  }
}
