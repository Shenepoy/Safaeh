import 'package:material_ui/material_ui.dart';

import 'semantic_status.dart';

/// Optional theme extension that overrides the semantic status colors.
///
/// [SafaehSemanticStatus] derives success, warning and danger from the
/// [ColorScheme] (success is `primary`). A host whose primary color is not its
/// "positive" color can register this extension on [ThemeData.extensions] and
/// read it through [SafaehStatusColors.of]. Without the extension [of] returns
/// the same values as the [ColorScheme] getters, so existing hosts are
/// unaffected.
@immutable
class SafaehStatusColors extends ThemeExtension<SafaehStatusColors> {
  const SafaehStatusColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
  });

  /// The values [SafaehSemanticStatus] derives from [scheme].
  factory SafaehStatusColors.fromColorScheme(ColorScheme scheme) =>
      SafaehStatusColors(
        success: scheme.success,
        onSuccess: scheme.onSuccess,
        warning: scheme.warning,
        onWarning: scheme.onWarning,
        danger: scheme.danger,
        onDanger: scheme.onDanger,
      );

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;

  /// The registered extension, or colors derived from the current scheme.
  static SafaehStatusColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<SafaehStatusColors>() ??
        SafaehStatusColors.fromColorScheme(theme.colorScheme);
  }

  @override
  SafaehStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
  }) => SafaehStatusColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    danger: danger ?? this.danger,
    onDanger: onDanger ?? this.onDanger,
  );

  @override
  SafaehStatusColors lerp(SafaehStatusColors? other, double t) {
    if (other == null) return this;
    return SafaehStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
    );
  }
}
