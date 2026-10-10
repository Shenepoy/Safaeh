import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// The visual meaning of a Safaeh feedback message.
enum SafaehFeedbackType { info, success, error }

/// Resolves extra bottom clearance for feedback overlays.
///
/// The returned value is added above the system safe-area inset. Hosts can
/// use it to keep feedback above a floating bottom navigation bar without
/// coupling Safaeh to an application's shell state.
typedef SafaehFeedbackInsetBuilder = double Function(BuildContext context);

/// Builds custom feedback content and receives a dismissal callback owned by
/// Safaeh. Apps can use this for richer messages while keeping placement and
/// animation consistent with ordinary feedback.
typedef SafaehFeedbackBuilder =
    Widget Function(BuildContext context, VoidCallback dismiss);

/// Mounts the shared feedback overlay and its placement policy.
///
/// Put this around the app's navigator (normally in `MaterialApp.builder`) so
/// feedback survives route changes. [bottomInsetBuilder] is intentionally a
/// callback rather than a dependency on a shell implementation: each app can
/// connect its own bottom-navigation visibility state at this seam.
class SafaehFeedbackHost extends StatefulWidget {
  const SafaehFeedbackHost({
    super.key,
    required this.child,
    this.alignment = Alignment.bottomCenter,
    this.itemWidth = 400,
    this.itemWidthBuilder,
    this.bottomInsetBuilder,
    this.startInsetBuilder,
    this.endInsetBuilder,
    this.maxToastLimit = 10,
    this.relayout,
  });

  final Widget child;
  final AlignmentGeometry alignment;
  final double itemWidth;
  final double Function(BuildContext context)? itemWidthBuilder;
  final SafaehFeedbackInsetBuilder? bottomInsetBuilder;

  /// Leading inset outside the toast width. Zero keeps the centered width.
  final SafaehFeedbackInsetBuilder? startInsetBuilder;

  /// Trailing inset outside the toast width. Zero keeps the centered width.
  final SafaehFeedbackInsetBuilder? endInsetBuilder;
  final int maxToastLimit;

  /// Rebuilds placement when shell chrome changes. Toastification keeps the
  /// first config for an alignment, so an idle manager is dropped too.
  final Listenable? relayout;

  @override
  State<SafaehFeedbackHost> createState() => _SafaehFeedbackHostState();
}

class _SafaehFeedbackHostState extends State<SafaehFeedbackHost> {
  @override
  void initState() {
    super.initState();
    widget.relayout?.addListener(_onRelayout);
  }

  @override
  void didUpdateWidget(covariant SafaehFeedbackHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.relayout == widget.relayout) return;
    oldWidget.relayout?.removeListener(_onRelayout);
    widget.relayout?.addListener(_onRelayout);
  }

  void _onRelayout() {
    // ignore: invalid_use_of_visible_for_testing_member
    toastification.managers.removeWhere(
      (_, manager) =>
          // ignore: invalid_use_of_visible_for_testing_member
          manager.notifications.isEmpty &&
          // ignore: invalid_use_of_visible_for_testing_member
          manager.overlayEntry == null,
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.relayout?.removeListener(_onRelayout);
    // dismissAll() schedules another timer. These testing-visible members are
    // the only way to cancel auto-close timers in the same turn.
    // ignore: invalid_use_of_visible_for_testing_member
    for (final manager in toastification.managers.values) {
      // ignore: invalid_use_of_visible_for_testing_member
      for (final item in manager.notifications.toList()) {
        item.dispose();
      }
      // ignore: invalid_use_of_visible_for_testing_member
      manager.notifications.clear();
      // ignore: invalid_use_of_visible_for_testing_member
      manager.overlayEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      config: ToastificationConfig(
        alignment: widget.alignment,
        itemWidth: widget.itemWidthBuilder?.call(context) ?? widget.itemWidth,
        maxToastLimit: widget.maxToastLimit,
        marginBuilder: (context, alignment) {
          final y = alignment.resolve(Directionality.of(context)).y;
          if (y >= 0.5) {
            final extraBottom = (widget.bottomInsetBuilder?.call(context) ?? 0)
                .clamp(0.0, double.infinity);
            final start = (widget.startInsetBuilder?.call(context) ?? 0).clamp(
              0.0,
              double.infinity,
            );
            final end = (widget.endInsetBuilder?.call(context) ?? 0).clamp(
              0.0,
              double.infinity,
            );
            if (start == 0 && end == 0) {
              return EdgeInsets.only(bottom: 12 + extraBottom);
            }
            return EdgeInsetsDirectional.only(
              bottom: 12 + extraBottom,
              start: start,
              end: end,
            );
          }
          if (y <= -0.5) return const EdgeInsets.only(top: 12);
          return EdgeInsets.zero;
        },
      ),
      child: widget.child,
    );
  }
}

