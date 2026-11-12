import 'package:material_ui/material_ui.dart';

/// Gold seed kept for brand, with contrast overrides so outline / secondary
/// copy stay readable on cream and charcoal surfaces.
ThemeData catalogTheme(Brightness brightness) {
  const seed = Color(0xFF8B6914);
  final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final scheme = switch (brightness) {
    Brightness.light => base.copyWith(
      onSurface: const Color(0xFF1F1708),
      onSurfaceVariant: const Color(0xFF534A3C),
      outline: const Color(0xFF7A6F5F),
      outlineVariant: const Color(0xFFC9BDAA),
      surface: const Color(0xFFFFF8F0),
      surfaceContainerLow: const Color(0xFFF7EFE3),
      surfaceContainerHigh: const Color(0xFFEDE3D4),
      surfaceContainerHighest: const Color(0xFFE7DCCB),
    ),
    Brightness.dark => base.copyWith(
      onSurface: const Color(0xFFF6EFE2),
      onSurfaceVariant: const Color(0xFFD0C4B4),
      outline: const Color(0xFFA89884),
      outlineVariant: const Color(0xFF5A5146),
      surface: const Color(0xFF16130F),
      surfaceContainerLow: const Color(0xFF221E18),
      surfaceContainerHigh: const Color(0xFF322C24),
      surfaceContainerHighest: const Color(0xFF3C352C),
    ),
  };
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
  );
}
