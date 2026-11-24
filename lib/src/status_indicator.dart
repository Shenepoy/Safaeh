import 'dart:async';
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

/// Background and foreground colors for a [SafaehSyncChip] state.
typedef SafaehSyncChipColors = ({Color background, Color foreground});

/// Pill that reports a [SafaehSyncState], collapsing to a circle.
///
/// While the state is in [collapseStates] (by default [SafaehSyncState.saved])
/// the chip shows its label for [collapseAfter] and then shrinks to an
/// icon-only circle; any other state shows the label until it changes. Tapping
/// calls [onTap], for example to open a status sheet. The host supplies the
/// localized [label], decides when the chip is shown, and may restyle each
/// state through [colorsBuilder] (defaults come from [SafaehStatusColors]).
///
/// Hosts place it in an app bar leading or actions slot, or in a rail or
/// header. It keeps a 44 pixel minimum tap target and is keyboard focusable
/// when [onTap] is set.
class SafaehSyncChip extends StatefulWidget {
  const SafaehSyncChip({
    super.key,
    required this.state,
    required this.label,
    this.onTap,
    this.collapseAfter = const Duration(seconds: 2),
    this.collapseStates = const {SafaehSyncState.saved},
    this.minWidthForLabel = 70,
    this.compactSize = 36,
    this.colorsBuilder,
  });

  final SafaehSyncState state;
  final String label;
  final VoidCallback? onTap;
  final Duration collapseAfter;
  final Set<SafaehSyncState> collapseStates;

  /// The label is hidden when the available width is below this.
  final double minWidthForLabel;
  final double compactSize;
  final SafaehSyncChipColors Function(
    BuildContext context,
    SafaehSyncState state,
  )?
  colorsBuilder;

  static SafaehSyncChipColors defaultColors(
    BuildContext context,
    SafaehSyncState state,
  ) {
    final status = SafaehStatusColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return switch (state) {
      SafaehSyncState.saved => (
        background: status.success,
        foreground: status.onSuccess,
      ),
      SafaehSyncState.syncing => (
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      ),
      SafaehSyncState.offline => (
        background: status.warning,
        foreground: status.onWarning,
      ),
      SafaehSyncState.failed => (
        background: status.danger,
        foreground: status.onDanger,
      ),
    };
  }

  @override
  State<SafaehSyncChip> createState() => _SafaehSyncChipState();
}

class _SafaehSyncChipState extends State<SafaehSyncChip> {
  Timer? _timer;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(SafaehSyncChip old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _expanded = true;
      _arm();
    }
  }

  void _arm() {
    _timer?.cancel();
    if (widget.collapseStates.contains(widget.state)) {
      _timer = Timer(widget.collapseAfter, () {
        if (mounted) setState(() => _expanded = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SafaehTheme.of(context);
    final duration = safaehResolvedMotion(context, tokens.pageIndexMotion);
    final colors = (widget.colorsBuilder ?? SafaehSyncChip.defaultColors)(
      context,
      widget.state,
    );
    final textStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w600);

    return Semantics(
      container: true,
      button: widget.onTap != null,
      liveRegion: true,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showLabel =
                  _expanded && constraints.maxWidth >= widget.minWidthForLabel;
              final size = widget.compactSize;
              final chip = InkWell(
                customBorder: const StadiumBorder(),
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeInOut,
                  width: showLabel ? null : size,
                  height: showLabel ? null : size,
                  padding: showLabel
                      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                      : EdgeInsets.all((size - 20) / 2),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(
                      showLabel ? 16 : size / 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: duration,
                        child: _StateIcon(
                          key: ValueKey(widget.state),
                          state: widget.state,
                          color: colors.foreground,
                          size: 20,
                        ),
                      ),
                      if (showLabel) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
              // A zero-duration AnimatedSize would restart during layout.
              return duration == Duration.zero
                  ? chip
                  : AnimatedSize(
                      duration: duration,
                      curve: Curves.easeInOut,
                      child: chip,
                    );
            },
          ),
        ),
      ),
    );
  }
}

/// A one-line bar that appears while the connection is not healthy.
///
/// It collapses to nothing for [SafaehSyncState.saved] and
/// [SafaehSyncState.syncing] unless [showWhenSyncing] is set. For offline and
/// failed states it shows [label] and, when [onRetry] is set, a retry action.
/// When [recoveredLabel] is set, going from offline or failed back to saved or
/// syncing briefly shows that text (for example "Back online") for
/// [recoveredDuration] before collapsing.
class SafaehConnectivityBar extends StatefulWidget {
  const SafaehConnectivityBar({
    super.key,
    required this.state,
    required this.label,
    this.onRetry,
    this.retryLabel,
    this.showWhenSyncing = false,
    this.recoveredLabel,
    this.recoveredDuration = const Duration(seconds: 2),
  });

  final SafaehSyncState state;
  final String label;
  final VoidCallback? onRetry;

  /// Localized text for the retry action; required to show it.
  final String? retryLabel;
  final bool showWhenSyncing;
  final String? recoveredLabel;
  final Duration recoveredDuration;

  @override
  State<SafaehConnectivityBar> createState() => _SafaehConnectivityBarState();
}

class _SafaehConnectivityBarState extends State<SafaehConnectivityBar> {
  Timer? _timer;
  bool _recovered = false;

  static bool _bad(SafaehSyncState s) =>
      s == SafaehSyncState.offline || s == SafaehSyncState.failed;

  @override
  void didUpdateWidget(SafaehConnectivityBar old) {
    super.didUpdateWidget(old);
    if (_bad(old.state) &&
        !_bad(widget.state) &&
        widget.recoveredLabel != null) {
      _timer?.cancel();
      _recovered = true;
      _timer = Timer(widget.recoveredDuration, () {
        if (mounted) setState(() => _recovered = false);
      });
    } else if (_bad(widget.state)) {
      _timer?.cancel();
      _recovered = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _visible =>
      _recovered ||
      _bad(widget.state) ||
      (widget.showWhenSyncing && widget.state == SafaehSyncState.syncing);

  @override
  Widget build(BuildContext context) {
    final tokens = SafaehTheme.of(context);
    final duration = safaehResolvedMotion(context, tokens.pageIndexMotion);
    final shown = _recovered ? SafaehSyncState.saved : widget.state;
    final text = _recovered ? widget.recoveredLabel! : widget.label;
    final color = SafaehStatusIndicator.colorFor(context, shown);
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
                  child: SafaehStatusIndicator(state: shown, label: text),
                ),
                if (!_recovered &&
                    widget.onRetry != null &&
                    widget.retryLabel != null)
                  TextButton(
                    onPressed: widget.onRetry,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 44),
                    ),
                    child: Text(widget.retryLabel!),
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
