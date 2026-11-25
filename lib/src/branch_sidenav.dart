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

/// A navigation rail whose rows branch with the current context, ported from
/// Hisab's shell sidenav.
///
/// - The rail is one widget for the whole app: changing [items] reconciles the
///   rows by [SafaehBranchNavItem.id]. Rows that stay keep their place; new
///   rows grow and fade in, gone rows shrink and fade out.
/// - [title] crossfades when it changes (the app name, then the open list).
/// - Rows indent by [SafaehBranchNavItem.depth]. When the selected row is two
///   levels deep, its parent turns bold and shows an expand arrow.
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

    Widget tile(SafaehBranchNavItem item, {bool expanded = false}) =>
        _BranchTile(
          item: item,
          selected: item.id == selectedId,
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
            child: _BranchRows(
              duration: motion,
              entries: [
                for (var i = 0; i < items.length; i++)
                  (
                    id: items[i].id,
                    child: tile(items[i], expanded: i == expandedParent),
                  ),
              ],
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
    required this.expanded,
    required this.compact,
    required this.compactWidth,
    required this.indent,
    required this.duration,
    required this.onTap,
  });

  final SafaehBranchNavItem item;
  final bool selected;
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
    final foreground = selected ? cs.surfaceContainerLow : cs.onSurface;
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
            return Padding(
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
                color: selected ? cs.onSurface : Colors.transparent,
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
          },
        ),
      ),
    );
  }
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
    return SizeTransition(
      sizeFactor: progress,
      alignment: Alignment.topCenter,
      child: FadeTransition(opacity: progress, child: child),
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
