import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calora_colors.dart';

ThemeData buildCaloraTheme(CaloraThemeId id) {
  final colors = CaloraColors.forId(id);

  TextStyle display(double size, FontWeight weight) => GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: colors.ink,
      );

  TextStyle body(double size, {Color? color, FontWeight? weight}) => GoogleFonts.sourceSans3(
        fontSize: size,
        fontWeight: weight,
        color: color ?? colors.ink,
      );

  final textTheme = TextTheme(
    displayLarge: display(40, FontWeight.w600),
    displayMedium: display(34, FontWeight.w600),
    headlineLarge: display(28, FontWeight.w600),
    headlineMedium: display(24, FontWeight.w600),
    headlineSmall: display(20, FontWeight.w600),
    titleLarge: body(20, weight: FontWeight.w600),
    titleMedium: body(16, weight: FontWeight.w600),
    bodyLarge: body(16),
    bodyMedium: body(14),
    bodySmall: body(12, color: colors.muted),
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: colors.accent,
      onPrimary: Colors.white,
      secondary: colors.accentSoft,
      surface: colors.surface,
      onSurface: colors.ink,
      error: colors.danger,
    ),
    scaffoldBackgroundColor: colors.bgTop,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: colors.ink,
      centerTitle: false,
      titleTextStyle: display(22, FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface.withValues(alpha: 0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.ringTrack),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.ringTrack),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.accent, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.accentSoft,
      labelStyle: TextStyle(color: colors.ink),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  return base.copyWith(extensions: [colors]);
}
