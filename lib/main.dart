import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/user_shell.dart';
import 'screens/user/battery_swap_screen.dart';
import 'screens/user/station_detail_screen.dart';
import 'screens/user/booking_screen.dart';
import 'screens/user/qr_screen.dart';
import 'screens/user/queue_screen.dart';
import 'screens/user/user_profile_screen.dart';
import 'screens/operator/operator_shell.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/admin/station_approval_screen.dart';
import 'screens/admin/admin_network_tab.dart';
import 'screens/user/membership_screen.dart';
import 'screens/user/submit_review_screen.dart';
import 'screens/user/notifications_screen.dart';
import 'screens/operator/register_station_screen.dart';
import 'screens/operator/qr_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const EVChargingApp());
}

class EVChargingApp extends StatelessWidget {
  const EVChargingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV Charging',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/roles': (_) => const RoleSelectionScreen(),
        '/user': (_) => const UserShell(),
        '/operator': (_) => const OperatorShell(),
        '/admin': (_) => const AdminShell(),
        '/user/battery-swap': (_) => const BatterySwapScreen(),
        '/user/membership': (_) => const MembershipScreen(),
        '/user/notifications': (_) => const NotificationsScreen(),
        '/operator/register-station': (_) => const RegisterStationScreen(),
        '/operator/qr-scan': (_) => const QrScannerScreen(),
        '/admin/stations': (_) => const StationApprovalScreen(),
        '/admin/monitoring': (_) => const AdminNetworkTab(),
        '/user/profile': (_) => const UserProfileScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/user/station') {
          final args = settings.arguments as Map<String, dynamic>;
          return fadeSlideRoute(
            settings: settings,
            child: StationDetailScreen(station: args['station']),
          );
        }
        if (settings.name == '/user/booking') {
          final args = settings.arguments as Map<String, dynamic>;
          return fadeSlideRoute(
            settings: settings,
            child: BookingScreen(
              station: args['station'],
              charger: args['charger'],
            ),
          );
        }
        if (settings.name == '/user/qr') {
          final args = settings.arguments as Map<String, dynamic>;
          return fadeSlideRoute(
            settings: settings,
            child: QRScreen(booking: args['booking']),
          );
        }
        if (settings.name == '/user/queue') {
          final args = settings.arguments as Map<String, dynamic>;
          return fadeSlideRoute(
            settings: settings,
            child: QueueScreen(
              station: args['station'],
              charger: args['charger'],
            ),
          );
        }
        if (settings.name == '/user/review') {
          final args = settings.arguments as Map<String, dynamic>;
          return fadeSlideRoute(
            settings: settings,
            child: SubmitReviewScreen(
              stationId: args['stationId'],
              stationName: args['stationName'],
            ),
          );
        }
        return null;
      },
    );
  }
}

/// Top-level helper — produces a fade + subtle rightward slide transition.
PageRouteBuilder<dynamic> fadeSlideRoute({
  required RouteSettings settings,
  required Widget child,
}) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, _, _) => child,
    transitionsBuilder: (_, animation, _, pageChild) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0.03, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: pageChild,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 260),
  );
}
