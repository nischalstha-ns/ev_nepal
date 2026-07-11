import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 600;
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1024;

  static double fontSize(BuildContext context, {required double mobile, double? tablet, required double desktop}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? (mobile + desktop) / 2;
    return mobile;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    if (isTablet(context)) return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static int gridCols(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}
