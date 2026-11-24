import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// One entry in [SafaehSectionChips].
@immutable
class SafaehSection {
  const SafaehSection({
    required this.id,
    required this.label,
    this.count,
    this.icon,
  });

  /// Stable identifier; also used as the item key.
  final String id;
  final String label;

  /// Optional item count shown after the label.
  final int? count;
  final IconData? icon;
}

/// Horizontal, scrollable chip bar for switching between user-defined
/// sections, with optional add, long-press, and reorder.
///
/// Pair with [TabController]/`SafaehTabView` or any host view that shows the
/// selected section. The host owns the section list and its persistence.
class SafaehSectionChips extends StatelessWidget {
  const SafaehSectionChips({
    super.key,
    required this.sections,
    required this.selectedId,
    required this.onSelected,
    this.onAdd,
    this.addLabel,
    this.onLongPress,
    this.onReorder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.gap = 8,
    this.height = 44,
  });

  final List<SafaehSection> sections;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  /// Shows a trailing "+" chip when set. [addLabel] is its tooltip and
  /// semantics label (localized).
  final VoidCallback? onAdd;
  final String? addLabel;

  /// For rename or delete menus.
  final ValueChanged<String>? onLongPress;

  /// Enables drag reorder. Old and new index, adjusted for removal.
  final void Function(int oldIndex, int newIndex)? onReorder;
  final EdgeInsets padding;
  final double gap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = SafaehTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final motion = safaehResolvedMotion(context, tokens.pageIndexMotion);

    Widget chip(SafaehSection s) {
      final selected = s.id == selectedId;
      final fg = selected ? scheme.onInverseSurface : scheme.onSurface;
      final bg = selected ? scheme.inverseSurface : Colors.transparent;
      final text = s.count == null ? s.label : '${s.label} · ${s.count}';
      return Semantics(
        button: true,
        selected: selected,
        label: text,
        excludeSemantics: true,
        onTap: () => onSelected(s.id),
        onLongPress: onLongPress == null ? null : () => onLongPress!(s.id),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(height / 2),
            onTap: () => onSelected(s.id),
            onLongPress: onLongPress == null ? null : () => onLongPress!(s.id),
            child: AnimatedContainer(
              duration: motion,
              curve: tokens.enterCurve,
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(
                  color: selected ? Colors.transparent : scheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (s.icon != null) ...[
                    Icon(s.icon, size: 18, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    text,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: fg, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final add = onAdd == null
        ? null
        : Tooltip(
            message: addLabel ?? '',
            child: Semantics(
              button: true,
              label: addLabel,
              excludeSemantics: true,
              onTap: onAdd,
              child: InkWell(
                borderRadius: BorderRadius.circular(height / 2),
                onTap: onAdd,
                child: Container(
                  width: height,
                  height: height,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(Icons.add, size: 20, color: scheme.onSurface),
                ),
              ),
            ),
          );

    return SizedBox(
      height: height,
      child: onReorder == null
          ? ScrollConfiguration(
              // Let a mouse or trackpad drag the bar, not only touch.
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  ...ScrollConfiguration.of(context).dragDevices,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: padding,
                itemCount: sections.length + (add == null ? 0 : 1),
                separatorBuilder: (_, _) => SizedBox(width: gap),
                itemBuilder: (context, i) =>
                    i < sections.length ? chip(sections[i]) : add!,
              ),
            )
          : ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              padding: padding,
              buildDefaultDragHandles: true,
              itemCount: sections.length,
              onReorderItem: onReorder!,
              footer: add == null
                  ? null
                  : Padding(
                      padding: EdgeInsetsDirectional.only(start: gap),
                      child: add,
                    ),
              itemBuilder: (context, i) => Padding(
                key: ValueKey(sections[i].id),
                padding: EdgeInsetsDirectional.only(end: gap),
                child: chip(sections[i]),
              ),
            ),
    );
  }
}
