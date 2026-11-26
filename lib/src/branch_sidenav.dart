import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'rtl.dart';
import 'theme.dart';
import 'user_text.dart';

/// One row of a [SafaehBranchSidenav].
///
/// [id] identifies the row across rebuilds: a row whose id stays keeps its
/// place while rows around it animate in or out. [depth] indents the row to
/// show branching (0 for top-level, 1 for a section of the open item, 2 for
/// a page inside that section).
@immutable
class SafaehBranchNavItem {
  const SafaehBranchNavItem({
    required this.id,
    required this.label,
    required this.onTap,
    this.icon,
    this.selectedIcon,
    this.leading,
    this.subtitle,
    this.depth = 0,
    this.animateSelection = true,
  }) : assert(icon != null || leading != null, 'Give an icon or a leading');

  final Key id;
  final String label;
  final VoidCallback onTap;

  /// Shown when not selected (and when selected, unless [selectedIcon]).
  final IconData? icon;
  final IconData? selectedIcon;

  /// A custom mark (an avatar) used instead of [icon].
  final Widget? leading;
  final String? subtitle;
  final int depth;

  /// False makes the selection fill switch instantly, for a row that is
  /// selected as the rail changes context (it would otherwise flash).
  final bool animateSelection;
}

/// A navigation rail whose rows branch with the current context.
///
/// - The rail is one widget for the whole app: changing [items] reconciles the
///   rows by [SafaehBranchNavItem.id]. Rows that stay keep their place; new
///   rows grow and fade in, gone rows shrink and fade out.
/// - [title] crossfades when it changes (the app name, then the open list).
/// - Rows indent by [SafaehBranchNavItem.depth]. When the selected row is two
///   levels deep, its parent turns bold and shows an expand arrow.
/// - With [highlightAncestors], every row the selected one branches from
///   (its parent, that row's parent, ...) gets a secondary tone fill, so the
///   path to the selection reads at a glance.
/// - [pinnedItems] stay at the bottom (settings, account) and never move.
/// - Collapsing morphs the width; labels fade out and icons stay centered.
/// - [asDrawer] lays the same content out for a temporary drawer.
class SafaehBranchSidenav extends StatelessWidget {
  const SafaehBranchSidenav({
    super.key,
    required this.title,
    required this.items,
    this.pinnedItems = const [],
    this.selectedId,
    this.collapsed = false,
    this.asDrawer = false,
    this.onToggleCompact,
    this.expandTooltip,
    this.collapseTooltip,
    this.compactWidth,
    this.expandedWidth,
    this.duration,
    this.indentStep = 16,
    this.footer,
    this.haptics = true,
    this.highlightAncestors = false,
    this.railKey = const ValueKey('safaeh_branch_nav_rail'),
    this.expandKey = const ValueKey('safaeh_branch_nav_expand'),
    this.collapseKey = const ValueKey('safaeh_branch_nav_collapse'),
  });

  final String title;
  final List<SafaehBranchNavItem> items;
  final List<SafaehBranchNavItem> pinnedItems;

  /// The id of the selected row, in [items] or [pinnedItems].
  final Key? selectedId;
  final bool collapsed;
  final bool asDrawer;

  /// Shows the menu / chevron button in the header. Null hides it.
  final VoidCallback? onToggleCompact;
  final String? expandTooltip;
  final String? collapseTooltip;
  final double? compactWidth;
  final double? expandedWidth;

  /// Width morph, row insert/remove and title crossfade. Defaults to
  /// [SafaehThemeData.navMotion]; reduced motion makes it instant.
  final Duration? duration;
  final double indentStep;

  /// A small line under the pinned rows (a version), hidden when compact.
  final Widget? footer;

  /// A light haptic on every row tap.
  final bool haptics;

  /// Fills the rows the selected row branches from with
  /// [ColorScheme.secondaryContainer] (ink [ColorScheme.onSecondaryContainer]).
  final bool highlightAncestors;
  final Key railKey;
  final Key expandKey;
  final Key collapseKey;

