import 'package:flutter/material.dart';

enum CaloraThemeId { sageMist, dawnCream, harborCalm }

extension CaloraThemeIdX on CaloraThemeId {
  String get storageKey => switch (this) {
        CaloraThemeId.sageMist => 'sage_mist',
        CaloraThemeId.dawnCream => 'dawn_cream',
        CaloraThemeId.harborCalm => 'harbor_calm',
      };

  String get label => switch (this) {
        CaloraThemeId.sageMist => 'Sage Mist',
        CaloraThemeId.dawnCream => 'Dawn Cream',
        CaloraThemeId.harborCalm => 'Harbor Calm',
      };

  static CaloraThemeId fromStorage(String? value) => switch (value) {
        'dawn_cream' => CaloraThemeId.dawnCream,
        'harbor_calm' => CaloraThemeId.harborCalm,
        _ => CaloraThemeId.sageMist,
      };
}

class CaloraColors extends ThemeExtension<CaloraColors> {
  const CaloraColors({
    required this.bgTop,
    required this.bgBottom,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accentSoft,
    required this.ringTrack,
    required this.success,
    required this.danger,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color accentSoft;
  final Color ringTrack;
  final Color success;
  final Color danger;

  static const sageMist = CaloraColors(
    bgTop: Color(0xFFF4F7F2),
    bgBottom: Color(0xFFE4EDE3),
    surface: Color(0xFFFBFDF9),
    ink: Color(0xFF2C332C),
    muted: Color(0xFF6B756B),
    accent: Color(0xFF5F7F62),
    accentSoft: Color(0xFFD7E5D6),
    ringTrack: Color(0xFFD3DDD2),
    success: Color(0xFF4C8B5C),
    danger: Color(0xFFB45A4E),
  );

  static const dawnCream = CaloraColors(
    bgTop: Color(0xFFFBF6EF),
    bgBottom: Color(0xFFF0E2D4),
    surface: Color(0xFFFFFBF7),
    ink: Color(0xFF3A2F28),
    muted: Color(0xFF8A7466),
    accent: Color(0xFFC4785A),
    accentSoft: Color(0xFFF0D7C8),
    ringTrack: Color(0xFFE6D5C6),
    success: Color(0xFF6E8B5E),
    danger: Color(0xFFB45A4E),
  );

  static const harborCalm = CaloraColors(
    bgTop: Color(0xFFF2F5F7),
    bgBottom: Color(0xFFDCE5EA),
    surface: Color(0xFFF8FBFC),
    ink: Color(0xFF2A3338),
    muted: Color(0xFF66757D),
    accent: Color(0xFF5B7C8A),
    accentSoft: Color(0xFFD2E0E6),
    ringTrack: Color(0xFFCDD8DE),
    success: Color(0xFF4F8A78),
    danger: Color(0xFFB45A4E),
  );

  static CaloraColors forId(CaloraThemeId id) => switch (id) {
        CaloraThemeId.sageMist => sageMist,
        CaloraThemeId.dawnCream => dawnCream,
        CaloraThemeId.harborCalm => harborCalm,
      };

  @override
  CaloraColors copyWith({
    Color? bgTop,
    Color? bgBottom,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? accent,
    Color? accentSoft,
    Color? ringTrack,
    Color? success,
    Color? danger,
  }) {
    return CaloraColors(
      bgTop: bgTop ?? this.bgTop,
      bgBottom: bgBottom ?? this.bgBottom,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      ringTrack: ringTrack ?? this.ringTrack,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  CaloraColors lerp(ThemeExtension<CaloraColors>? other, double t) {
    if (other is! CaloraColors) return this;
    return CaloraColors(
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bgBottom: Color.lerp(bgBottom, other.bgBottom, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
