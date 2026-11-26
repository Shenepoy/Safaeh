import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// Vertical connected list for ordered stops, with optional reordering.
///
/// Each stop shows a numbered marker on a connector line. [legBuilder] can add
/// a row under a stop (travel time, transit leg) that sits on the connector;
/// return null for none. The package owns layout, drag feedback and
/// semantics; the host owns stop content, order, and copy.
///
/// The list is a [ReorderableListView] with the host's keys, so only visible
/// rows are built when [shrinkWrap] is false.
class SafaehTimeline<T> extends StatelessWidget {
  const SafaehTimeline({
    super.key,
    required this.items,
    required this.itemKey,
    required this.itemBuilder,
    this.legBuilder,
    this.markerBuilder,
    this.onReorder,
    this.reorderHandleBuilder,
    this.markerSize = 28,
    this.markerColor,
    this.onMarkerColor,
    this.lineColor,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
  });

  final List<T> items;
  final Key Function(T item) itemKey;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Row shown between stop [index] and the next. Not called for the last stop.
  final Widget? Function(BuildContext context, T item, int index)? legBuilder;

  /// Replaces the numbered circle for a stop.
  final Widget Function(BuildContext context, T item, int index)? markerBuilder;

  /// Called with the old and new index (already adjusted for removal).
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Drag handle for a stop. Defaults to a grip icon. It is wrapped in the
  /// reorder start listener. Return [SizedBox.shrink] to hide the handle.
  final Widget Function(BuildContext context, T item, int index)?
  reorderHandleBuilder;
  final double markerSize;
  final Color? markerColor;
  final Color? onMarkerColor;
  final Color? lineColor;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = SafaehTheme.of(context);
    final marker = markerColor ?? scheme.primary;
    final onMarker = onMarkerColor ?? scheme.onPrimary;
    final line = lineColor ?? scheme.outlineVariant;
    final reorderable = onReorder != null;

    Widget row(BuildContext context, int index) {
      final item = items[index];
      final isLast = index == items.length - 1;
      final leg = isLast ? null : legBuilder?.call(context, item, index);
      Widget markerWidget =
          markerBuilder?.call(context, item, index) ??
          Container(
            width: markerSize,
            height: markerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: marker, shape: BoxShape.circle),
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: onMarker, fontWeight: FontWeight.w600),
            ),
          );
      final handle = reorderable
          ? _ReorderHandle(
              index: index,
              count: items.length,
              onReorder: onReorder!,
              child:
                  reorderHandleBuilder?.call(context, item, index) ??
                  const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.drag_indicator, size: 20),
                  ),
            )
          : null;
      // The line to the next stop is drawn behind the row, from under the
      // marker to the row's bottom. (An IntrinsicHeight row would measure
      // every card twice on each layout.)
      return Semantics(
        container: true,
        child: Stack(
          children: [
            if (!isLast)
              PositionedDirectional(
                start: (markerSize + 8) / 2 - 1,
                top: markerSize,
                bottom: 0,
                child: SizedBox(width: 2, child: ColoredBox(color: line)),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: markerSize + 8,
                  child: Center(child: markerWidget),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: itemBuilder(context, item, index)),
                          ?handle,
                        ],
                      ),
                      leg ?? SizedBox(height: isLast ? 0 : tokens.radius / 2),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (!reorderable) {
      return ListView.builder(
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        controller: controller,
        itemCount: items.length,
        itemBuilder: (context, index) => KeyedSubtree(
          key: itemKey(items[index]),
          child: row(context, index),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollController: controller,
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorderItem: onReorder!,
      proxyDecorator: (child, index, animation) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = Curves.easeOut.transform(animation.value);
          return Material(
            color: Colors.transparent,
            elevation: 6 * t,
            shadowColor: scheme.shadow,
            borderRadius: BorderRadius.circular(tokens.radius),
            child: child,
          );
        },
        child: child,
      ),
      itemBuilder: (context, index) =>
          KeyedSubtree(key: itemKey(items[index]), child: row(context, index)),
    );
  }
}

/// Drag start for mouse, touch and pen, plus Alt/Ctrl + Up/Down for keyboard
/// reordering. Screen readers get move actions from [ReorderableListView].
class _ReorderHandle extends StatefulWidget {
  const _ReorderHandle({
    required this.index,
    required this.count,
    required this.onReorder,
    required this.child,
  });

  final int index;
  final int count;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget child;

  @override
  State<_ReorderHandle> createState() => _ReorderHandleState();
}

class _ReorderHandleState extends State<_ReorderHandle> {
  bool _focused = false;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    if (!keys.isAltPressed && !keys.isControlPressed) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && widget.index > 0) {
      widget.onReorder(widget.index, widget.index - 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        widget.index < widget.count - 1) {
      widget.onReorder(widget.index, widget.index + 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Focus(
        onKeyEvent: _onKey,
        onFocusChange: (v) => setState(() => _focused = v),
        child: ReorderableDragStartListener(
          index: widget.index,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focused ? scheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
