import 'package:flutter/material.dart';

import 'theme.dart';

/// Bordered ink row for sheet action / picker lists.
///
/// Defaults use [ColorScheme] only. Hosts that need a brand accent can pass
/// [selectedFill] / [selectedBorder].
class SafaehOptionTile extends StatelessWidget {
  const SafaehOptionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.destructive = false,
    this.enabled = true,
    this.selectedFill,
    this.selectedBorder,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool destructive;
  final bool enabled;
  final Color? selectedFill;
  final Color? selectedBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onTapEnabled = enabled ? onTap : null;
    final onSelected = selectedFill == null
        ? cs.onPrimaryContainer
        : cs.onSurface;
    final titleColor = destructive
        ? cs.error
        : (enabled
              ? (selected ? onSelected : cs.onSurface)
              : cs.onSurface.withValues(alpha: 0.38));
    final subtitleColor = destructive
        ? cs.error.withValues(alpha: 0.85)
        : (selected ? onSelected : cs.onSurfaceVariant);
    final fill = selected
        ? (selectedFill ?? cs.primaryContainer)
        : cs.surfaceContainerLow;
    final border = selected ? (selectedBorder ?? cs.primary) : cs.outline;
    final radius = BorderRadius.circular(SafaehTheme.of(context).radius);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: fill,
        borderRadius: radius,
        child: InkWell(
          onTap: onTapEnabled,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: DefaultTextStyle.merge(
                style:
                    (theme.textTheme.bodyLarge ?? theme.textTheme.bodyMedium)
                        ?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ) ??
                    TextStyle(color: titleColor, fontWeight: FontWeight.w600),
                child: IconTheme.merge(
                  data: IconThemeData(color: titleColor),
                  child: Row(
                    children: [
                      if (leading != null) ...[
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(child: leading!),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            title,
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              DefaultTextStyle.merge(
                                style:
                                    (theme.textTheme.bodySmall ??
                                            theme.textTheme.bodyMedium)
                                        ?.copyWith(color: subtitleColor) ??
                                    TextStyle(color: subtitleColor),
                                child: subtitle!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 10),
                        trailing!,
                      ],
                    ],
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