  @override
  Widget build(BuildContext context) {
    final tokens = SafaehTheme.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final compactW = compactWidth ?? tokens.compactNavWidth;
    final expandedW = expandedWidth ?? tokens.expandedNavWidth;
    final compact = collapsed && !asDrawer;
    final motion = safaehResolvedMotion(context, duration ?? tokens.navMotion);

    final activeIndex = items.indexWhere((i) => i.id == selectedId);
    var expandedParent = -1;
    if (activeIndex >= 0 && items[activeIndex].depth > 1) {
      final want = items[activeIndex].depth - 1;
      for (var i = activeIndex - 1; i >= 0; i--) {
        if (items[i].depth == want) {
          expandedParent = i;
          break;
        }
      }
    }

    // The rows the selection branches from: walk up one depth at a time.
    final ancestors = <int>{};
    if (highlightAncestors && activeIndex >= 0) {
      var want = items[activeIndex].depth - 1;
      for (var i = activeIndex - 1; i >= 0 && want >= 0; i--) {
        if (items[i].depth == want) {
          ancestors.add(i);
          want--;
        }
      }
    }

    // The line joining the path: from each row on it down to the next one,
    // under the parent's icon, through any rows in between. Each row gets
    // the depth of the line entering it from above and leaving it below.
    final lineAbove = <int, int>{};
    final lineBelow = <int, int>{};
    final bridgeAbove = <int, int>{};
    final bridgeBelow = <int, int>{};
    final aboveKind = <int, _Piece>{};
    final belowKind = <int, _Piece>{};
    // When each row's piece of the line draws, as a share of the whole
    // draw: top to bottom, so it flows from the parent into the selection.
    final lineSlot = <int, (double, double)>{};
    if (ancestors.isNotEmpty) {
      final path = [...ancestors.toList()..sort(), activeIndex];
      final first = path.first;
      final rows = activeIndex - first + 1;
      for (var i = first; i <= activeIndex; i++) {
        lineSlot[i] = ((i - first) / rows, (i - first + 1) / rows);
      }
      for (var k = 0; k + 1 < path.length; k++) {
        final depth = items[path[k]].depth;
        lineBelow[path[k]] = depth;
        belowKind[path[k]] = _Piece.source;
        for (var i = path[k] + 1; i < path[k + 1]; i++) {
          lineAbove[i] = depth;
          lineBelow[i] = depth;
          aboveKind[i] = _Piece.through;
          belowKind[i] = _Piece.through;
        }
        lineAbove[path[k + 1]] = depth;
        aboveKind[path[k + 1]] = _Piece.target;
        // Next to each other: one shape, bridged across the width both
        // pills share, instead of a thin line.
        if (path[k + 1] == path[k] + 1) {
          final shared = depth > items[path[k + 1]].depth
              ? depth
              : items[path[k + 1]].depth;
          bridgeBelow[path[k]] = shared;
          bridgeAbove[path[k + 1]] = shared;
          belowKind[path[k]] = _Piece.bridge;
          aboveKind[path[k + 1]] = _Piece.bridge;
        }
      }
    }

    Widget tile(
      SafaehBranchNavItem item, {
      bool expanded = false,
      bool ancestor = false,
      int? above,
      int? below,
      int? bridgeUp,
      int? bridgeDown,
      _Piece? kindUp,
      _Piece? kindDown,
      (double, double)? slot,
    }) => _BranchTile(
      item: item,
      selected: item.id == selectedId,
      ancestor: ancestor,
      lineAboveIndent: above == null
          ? null
          : (compact ? 0 : indentStep * above),
      lineBelowIndent: below == null
          ? null
          : (compact ? 0 : indentStep * below),
      bridgeAboveIndent: bridgeUp == null
          ? null
          : (compact ? 0 : indentStep * bridgeUp),
      bridgeBelowIndent: bridgeDown == null
          ? null
          : (compact ? 0 : indentStep * bridgeDown),
      lineAboveKind: kindUp,
      lineBelowKind: kindDown,
      pathLines: highlightAncestors,
      lineSlot: slot ?? (0, 1),
      expanded: expanded,
      compact: compact,
      compactWidth: compactW,
      indent: compact ? 0 : indentStep * item.depth,
      duration: motion,
      onTap: () {
        if (haptics) HapticFeedback.lightImpact();
        item.onTap();
      },
    );

    final titleText = AnimatedSwitcher(
      duration: motion,
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          for (final old in previous) ExcludeSemantics(child: old),
          ?current,
        ],
      ),
      child: SafaehUserText(
        title,
        key: ValueKey(title),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    final header = asDrawer
        ? Padding(
            padding: EdgeInsetsDirectional.fromSTEB(compactW, 16, 20, 8),
            child: titleText,
          )
        : SizedBox(
            height: 56,
            child: Row(
              children: [
                SizedBox(
                  width: compactW,
                  child: onToggleCompact == null
                      ? null
                      : Center(
                          child: IconButton(
                            key: compact ? expandKey : collapseKey,
                            tooltip: compact ? expandTooltip : collapseTooltip,
                            onPressed: onToggleCompact,
                            icon: Icon(
                              compact
                                  ? Icons.menu
                                  : safaehChevronStart(context),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: ClipRect(
                    child: Opacity(opacity: compact ? 0 : 1, child: titleText),
                  ),
                ),
              ],
            ),
          );

    return AnimatedContainer(
      key: railKey,
      width: asDrawer ? null : (compact ? compactW : expandedW),
      duration: motion,
      curve: Curves.fastOutSlowIn,
      clipBehavior: Clip.hardEdge,
      color: cs.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(bottom: false, child: header),
          const SizedBox(height: 8),
          Expanded(
            child: _PathClock(
              path: [
                if (ancestors.isNotEmpty)
                  for (
                    var i = ancestors.reduce((a, b) => a < b ? a : b);
                    i <= activeIndex;
                    i++
                  )
                    items[i].id,
              ],
              child: _BranchRows(
                duration: motion,
                entries: [
                  for (var i = 0; i < items.length; i++)
                    (
                      id: items[i].id,
                      child: tile(
                        items[i],
                        expanded: i == expandedParent,
                        ancestor: ancestors.contains(i),
                        above: lineAbove[i],
                        below: lineBelow[i],
                        bridgeUp: bridgeAbove[i],
                        bridgeDown: bridgeBelow[i],
                        kindUp: aboveKind[i],
                        kindDown: belowKind[i],
                        slot: lineSlot[i],
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            left: false,
            right: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in pinnedItems) tile(item),
                if (footer != null)
                  SizedBox(
                    height: 24,
                    child: compact ? null : Center(child: footer),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({
    required this.item,
    required this.selected,
    this.ancestor = false,
    this.lineAboveIndent,
    this.lineBelowIndent,
    this.bridgeAboveIndent,
    this.bridgeBelowIndent,
    this.lineAboveKind,
    this.lineBelowKind,
    this.pathLines = false,
    this.lineSlot = (0, 1),
    required this.expanded,
    required this.compact,
    required this.compactWidth,
    required this.indent,
    required this.duration,
    required this.onTap,
  });

  final SafaehBranchNavItem item;
  final bool selected;

  /// The selected row branches from this one.
  final bool ancestor;

  /// The path line entering from the row above / leaving to the row below,
  /// drawn under the icon of a row at this indent. Null draws none.
  final double? lineAboveIndent;
  final double? lineBelowIndent;

  /// Set when the path row above / below sits right next to this one: the
  /// piece is a bridge from this indent to the rail's end edge, filling the
  /// gap and the rounded corners between the two pills.
  final double? bridgeAboveIndent;
  final double? bridgeBelowIndent;

  /// What this row's piece of the path is, coming in and going on.
  final _Piece? lineAboveKind;
  final _Piece? lineBelowKind;

  /// Whether this rail draws path lines at all (keeps the line's state, so
  /// it can retract when the path moves away).
  final bool pathLines;

  /// When this row's piece of the line draws, as a share of the whole draw.
  final (double, double) lineSlot;
  final bool expanded;
  final bool compact;
  final double compactWidth;
  final double indent;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final foreground = selected
        ? cs.surfaceContainerLow
        : ancestor
        ? cs.onSecondaryContainer
        : cs.onSurface;
    final background = selected
        ? cs.onSurface
        : ancestor
        ? cs.secondaryContainer
        : Colors.transparent;
    final mark =
        item.leading ??
        Icon(selected ? (item.selectedIcon ?? item.icon) : item.icon);
    return Tooltip(
      message: item.label,
      child: Semantics(
        selected: selected,
        expanded: expanded ? true : null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep the compact icon column while the rail animates open.
            final effectiveIndent = (constraints.maxWidth - compactWidth).clamp(
              0.0,
              indent,
            );
            // The line sits under the icon column of the row it comes from:
            // outer padding 8, inner padding 8, then a 40 wide icon box.
            final tile = Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                8 + effectiveIndent,
                2,
                8,
                2,
              ),
              child: Material(
                animationDuration: item.animateSelection
                    ? duration
                    : Duration.zero,
                color: background,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  key: item.id,
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: IconTheme(
                                data: IconThemeData(color: foreground),
                                child: mark,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRect(
                              child: Opacity(
                                opacity: compact ? 0 : 1,
                                child: ExcludeSemantics(
                                  excluding: compact,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SafaehUserText(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: foreground,
                                                fontWeight: expanded
                                                    ? FontWeight.w700
                                                    : null,
                                              ),
                                        ),
                                        if (item.subtitle != null)
                                          SafaehUserText(
                                            item.subtitle!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(color: foreground),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (expanded &&
                              !compact &&
                              constraints.maxWidth >=
                                  compactWidth + effectiveIndent + 18)
                            Icon(
                              Icons.expand_more,
                              size: 18,
                              color: foreground,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
            if (!pathLines) return tile;
            double eff(double indent) =>
                (constraints.maxWidth - compactWidth).clamp(0.0, indent);
            final own = 8 + effectiveIndent;
            final end = constraints.maxWidth - 8;
            // A bridge spans the pills' shared width (outer padding 8 each
            // side). The spine runs down the leading edge of the row it
            // comes from, 16 wide.
            _PieceShape? shape(_Piece? kind, double? line, double? bridge) {
              if (kind == null) return null;
              if (kind == _Piece.bridge && bridge != null) {
                return _PieceShape(kind, 8 + eff(bridge), end, own);
              }
              if (line == null) return null;
              final start = 8 + eff(line);
              return _PieceShape(kind, start, start + 16, own);
            }

            return Stack(
              // The spine's rounded joins reach a few pixels into the rows
              // above and below.
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _PathLine(
                    aboveIndent: lineAboveIndent,
                    belowIndent: lineBelowIndent,
                    aboveShape: shape(
                      lineAboveKind,
                      lineAboveIndent,
                      bridgeAboveIndent,
                    ),
                    belowShape: shape(
                      lineBelowKind,
                      lineBelowIndent,
                      bridgeBelowIndent,
                    ),
                    slot: lineSlot,
                    duration: duration,
                    color: cs.secondaryContainer,
                  ),
                ),
                tile,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One row's piece of the path line: from the row's top edge to its middle
/// (the line coming in) and from the middle to its bottom edge (going on),
/// through the gaps between rows so the highlighted shapes join.
///
/// It draws top down within [slot] of the whole draw, so across rows the
/// line flows from the parent into the selection, and retracts bottom up
/// when the path moves away. The whole draw takes one and a half times the
/// rail's motion; reduced motion makes it instant.
class _PathLine extends StatefulWidget {
  const _PathLine({
    required this.aboveIndent,
    required this.belowIndent,
    required this.aboveShape,
    required this.belowShape,
    required this.slot,
    required this.duration,
    required this.color,
  });

  final double? aboveIndent;
  final double? belowIndent;

  final _PieceShape? aboveShape;
  final _PieceShape? belowShape;
  final (double, double) slot;
  final Duration duration;
  final Color color;

  @override
  State<_PathLine> createState() => _PathLineState();
}

class _PathLineState extends State<_PathLine> with TickerProviderStateMixin {
  // The incoming (top half) and outgoing (bottom half) pieces animate on
  // their own, so a piece that stays put never redraws when the path moves.
  late final _above = AnimationController(vsync: this);
  late final _below = AnimationController(vsync: this);
  Timer? _aboveTimer;
  Timer? _belowTimer;

  // What is drawn: kept while a piece that went away retracts.
  late _PieceShape? _aboveShape = widget.aboveShape;
  late _PieceShape? _belowShape = widget.belowShape;
  late (double, double) _slot = widget.slot;

  Duration get _total => widget.duration * 1.5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_above.status == AnimationStatus.dismissed &&
        _below.status == AnimationStatus.dismissed &&
        !_started) {
      _started = true;
      _show(_above, widget.aboveIndent != null, top: true);
      _show(_below, widget.belowIndent != null, top: false);
    }
  }

  bool _started = false;

  /// Runs [c] to shown or hidden at the moment the shared path clock says
  /// this piece's turn comes: drawing top down, retracting bottom up. A row
  /// rebuilt late (the list shifted) catches up at once.
  void _show(AnimationController c, bool show, {required bool top}) {
    final total = _total;
    final (begin, end) = _slot;
    final mid = (begin + end) / 2;
    final piece = total * ((end - begin) / 2);
    if (total == Duration.zero || piece == Duration.zero) {
      c.value = show ? 1 : 0;
      return;
    }
    c.duration = piece;
    final turn = show ? (top ? begin : mid) : (1 - (top ? mid : end));
    final elapsed = _PathClock.elapsed(context);
    final wait = total * turn - elapsed;
    void run() {
      if (!mounted) return;
      show ? c.forward() : c.reverse();
    }

    final timer = top ? _aboveTimer : _belowTimer;
    timer?.cancel();
    if (top) {
      _aboveTimer = null;
    } else {
      _belowTimer = null;
    }
    if (wait <= Duration.zero) {
      // Late: jump to where the draw is by now, then finish.
      final late = (-wait).inMicroseconds / piece.inMicroseconds;
      final target = show ? late.clamp(0.0, 1.0) : 1 - late.clamp(0.0, 1.0);
      if (show ? target > c.value : target < c.value) c.value = target;
      run();
      return;
    }
    final t = Timer(wait, run);
    if (top) {
      _aboveTimer = t;
    } else {
      _belowTimer = t;
    }
  }

  @override
  void didUpdateWidget(_PathLine old) {
    super.didUpdateWidget(old);
    // Positions follow the rail's width morph; a retracting piece keeps its
    // last place.
    if (widget.aboveIndent != null) _aboveShape = widget.aboveShape;
    if (widget.belowIndent != null) _belowShape = widget.belowShape;
    if (widget.aboveIndent != null || widget.belowIndent != null) {
      _slot = widget.slot;
    }
    // A piece that moved to another row's column keeps its progress and
    // only slides over, under the pills.
    if ((old.aboveIndent == null) != (widget.aboveIndent == null)) {
      _show(_above, widget.aboveIndent != null, top: true);
    }
    if ((old.belowIndent == null) != (widget.belowIndent == null)) {
      _show(_below, widget.belowIndent != null, top: false);
    }
  }

  @override
  void dispose() {
    _aboveTimer?.cancel();
    _belowTimer?.cancel();
    _above.dispose();
    _below.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    key: ValueKey(
      'safaeh_branch_line_${widget.aboveIndent != null}_'
      '${widget.belowIndent != null}',
    ),
    painter: _PathLinePainter(
      above: CurvedAnimation(parent: _above, curve: Curves.easeOut),
      below: CurvedAnimation(parent: _below, curve: Curves.easeIn),
      aboveShape: _aboveShape,
      belowShape: _belowShape,
      color: widget.color,
      rtl: Directionality.of(context) == TextDirection.rtl,
    ),
  );
}

/// When the highlighted path last changed, so every row's piece of the line
/// keeps time with the others, even a row the list rebuilt midway.
class _PathClock extends StatefulWidget {
  const _PathClock({required this.path, required this.child});

  final List<Key> path;
  final Widget child;

  static Duration elapsed(BuildContext context) {
    final since = context
        .getInheritedWidgetOfExactType<_PathClockScope>()
        ?.state
        ._changedAt;
    return since == null ? Duration.zero : _now() - since;
  }

  // The frame clock: it follows animation time (and test time), unlike the
  // wall clock.
  static Duration _now() =>
      SchedulerBinding.instance.currentSystemFrameTimeStamp;

  @override
  State<_PathClock> createState() => _PathClockState();
}

class _PathClockState extends State<_PathClock> {
  Duration? _changedAt;

  @override
  void initState() {
    super.initState();
    _changedAt = _PathClock._now();
  }

  @override
  void didUpdateWidget(_PathClock old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.path, widget.path)) _changedAt = _PathClock._now();
  }

  @override
  Widget build(BuildContext context) =>
      _PathClockScope(state: this, child: widget.child);
}

class _PathClockScope extends InheritedWidget {
  const _PathClockScope({required this.state, required super.child});

  final _PathClockState state;

  @override
  bool updateShouldNotify(_PathClockScope old) => false;
}

/// What a row's piece of the path is.
enum _Piece {
  /// Between two path rows right next to each other: fills the gap and the
  /// corners across their shared width.
  bridge,

  /// Leaves a path row for one further down.
  source,

  /// Passes a row that isn't on the path.
  through,

  /// Arrives at a path row from one further up.
  target,
}

@immutable
class _PieceShape {
  const _PieceShape(this.kind, this.from, this.to, this.own);

  final _Piece kind;

  /// Start-relative horizontal extent: the bridge's width or the spine's.
  final double from;
  final double to;

  /// Where this row's own pill starts.
  final double own;

  @override
  bool operator ==(Object other) =>
      other is _PieceShape &&
      other.kind == kind &&
      other.from == from &&
      other.to == to &&
      other.own == own;

  @override
  int get hashCode => Object.hash(kind, from, to, own);
}

class _PathLinePainter extends CustomPainter {
  _PathLinePainter({
    required this.above,
    required this.below,
    required this.aboveShape,
    required this.belowShape,
    required this.color,
    required this.rtl,
  }) : super(repaint: Listenable.merge([above, below]));

  /// The row's padding around its pill, the pill's corner radius and the
  /// spine's rounded joins.
  static const inset = 2.0;
  static const radius = 16.0;
  static const join = 8.0;

  final Animation<double> above;
  final Animation<double> below;
  final _PieceShape? aboveShape;
  final _PieceShape? belowShape;
  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final mid = h / 2;
    final paint = Paint()..color = color;
    if (rtl) {
      canvas
        ..save()
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }

    // Both pieces grow downwards: in from the top edge, out from the middle.
    final a = aboveShape;
    final t = above.value;
    if (a != null && t > 0) {
      if (a.kind == _Piece.target) {
        // An indented child (the expanded rail): the spine runs down its
        // whole leading side, filling both of its corners. Otherwise it
        // joins at the child's top.
        final indented = a.own > a.from + 0.5;
        final reach = (indented ? h - inset : mid) * t;
        final bottom = indented
            ? Radius.circular(radius.clamp(0, reach))
            : Radius.zero;
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(a.from, 0, a.to, reach, bottomLeft: bottom),
          paint,
        );
        if (indented && reach > inset) {
          canvas.drawRect(
            Rect.fromLTRB(a.to - 1, inset, a.own + radius, reach),
            paint,
          );
        }
        if (reach > inset) {
          // The rounded inner corner between spine and pill top.
          final x = a.to > a.own ? a.to : a.own;
          canvas.drawPath(
            Path()
              ..moveTo(x, inset - join)
              ..arcToPoint(
                Offset(x + join, inset),
                radius: const Radius.circular(join),
                clockwise: false,
              )
              ..lineTo(x, inset)
              ..close(),
            paint,
          );
        }
      } else {
        canvas.drawRect(Rect.fromLTRB(a.from, 0, a.to, mid * t), paint);
      }
    }

    final b = belowShape;
    final u = below.value;
    if (b != null && u > 0) {
      final reach = mid + (h - mid) * u;
      canvas.drawRect(Rect.fromLTRB(b.from, mid, b.to, reach), paint);
      if (b.kind == _Piece.source && reach >= h - inset) {
        // The rounded inner corner between the parent's pill and the spine.
        final y = h - inset;
        canvas.drawPath(
          Path()
            ..moveTo(b.to + join, y)
            ..arcToPoint(
              Offset(b.to, y + join),
              radius: const Radius.circular(join),
              clockwise: false,
            )
            ..lineTo(b.to, y)
            ..close(),
          paint,
        );
      }
    }
    if (rtl) canvas.restore();
  }

  @override
  bool shouldRepaint(_PathLinePainter old) =>
      old.aboveShape != aboveShape ||
      old.belowShape != belowShape ||
      old.color != color ||
      old.rtl != rtl ||
      old.above != above ||
      old.below != below;
}

typedef _BranchEntry = ({Key id, Widget child});

/// Reconciles rows by id without replacing the rail, header or scroll view.
class _BranchRows extends StatefulWidget {
  const _BranchRows({required this.entries, required this.duration});

  final List<_BranchEntry> entries;
  final Duration duration;

  @override
  State<_BranchRows> createState() => _BranchRowsState();
}

class _BranchRowsState extends State<_BranchRows> {
  final _listKey = GlobalKey<AnimatedListState>();
  late final List<_BranchEntry> _entries = List.of(widget.entries);

  void _remove(int index) {
    final removed = _entries.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _transition(
        animation,
        ExcludeFocus(
          child: IgnorePointer(child: ExcludeSemantics(child: removed.child)),
        ),
      ),
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(covariant _BranchRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIds = widget.entries.map((e) => e.id).toSet();
    for (var i = _entries.length - 1; i >= 0; i--) {
      if (!nextIds.contains(_entries[i].id)) _remove(i);
    }
    for (var i = 0; i < widget.entries.length; i++) {
      final next = widget.entries[i];
      if (i < _entries.length && _entries[i].id == next.id) {
        _entries[i] = next;
        continue;
      }
      final previous = _entries.indexWhere((e) => e.id == next.id);
      if (previous >= 0) _remove(previous);
      _entries.insert(i, next);
      _listKey.currentState!.insertItem(i, duration: widget.duration);
    }
  }

  Widget _transition(Animation<double> animation, Widget child) {
    final progress = animation.drive(CurveTween(curve: Curves.easeInOutCubic));
    // A SizeTransition that stops clipping once the row is fully in, so the
    // path's rounded joins can reach into the next row. The structure stays
    // the same either way, so the row keeps its state.
    return AnimatedBuilder(
      animation: progress,
      child: FadeTransition(opacity: progress, child: child),
      builder: (context, faded) => ClipRect(
        clipBehavior: animation.isCompleted ? Clip.none : Clip.hardEdge,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: progress.value.clamp(0.0, 1.0),
          child: faded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedList(
    key: _listKey,
    primary: false,
    padding: EdgeInsets.zero,
    initialItemCount: _entries.length,
    itemBuilder: (context, index, animation) => _transition(
      animation,
      KeyedSubtree(
        key: ValueKey(_entries[index].id),
        child: _entries[index].child,
      ),
    ),
  );
}
