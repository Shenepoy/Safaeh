import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'status_colors.dart';
import 'theme.dart';

/// Sync or connectivity state shown by [SafaehStatusIndicator].
enum SafaehSyncState {
  /// Everything is stored.
  saved,

  /// A change is being written or uploaded.
  syncing,

  /// The device is offline; changes wait in the queue.
  offline,

  /// A change could not be saved.
  failed,
}

/// Compact icon, with an optional label, that reports a [SafaehSyncState].
///
/// The host supplies the localized [label]; it is also the semantics label.
/// The icon cross-fades between states and the syncing icon turns, both with
/// zero duration when animations are disabled. The syncing turn runs only
/// while the indicator is visible and syncing.
class SafaehStatusIndicator extends StatelessWidget {
  const SafaehStatusIndicator({
    super.key,
    required this.state,
    required this.label,
    this.showLabel = true,
    this.size = 16,
  });

  final SafaehSyncState state;

  /// Localized text such as "Saved" or "Syncing 2 changes".
  final String label;

  /// Show [label] next to the icon. When false only the icon is drawn.
  final bool showLabel;

  /// Icon size in logical pixels.
  final double size;

  static IconData iconFor(SafaehSyncState state) => switch (state) {
    SafaehSyncState.saved => Icons.check_circle_outline,
    SafaehSyncState.syncing => Icons.sync,
    SafaehSyncState.offline => Icons.cloud_off_outlined,
    SafaehSyncState.failed => Icons.error_outline,
  };

  static Color colorFor(BuildContext context, SafaehSyncState state) {
    final status = SafaehStatusColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return switch (state) {
      SafaehSyncState.saved => status.success,
      SafaehSyncState.syncing => scheme.onSurfaceVariant,
      SafaehSyncState.offline => status.warning,
      SafaehSyncState.failed => status.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SafaehTheme.of(context);
    final color = colorFor(context, state);
    final fade = safaehResolvedMotion(context, tokens.pageIndexMotion);
    final icon = AnimatedSwitcher(
      duration: fade,
      child: _StateIcon(
        key: ValueKey(state),
        state: state,
        color: color,
        size: size,
      ),
    );
    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (showLabel) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(color: color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StateIcon extends StatefulWidget {
  const _StateIcon({
    super.key,
    required this.state,
    required this.color,
    required this.size,
  });

  final SafaehSyncState state;
  final Color color;
  final double size;

  @override
  State<_StateIcon> createState() => _StateIconState();
}

class _StateIconState extends State<_StateIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _turn;

  bool get _spins =>
      widget.state == SafaehSyncState.syncing &&
      !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_spins) {
      _turn ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      if (!_turn!.isAnimating) _turn!.repeat();
    } else {
      _turn?.stop();
    }
  }

  @override
  void dispose() {
    _turn?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      SafaehStatusIndicator.iconFor(widget.state),
      size: widget.size,
      color: widget.color,
    );
    final turn = _turn;
    if (turn == null || !_spins) return icon;
    return AnimatedBuilder(
      animation: turn,
      builder: (context, child) =>
          Transform.rotate(angle: -turn.value * 2 * math.pi, child: child),
      child: icon,
    );
  }
}

/// A one-line bar that appears while the connection is not healthy.
///
/// It collapses to nothing for [SafaehSyncState.saved] and
/// [SafaehSyncState.syncing] unless [showWhenSyncing] is set. For offline and
/// failed states it shows [label] and, when [onRetry] is set, a retry action.
class SafaehConnectivityBar extends StatelessWidget {
  const SafaehConnectivityBar({
    super.key,
    required this.state,
    required this.label,
    this.onRetry,
    this.retryLabel,
    this.showWhenSyncing = false,
  });

  final SafaehSyncState state;
  final String label;
  final VoidCallback? onRetry;

  /// Localized text for the retry action; required to show it.
  final String? retryLabel;
  final bool showWhenSyncing;

  bool get _visible =>
      state == SafaehSyncState.offline ||
      state == SafaehSyncState.failed ||
      (showWhenSyncing && state == SafaehSyncState.syncing);

  @override
  Widget build(BuildContext context) {
    final tokens = SafaehTheme.of(context);
    final duration = safaehResolvedMotion(context, tokens.pageIndexMotion);
    final color = SafaehStatusIndicator.colorFor(context, state);
    final content = !_visible
        ? const SizedBox(width: double.infinity)
        : Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 8, 4),
            color: color.withValues(alpha: 0.14),
            child: Row(
              children: [
                Expanded(
                  child: SafaehStatusIndicator(state: state, label: label),
                ),
                if (onRetry != null && retryLabel != null)
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 44),
                    ),
                    child: Text(retryLabel!),
                  ),
              ],
            ),
          );
    // A zero-duration AnimatedSize would restart its controller during layout.
    if (duration == Duration.zero) return content;
    return AnimatedSize(
      duration: duration,
      curve: tokens.enterCurve,
      alignment: AlignmentDirectional.topStart,
      child: content,
    );
  }
}
