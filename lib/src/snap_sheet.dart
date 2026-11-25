import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// Controls a [SafaehSnapSheet] from the host.
class SafaehSnapSheetController {
  _SafaehSnapSheetState? _state;

  /// Index into [SafaehSnapSheet.snapFractions] the sheet last settled on.
  int get snapIndex => _state?._index ?? 0;

  /// Animates to the snap point at [index]. Does nothing when not attached,
  /// or on a wide layout where the sheet is a fixed side panel.
  Future<void> snapTo(int index) async => _state?._snapTo(index);
}

/// A non-modal bottom sheet that sits over live content, such as a map.
///
/// On a phone the sheet drags between [snapFractions] (fractions of the
/// available height, ascending). Scrolling content inside it hands off to the
/// drag at the top edge. The content behind the sheet is the host's [child]
/// and is not rebuilt while the sheet moves.
///
/// At [SafaehThemeData.tabletBreakpoint] and wider the sheet becomes a fixed
/// side panel of [sidePanelWidth] at the start edge. Returning to the phone
/// layout restores the last settled snap point.
class SafaehSnapSheet extends StatefulWidget {
  const SafaehSnapSheet({
    super.key,
    required this.child,
    required this.sheetBuilder,
    this.snapFractions = const [0.18, 0.5, 0.92],
    this.initialSnap = 1,
    this.controller,
    this.onSnapChanged,
    this.sidePanelWidth = 380,
    this.showHandle = true,
    this.handleLabel,
    this.backgroundColor,
    this.radius,
  }) : assert(snapFractions.length > 0),
       assert(initialSnap >= 0 && initialSnap < snapFractions.length);

  /// The live content behind the sheet, for example a map and its chrome.
  final Widget child;

  /// Builds the sheet body. Pass [scrollController] to the primary scrollable
  /// so drag and scroll hand off. On a side panel it is a plain controller.
  final Widget Function(BuildContext context, ScrollController scrollController)
  sheetBuilder;

  /// Ascending fractions of the height, each in (0, 1].
  final List<double> snapFractions;
  final int initialSnap;
  final SafaehSnapSheetController? controller;

  /// Called after a drag or [SafaehSnapSheetController.snapTo] settles.
  final ValueChanged<int>? onSnapChanged;
  final double sidePanelWidth;
  final bool showHandle;

  /// Localized semantics label for the drag handle.
  final String? handleLabel;
  final Color? backgroundColor;
  final double? radius;

  @override
  State<SafaehSnapSheet> createState() => _SafaehSnapSheetState();
}

class _SafaehSnapSheetState extends State<SafaehSnapSheet> {
  late final DraggableScrollableController _drag =
      DraggableScrollableController();
  late int _index = widget.initialSnap;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(SafaehSnapSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _index = _index.clamp(0, widget.snapFractions.length - 1);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _drag.dispose();
    super.dispose();
  }

  Future<void> _snapTo(int index) async {
    if (!_drag.isAttached) return;
    final target =
        widget.snapFractions[index.clamp(0, widget.snapFractions.length - 1)];
    final tokens = SafaehTheme.of(context);
    final duration = safaehResolvedMotion(context, tokens.sheetRoll);
    if (duration == Duration.zero) {
      _drag.jumpTo(target);
    } else {
      await _drag.animateTo(
        target,
        duration: duration,
        curve: tokens.sheetRollEnter,
      );
    }
    if (mounted && _drag.isAttached) _settle(_drag.size);
  }

  void _dragBy(double deltaDy, double height) {
    if (!_drag.isAttached || height <= 0) return;
    final min = widget.snapFractions.first;
    final max = widget.snapFractions.last;
    _drag.jumpTo((_drag.size - deltaDy / height).clamp(min, max));
  }

  void _snapNearest() {
    if (!_drag.isAttached) return;
    var nearest = 0;
    var best = double.infinity;
    for (var i = 0; i < widget.snapFractions.length; i++) {
      final d = (widget.snapFractions[i] - _drag.size).abs();
      if (d < best) {
        best = d;
        nearest = i;
      }
    }
    _snapTo(nearest);
  }

