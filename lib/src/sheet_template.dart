import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// Shared content layout for action, edit, and selection sheets.
///
/// The body scrolls while [feedback] and [footer] remain reachable. Leave the
/// footer null for immediate selection. Set [scrollBody] false for a ListView
/// or other body that owns its scrolling. No buttons or dismissal are invented.
///
/// The adaptive route owns safe/keyboard insets. With showSafaeh, pass
/// contentPadding: EdgeInsets.zero to avoid adding the route padding twice.
class SafaehSheetTemplate extends StatelessWidget {
  const SafaehSheetTemplate({
    super.key,
    required this.body,
    this.header,
    this.feedback,
    this.footer,
    this.padding,
    this.scrollBody = true,
    this.scrollController,
  });

  final Widget body;
  final Widget? header, feedback, footer;
  final EdgeInsetsGeometry? padding;
  final bool scrollBody;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final style = SafaehTheme.of(context).sheetTemplate;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[header!, SizedBox(height: style.headerGap)],
        body,
      ],
    );
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: padding ?? style.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scrolling = scrollBody
                ? SingleChildScrollView(
                    controller: scrollController,
                    child: content,
                  )
                : body;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!scrollBody && header != null) ...[
                  header!,
                  SizedBox(height: style.headerGap),
                ],
                if (constraints.hasBoundedHeight)
                  Flexible(child: scrolling)
                else
                  scrolling,
                if (feedback != null) ...[
                  SizedBox(height: style.footerGap),
                  feedback!,
                ],
                if (footer != null) ...[
                  SizedBox(height: style.footerGap),
                  footer!,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Direction-aware title with replaceable leading and trailing widgets.
class SafaehSheetHeading extends StatelessWidget {
  const SafaehSheetHeading({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.style,
    this.centered = false,
    this.maxLines = 2,
  });

  final String title;
  final Widget? leading, trailing;
  final TextStyle? style;
  final bool centered;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      title,
      style: style ?? Theme.of(context).textTheme.titleLarge,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
    return Semantics(
      namesRoute: true,
      child: Row(
        mainAxisAlignment: centered
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          if (centered) Flexible(child: label) else Expanded(child: label),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Opaque reading surface; kept independent from the translucent route skin.
class SafaehSheetSurface extends StatelessWidget {
  const SafaehSheetSurface({
    super.key,
    required this.child,
    this.color,
    this.radius,
    this.borderColor,
    this.borderWidth,
  });
  final Widget child;
  final Color? color, borderColor;
  final double? radius, borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = SafaehTheme.of(context).sheetTemplate;
    return Material(
      color:
          (color ??
                  (theme.brightness == Brightness.dark
                      ? style.darkSurfaceColor ??
                            theme.colorScheme.surfaceContainerHigh
                      : style.surfaceColor ?? theme.colorScheme.surface))
              .withValues(alpha: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius ?? style.surfaceRadius),
        side: BorderSide(
          color:
              borderColor ??
              style.surfaceBorderColor ??
              theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: borderWidth ?? style.surfaceBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
