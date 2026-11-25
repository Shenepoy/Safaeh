import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// One row in an anchored choice or toggle menu.
class SafaehDropdownOption<T> {
  const SafaehDropdownOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// A compact chip that opens an anchored menu below the trigger.
///
/// The menu is never narrower than the rendered trigger. Hosts can provide
/// [selectedFill], [selectedBorder], and [selectedForeground] to keep the
/// selected row aligned with their own color tokens. [labelBuilder] is useful
/// for hosts that need bidi-aware or otherwise specialized text widgets.
class SafaehAnchoredDropdownChip<T> extends _AnchoredDropdownChip<T> {
  const SafaehAnchoredDropdownChip({
    super.key,
    required super.icon,
    required super.label,
    required super.options,
    required this.selected,
    required this.onSelected,
    super.active,
    super.expand,
    super.menuWidth,
    super.selectedFill,
    super.selectedBorder,
    super.selectedForeground,
    super.labelBuilder,
    super.iconOnly,
  });

  /// Keeps a longer list of choices in a compact, scrollable anchored menu.
  /// The height is also limited by the space available on screen.
  const SafaehAnchoredDropdownChip.scrollable({
    super.key,
    required super.icon,
    required super.label,
    required super.options,
    required this.selected,
    required this.onSelected,
    double maxHeight = 240,
    super.active,
    super.expand,
    super.menuWidth,
    super.selectedFill,
    super.selectedBorder,
    super.selectedForeground,
    super.labelBuilder,
    super.iconOnly,
  }) : super(menuMaxHeight: maxHeight);

  final T selected;
  final ValueChanged<T> onSelected;

  @override
  bool _isSelected(T value) => value == selected;

  @override
  void _activate(T value) => onSelected(value);

  @override
  State<SafaehAnchoredDropdownChip<T>> createState() =>
      _AnchoredDropdownChipState<T, SafaehAnchoredDropdownChip<T>>();
}

/// An anchored menu for independent checkbox choices.
///
/// The host owns [selectedValues] and updates them in [onToggled]. The menu
/// stays open after each change so several rows can be toggled in one visit.
class SafaehAnchoredToggleDropdownChip<T> extends _AnchoredDropdownChip<T> {
  const SafaehAnchoredToggleDropdownChip({
    super.key,
    required super.icon,
    required super.label,
    required super.options,
    required this.selectedValues,
    required this.onToggled,
    double maxHeight = 240,
    super.active,
    super.expand,
    super.menuWidth,
    super.selectedFill,
    super.selectedBorder,
    super.selectedForeground,
    super.labelBuilder,
    super.iconOnly,
  }) : super(menuMaxHeight: maxHeight);

  final Set<T> selectedValues;
  final void Function(T value, bool checked) onToggled;

  @override
  bool get _toggleRows => true;

  @override
  bool _isSelected(T value) => selectedValues.contains(value);

  @override
  void _activate(T value) => onToggled(value, !_isSelected(value));

  @override
  State<SafaehAnchoredToggleDropdownChip<T>> createState() =>
      _AnchoredDropdownChipState<T, SafaehAnchoredToggleDropdownChip<T>>();
}

abstract class _AnchoredDropdownChip<T> extends StatefulWidget {
  const _AnchoredDropdownChip({
    super.key,
    required this.icon,
    required this.label,
    required this.options,
    this.menuMaxHeight,
    this.active = false,
    this.expand = false,
    this.menuWidth,
    this.selectedFill,
    this.selectedBorder,
    this.selectedForeground,
    this.labelBuilder,
    this.iconOnly = false,
  }) : assert(menuWidth == null || menuWidth > 0),
       assert(
         menuMaxHeight == null ||
             (menuMaxHeight > 0 && menuMaxHeight < double.infinity),
       );

  final IconData icon;
  final String label;
  final List<SafaehDropdownOption<T>> options;

  /// When true, the trigger uses the emphasized selected-filter look.
  final bool active;

  /// When true, the trigger fills the parent width.
  final bool expand;

  /// Overrides the automatic trigger-width menu sizing when supplied.
  final double? menuWidth;

  /// Additional height limit for the scrollable variant, in logical pixels.
  final double? menuMaxHeight;

  /// Optional host color for the selected menu row.
  final Color? selectedFill;

  /// Optional host border color for the selected menu row.
  final Color? selectedBorder;

  /// Optional host text color for the selected menu row.
  final Color? selectedForeground;

  /// Optional host bidi / text wrapper for labels.
  final SafaehLabelBuilder? labelBuilder;

  /// When true, the trigger is only [icon]. [label] stays the tooltip.
  /// Menu rows still show their labels.
  final bool iconOnly;

