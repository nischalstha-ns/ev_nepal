import 'package:flutter/material.dart';

/// Displays assets/images/logo.png at a fixed width.
/// The logo image already contains the "EVCharging" wordmark — no extra text is added.
///
/// Named constructors:
///   AppLogo.appBar()  — 120 px wide, for AppBar titles
///   AppLogo.card()    — 180 px wide, for login / register card headers
///   AppLogo.splash()  — 260 px wide, for splash / role-selection screens
class AppLogo extends StatelessWidget {
  final double width;

  const AppLogo.appBar({super.key}) : width = 160;
  const AppLogo.card({super.key}) : width = 260;
  const AppLogo.splash({super.key}) : width = 340;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}