  /// Tap or Enter on the handle: next snap point, wrapping to the first.
  void _cycle() => _snapTo((_index + 1) % widget.snapFractions.length);

  /// Arrow keys on the handle: [direction] is +1 for taller, -1 for shorter.
  void _step(int direction) => _snapTo(_index + direction);

  void _settle(double extent) {
    var nearest = 0;
    var best = double.infinity;
    for (var i = 0; i < widget.snapFractions.length; i++) {
      final d = (widget.snapFractions[i] - extent).abs();
      if (d < best) {
        best = d;
        nearest = i;
      }
    }
    if (nearest != _index) {
      _index = nearest;
      widget.onSnapChanged?.call(nearest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SafaehTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final radius = widget.radius ?? tokens.radius + 8;
    final background = widget.backgroundColor ?? scheme.surface;
    final wide = MediaQuery.sizeOf(context).width >= tokens.tabletBreakpoint;

    if (wide) {
      return Stack(
        children: [
          Positioned.fill(child: widget.child),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: widget.sidePanelWidth,
            child: Material(
              color: background,
              elevation: 3,
              child: SafeArea(child: _PanelBody(builder: widget.sheetBuilder)),
            ),
          ),
        ],
      );
    }

    final fractions = widget.snapFractions;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned.fill(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              if (!n.context.mounted) return false;
              // Settle detection: update only when the extent is at a snap.
              for (final f in fractions) {
                if ((n.extent - f).abs() < 0.002) {
                  _settle(n.extent);
                  break;
                }
              }
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _drag,
              initialChildSize: fractions[_index],
              minChildSize: fractions.first,
              maxChildSize: fractions.last,
              snap: true,
              snapSizes: fractions.length > 2
                  ? fractions.sublist(1, fractions.length - 1)
                  : null,
              builder: (context, scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.16),
                        blurRadius: 14,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radius),
                    ),
                    child: Column(
                      children: [
                        if (widget.showHandle)
                          _SnapHandle(
                            label: widget.handleLabel,
                            color: scheme.outlineVariant,
                            onDrag: _dragBy,
                            onDragEnd: _snapNearest,
                            onCycle: _cycle,
                            onStep: _step,
                          ),
                        Expanded(
                          // Mouse and trackpad can drag the content too, so
                          // desktop browsers at phone width are usable.
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                ...ScrollConfiguration.of(context).dragDevices,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.trackpad,
                              },
                            ),
                            child: widget.sheetBuilder(
                              context,
                              scrollController,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelBody extends StatefulWidget {
  const _PanelBody({required this.builder});

  final Widget Function(BuildContext, ScrollController) builder;

  @override
  State<_PanelBody> createState() => _PanelBodyState();
}

class _PanelBodyState extends State<_PanelBody> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _scroll);
}

class _SnapHandle extends StatefulWidget {
  const _SnapHandle({
    required this.label,
    required this.color,
    required this.onDrag,
    required this.onDragEnd,
    required this.onCycle,
    required this.onStep,
  });

  final String? label;
  final Color color;
  final void Function(double deltaDy, double height) onDrag;
  final VoidCallback onDragEnd;
  final VoidCallback onCycle;
  final void Function(int direction) onStep;

  @override
  State<_SnapHandle> createState() => _SnapHandleState();
}

class _SnapHandleState extends State<_SnapHandle> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final onCycle = widget.onCycle;
    final onStep = widget.onStep;
    return Semantics(
      label: widget.label,
      button: true,
      onTap: onCycle,
      onIncrease: () => onStep(1),
      onDecrease: () => onStep(-1),
      child: Focus(
        // Not a tab stop: it only handles arrow keys bubbling from the handle.
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            onStep(1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            onStep(-1);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.grab,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                onCycle();
                return null;
              },
            ),
          },
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCycle,
            onVerticalDragUpdate: (d) => widget.onDrag(d.delta.dy, height),
            onVerticalDragEnd: (_) => widget.onDragEnd(),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _focused
                        ? Theme.of(context).colorScheme.primary
                        : widget.color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: _focused
                        ? [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary
                                  .withValues(alpha: 0.35),
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
