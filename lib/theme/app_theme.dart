import 'package:flutter/material.dart';

class AppColors {
  // Lumina Ecology design system
  static const primary = Color(0xFF006b2c);
  static const primaryContainer = Color(0xFF00873a);
  static const onPrimary = Colors.white;
  static const onPrimaryContainer = Color(0xFFF7FFF2);

  static const secondary = Color(0xFF006D30);
  static const secondaryContainer = Color(0xFF92F5A4);
  static const onSecondaryContainer = Color(0xFF007233);

  static const background = Color(0xFFF8F9FF);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContainer = Color(0xFFE6EEFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainerHigh = Color(0xFFDDE9FF);
  static const surfaceContainerHighest = Color(0xFFD5E3FD);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);

  static const onSurface = Color(0xFF0D1C2F);
  static const onSurfaceVariant = Color(0xFF3E4A3D);
  static const outline = Color(0xFF6E7B6C);
  static const outlineVariant = Color(0xFFBDCABA);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const tertiary = Color(0xFF466252);
  static const tertiaryContainer = Color(0xFF5E7B6A);
  static const onTertiaryContainer = Color(0xFFF6FFF6);

  static const inversePrimary = Color(0xFF62DF7D);
  static const inverseSurface = Color(0xFF233144);

  // Status
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFEAB308);
  static const danger = Color(0xFFEF4444);

  // Legacy aliases kept for compatibility
  static const primaryGreen = primary;
  static const secondaryBlue = Color(0xFF0B5FFF);
  static const cardWhite = surfaceContainerLowest;
  static const darkText = onSurface;
  static const lightText = onSurfaceVariant;
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.96, color: AppColors.onSurface),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.32, color: AppColors.onSurface),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceContainerLowest,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x28BDCABA)),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceContainerLowest,
          indicatorColor: AppColors.secondaryContainer,
          elevation: 3,
          height: 72,
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSecondaryContainer);
            }
            return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.onSecondaryContainer, size: 22);
            }
            return const IconThemeData(color: AppColors.onSurfaceVariant, size: 22);
          }),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0x28BDCABA),
          thickness: 1,
          space: 1,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.surfaceContainerLow,
        ),
      );
}
