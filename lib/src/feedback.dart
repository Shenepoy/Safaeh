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
            final extraBottom =
                (widget.bottomInsetBuilder?.call(context) ?? 0).clamp(
                  0.0,
                  double.infinity,
                );
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
class SafaehFeedbackSurface extends StatelessWidget {
  const SafaehFeedbackSurface({
    super.key,
    required this.type,
    required this.child,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final SafaehFeedbackType type;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (background, foreground, defaultIcon) = switch (type) {
      SafaehFeedbackType.info => (
        colors.surfaceContainerHigh,
        colors.onSurface,
        Icons.info_outline,
      ),
      SafaehFeedbackType.success => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      SafaehFeedbackType.error => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error_outline,
      ),
    };

    return Material(
      color: background,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? defaultIcon, size: 24, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(color: foreground),
                child: child,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
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
      builder: (context, _) => SafaehFeedbackSurface(
        type: type,
        icon: icon,
        child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis),
      ),
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
        child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis),
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
      builder: (context, holder) =>
          builder(context, () => toastification.dismiss(holder)),
    );
  }

  /// Dismisses all feedback messages currently shown by the host.
  void dismissSafaehFeedbacks() {
    if (!mounted) return;
    toastification.dismissAll(delayForAnimation: true);
  }
}