/// Shared feedback surface used by the built-in and custom message APIs.
///
/// Stays one slim row; grows only when [child] wraps. A [TextButton] passed
/// as [trailing] is compacted and tinted with the type accent.
class SafaehFeedbackSurface extends StatelessWidget {
  const SafaehFeedbackSurface({
    super.key,
    required this.type,
    required this.child,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsetsDirectional.fromSTEB(10, 8, 12, 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.elevation = 4,
  });

  final SafaehFeedbackType type;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (accent, defaultIcon) = switch (type) {
      SafaehFeedbackType.info => (colors.primary, Icons.info_outline),
      SafaehFeedbackType.success => (
        colors.primary,
        Icons.check_circle_outline,
      ),
      SafaehFeedbackType.error => (colors.error, Icons.error_outline),
    };
    final badge = type == SafaehFeedbackType.error
        ? colors.errorContainer
        : colors.primaryContainer;
    final onBadge = type == SafaehFeedbackType.error
        ? colors.onErrorContainer
        : colors.onPrimaryContainer;

    return Material(
      color: colors.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      shadowColor: colors.shadow.withValues(alpha: 0.25),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
              child: SizedBox.square(
                dimension: 28,
                child: Icon(icon ?? defaultIcon, size: 18, color: onBadge),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: DefaultTextStyle(
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  child: child,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              TextButtonTheme(
                data: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shared toast operations exposed through a small, app-agnostic interface.
extension SafaehFeedbackContext on BuildContext {
  /// Shows an informational, success, or error message.
  void showSafaehFeedback(
    String message, {
    SafaehFeedbackType type = SafaehFeedbackType.info,
    Duration duration = const Duration(seconds: 4),
    IconData? icon,
  }) {
    showSafaehCustomFeedback(
      duration: duration,
      builder: (context, _) =>
          SafaehFeedbackSurface(type: type, icon: icon, child: Text(message)),
    );
  }

  /// Shows a message with one action. Auto-dismiss never invokes the action.
  void showSafaehFeedbackWithAction(
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    SafaehFeedbackType type = SafaehFeedbackType.info,
    Duration duration = const Duration(seconds: 8),
    IconData? icon,
  }) {
    showSafaehCustomFeedback(
      duration: duration,
      builder: (context, dismiss) => SafaehFeedbackSurface(
        type: type,
        icon: icon,
        trailing: TextButton(
          onPressed: () {
            dismiss();
            onAction();
          },
          child: Text(actionLabel),
        ),
        child: Text(message),
      ),
    );
  }

  /// Shows app-specific content using the shared host and animation policy.
  void showSafaehCustomFeedback({
    required SafaehFeedbackBuilder builder,
    Duration duration = const Duration(seconds: 8),
  }) {
    if (!mounted) return;
    // Keep [context] for ToastificationConfig (width, alignment, insets).
    // Pass the navigator overlay explicitly so BetterFeedback's root Overlay
    // does not steal toasts via Overlay.maybeOf(rootOverlay: true).
    toastification.showCustom(
      context: this,
      overlayState: Navigator.maybeOf(this, rootNavigator: true)?.overlay,
      autoCloseDuration: duration,
      builder: (context, holder) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: builder(context, () => toastification.dismiss(holder)),
      ),
    );
  }

  /// Dismisses all feedback messages currently shown by the host.
  void dismissSafaehFeedbacks() {
    if (!mounted) return;
    toastification.dismissAll(delayForAnimation: true);
  }
}
