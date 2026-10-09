import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_enums.dart';

class AppColors {
  AppColors._();

  static const Color teal = Color(0xFF0B6E77);
  static const Color tealBright = Color(0xFF4FC3CC);
  static const Color navy = Color(0xFF0F2436);
  static const Color navyDark = Color(0xFF0A1824);
  static const Color onNavy = Color(0xFFEDF2F5);
  static const Color onNavyMuted = Color(0xFFB4C2CE);

  static const Color lightBg = Color(0xFFF2F4F6);
  static const Color lightBorder = Color(0xFFE1E6EB);
  static const Color lightInk = Color(0xFF142433);
  static const Color lightSub = Color(0xFF566574);
  static const Color lightChip = Color(0xFFE9EDF1);

  static const Color darkBg = Color(0xFF0B1620);
  static const Color darkSurface = Color(0xFF13202C);
  static const Color darkBorder = Color(0xFF243545);
  static const Color darkInk = Color(0xFFE7EDF2);
  static const Color darkSub = Color(0xFF9DAEBD);
  static const Color darkChip = Color(0xFF1E2E3D);

  static const Color overdueSolid = Color(0xFFB3261E);

  static Color slaForeground(SlaStatus s, Brightness b) {
    final dark = b == Brightness.dark;
    return switch (s) {
      SlaStatus.onTrack => dark ? const Color(0xFF5FD9A2) : const Color(0xFF0B6B45),
      SlaStatus.atRisk => dark ? const Color(0xFFF3BC55) : const Color(0xFF7D4A00),
      SlaStatus.overdue => dark ? const Color(0xFFFF9087) : const Color(0xFFB3261E),
      SlaStatus.completed => dark ? const Color(0xFFB8C6D3) : const Color(0xFF455468),
    };
  }

  static Color slaBackground(SlaStatus s, Brightness b) {
    final dark = b == Brightness.dark;
    return switch (s) {
      SlaStatus.onTrack => dark ? const Color(0xFF103828) : const Color(0xFFE3F5EC),
      SlaStatus.atRisk => dark ? const Color(0xFF3A2C0C) : const Color(0xFFFFF1D6),
      SlaStatus.overdue => dark ? const Color(0xFF431A1C) : const Color(0xFFFDE8E6),
      SlaStatus.completed => dark ? const Color(0xFF223243) : const Color(0xFFE8ECF1),
    };
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final primary = dark ? AppColors.tealBright : AppColors.teal;
    final onPrimary = dark ? const Color(0xFF05242A) : Colors.white;
    final bg = dark ? AppColors.darkBg : AppColors.lightBg;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final ink = dark ? AppColors.darkInk : AppColors.lightInk;
    final sub = dark ? AppColors.darkSub : AppColors.lightSub;
    final chip = dark ? AppColors.darkChip : AppColors.lightChip;
    final primaryContainer = dark ? const Color(0xFF123A40) : const Color(0xFFE0F0F0);

    final scheme = ColorScheme.fromSeed(seedColor: AppColors.teal, brightness: b).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: ink,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: sub,
      surfaceContainerHighest: chip,
      outline: border,
      outlineVariant: border,
    );

    OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryContainer,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected) ? primary : sub,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? primary : sub,
            )),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: const CircleBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: bg),
        actionTextColor: dark ? AppColors.teal : AppColors.tealBright,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const String _key = 'sla_tracker_theme_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = switch (prefs.getString(_key)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> toggle(Brightness currentlyShown) async {
    value = currentlyShown == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value == ThemeMode.dark ? 'dark' : 'light');
  }
}

final ThemeController appThemeController = ThemeController();