  bool get _toggleRows => false;
  bool _isSelected(T value);
  void _activate(T value);
}

class _AnchoredDropdownChipState<T, W extends _AnchoredDropdownChip<T>>
    extends State<W> {
  final _anchorKey = GlobalKey();
  double? _anchorWidth;

  @override
  void initState() {
    super.initState();
    _scheduleAnchorMeasurement();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.menuWidth == null) _scheduleAnchorMeasurement();
  }

  void _scheduleAnchorMeasurement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measureAnchor();
    });
  }

  void _measureAnchor() {
    if (widget.menuWidth != null) return;
    final renderObject = _anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final width = renderObject.size.width;
    if (width <= 0 || width == _anchorWidth) return;
    setState(() => _anchorWidth = width);
  }

  Widget _label(String data, TextStyle? style) {
    return widget.labelBuilder?.call(data, style) ?? Text(data, style: style);
  }

  Widget _menuItem(SafaehDropdownOption<T> option, ThemeData theme) {
    final cs = theme.colorScheme;
    final selected = widget._isSelected(option.value);
    final selectedForeground =
        widget.selectedForeground ??
        (widget.selectedFill == null ? cs.onPrimaryContainer : cs.onSurface);
    final style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(
        selected
            ? (widget.selectedFill ?? cs.primaryContainer)
            : cs.surfaceContainerLow,
      ),
      side: WidgetStatePropertyAll(
        BorderSide(
          color: selected
              ? (widget.selectedBorder ?? cs.primary)
              : cs.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
    final label = _label(
      option.label,
      theme.textTheme.bodyMedium?.copyWith(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        color: selected ? selectedForeground : cs.onSurface,
      ),
    );
    final icon = option.icon == null
        ? null
        : Icon(
            option.icon,
            size: 20,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          );

    if (widget._toggleRows) {
      return CheckboxMenuButton(
        value: selected,
        onChanged: (_) => widget._activate(option.value),
        closeOnActivate: false,
        trailingIcon: icon,
        style: style,
        child: label,
      );
    }
    return MenuItemButton(
      leadingIcon: icon,
      style: style,
      onPressed: () => widget._activate(option.value),
      child: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return MenuAnchor(
      // Let a tap reach another chip so it can open in the same gesture.
      consumeOutsideTap: false,
      // The menu has an explicit minimum width and should honor it instead of
      // being unconstrained to the widest intrinsic child.
      crossAxisUnconstrained: false,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
        elevation: const WidgetStatePropertyAll(8),
        shadowColor: WidgetStatePropertyAll(cs.shadow.withValues(alpha: 0.28)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
        minimumSize: WidgetStateProperty.resolveWith<Size?>((_) {
          final width = widget.menuWidth ?? _anchorWidth;
          return width == null ? null : Size(width, 0);
        }),
        maximumSize: WidgetStateProperty.resolveWith<Size?>((_) {
          final width = widget.menuWidth ?? _anchorWidth ?? 0;
          final viewportLimit = MediaQuery.sizeOf(context).height * 0.45;
          return Size(
            math.max(280.0, width),
            math.min(widget.menuMaxHeight ?? viewportLimit, viewportLimit),
          );
        }),
      ),
      alignmentOffset: const Offset(0, 8),
      builder: (context, controller, _) {
        final bg = widget.active
            ? cs.primaryContainer
            : cs.surfaceContainerHighest.withValues(alpha: 0.65);
        final fg = widget.active ? cs.onPrimaryContainer : cs.onSurface;
        final iconColor = widget.iconOnly
            ? (widget.active ? cs.primary : cs.onSurface)
            : widget.active
            ? cs.onPrimaryContainer
            : cs.onSurfaceVariant;
        void toggle() {
          _measureAnchor();
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        }

        if (widget.iconOnly) {
          return Tooltip(
            message: widget.label,
            child: Material(
              key: _anchorKey,
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: toggle,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(widget.icon, size: 24, color: iconColor),
                ),
              ),
            ),
          );
        }
        final labelStyle = theme.textTheme.labelLarge?.copyWith(
          color: fg,
          fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
        );
        final labelText = _label(widget.label, labelStyle);

        return Material(
          key: _anchorKey,
          color: bg,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: toggle,
            child: Container(
              width: widget.expand ? double.infinity : null,
              padding: EdgeInsetsDirectional.only(
                start: widget.expand ? 10 : 14,
                end: widget.expand ? 6 : 10,
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: widget.active
                      ? cs.primary.withValues(alpha: 0.35)
                      : cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: iconColor),
                  SizedBox(width: widget.expand ? 6 : 8),
                  if (widget.expand)
                    Expanded(child: labelText)
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 112),
                      child: labelText,
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    controller.isOpen
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: iconColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      menuChildren: [
        for (var i = 0; i < widget.options.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _menuItem(widget.options[i], theme),
        ],
      ],
    );
  }
}
