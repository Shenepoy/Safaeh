import 'package:material_ui/material_ui.dart';

/// App-wide defaults for sheet content, independent of the floating route skin.
/// Colors left null follow the current Material theme, including dark mode.
@immutable
class SafaehSheetTemplateStyle {
  const SafaehSheetTemplateStyle({
    this.padding = const EdgeInsets.all(24),
    this.headerGap = 20,
    this.footerGap = 8,
    this.surfaceRadius = 16,
    this.surfaceBorderWidth = 1,
    this.surfaceColor,
    this.darkSurfaceColor,
    this.surfaceBorderColor,
  }) : assert(headerGap >= 0),
       assert(footerGap >= 0),
       assert(surfaceRadius >= 0),
       assert(surfaceBorderWidth >= 0);

  final EdgeInsetsGeometry padding;
  final double headerGap, footerGap, surfaceRadius, surfaceBorderWidth;
  final Color? surfaceColor, darkSurfaceColor, surfaceBorderColor;

  SafaehSheetTemplateStyle copyWith({
    EdgeInsetsGeometry? padding,
    double? headerGap,
    double? footerGap,
    double? surfaceRadius,
    double? surfaceBorderWidth,
    Color? surfaceColor,
    Color? darkSurfaceColor,
    Color? surfaceBorderColor,
  }) => SafaehSheetTemplateStyle(
    padding: padding ?? this.padding,
    headerGap: headerGap ?? this.headerGap,
    footerGap: footerGap ?? this.footerGap,
    surfaceRadius: surfaceRadius ?? this.surfaceRadius,
    surfaceBorderWidth: surfaceBorderWidth ?? this.surfaceBorderWidth,
    surfaceColor: surfaceColor ?? this.surfaceColor,
    darkSurfaceColor: darkSurfaceColor ?? this.darkSurfaceColor,
    surfaceBorderColor: surfaceBorderColor ?? this.surfaceBorderColor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafaehSheetTemplateStyle &&
          padding == other.padding &&
          headerGap == other.headerGap &&
          footerGap == other.footerGap &&
          surfaceRadius == other.surfaceRadius &&
          surfaceBorderWidth == other.surfaceBorderWidth &&
          surfaceColor == other.surfaceColor &&
          darkSurfaceColor == other.darkSurfaceColor &&
          surfaceBorderColor == other.surfaceBorderColor;

  @override
  int get hashCode => Object.hash(
    padding,
    headerGap,
    footerGap,
    surfaceRadius,
    surfaceBorderWidth,
    surfaceColor,
    darkSurfaceColor,
    surfaceBorderColor,
  );
}
