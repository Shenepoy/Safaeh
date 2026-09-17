import 'package:flutter/material.dart';

import 'adaptive_sheet.dart';
import 'content_panel.dart';
import 'sheet_shell.dart';
import 'theme.dart';

/// Informational modal with a content panel and a primary action.
///
/// Phone: optional secondary (cancel) in the footer. Tablet+: close chrome
/// is the dismiss path.
Future<bool?> showSafaehInfo({
  required BuildContext context,
  required String title,
  required String content,
  required String primaryLabel,
  String? secondaryLabel,
  bool showSecondaryAction = true,
  SafaehTitleBuilder? titleBuilder,
  SafaehTitleBuilder? contentBuilder,
  double Function(BuildContext context)? railWidthOf,
  SafaehTransition? fadeScale,
  SafaehTransition? slideUp,
  SafaehPhoneSheetPlacement phonePlacement = SafaehPhoneSheetPlacement.bottom,
  double? tabletBreakpoint,
  Duration? motion,
  Curve? enterCurve,
  Curve? exitCurve,
  double? maxWidth,
  double? maxHeight,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  SafaehRouteOptions? route,
}) {
  final tokens = SafaehTheme.of(context);
  final breakpoint = tabletBreakpoint ?? tokens.tabletBreakpoint;
  return showSafaeh<bool>(
    context: context,
    title: title,
    titleBuilder: titleBuilder,
    tabletBreakpoint: breakpoint,
    maxWidth: maxWidth,
    maxHeight: maxHeight ?? MediaQuery.sizeOf(context).height * 0.75,
    barrierDismissible: barrierDismissible,
    motion: motion,
    enterCurve: enterCurve,
    exitCurve: exitCurve,
    railWidthOf: railWidthOf,
    fadeScale: fadeScale,
    slideUp: slideUp,
    phonePlacement: phonePlacement,
    useRootNavigator: useRootNavigator,
    paintPhoneTitle: true,
    route: route,
    child: SafaehInfoSheet(
      title: title,
      content: content,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      showSecondaryAction: showSecondaryAction,
      titleBuilder: titleBuilder,
      contentBuilder: contentBuilder,
      tabletBreakpoint: breakpoint,
    ),
  );
}

/// Body used by [showSafaehInfo].
class SafaehInfoSheet extends StatelessWidget {
  const SafaehInfoSheet({
    super.key,
    required this.title,
    required this.content,
    required this.primaryLabel,
    this.secondaryLabel,
    this.showSecondaryAction = true,
    this.titleBuilder,
    this.contentBuilder,
    this.tabletBreakpoint,
  });

  final String title;
  final String content;
  final String primaryLabel;
  final String? secondaryLabel;
  final bool showSecondaryAction;
  final SafaehTitleBuilder? titleBuilder;
  final SafaehTitleBuilder? contentBuilder;
  final double? tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    final tokens = SafaehTheme.of(context);
    final breakpoint = tabletBreakpoint ?? tokens.tabletBreakpoint;
    final isWide = MediaQuery.sizeOf(context).width >= breakpoint;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final contentStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onSurfaceVariant,
    );
    final secondary =
        secondaryLabel ?? MaterialLocalizations.of(context).cancelButtonLabel;

    return buildSafaehSheetShell(
      showTitleInBody: false,
      title:
          titleBuilder?.call(context, titleStyle) ??
          Text(title, style: titleStyle),
      body: SafaehContentPanel(
        child:
            contentBuilder?.call(context, contentStyle) ??
            Text(content, style: contentStyle),
      ),
      actions: [
        if (!isWide && showSecondaryAction)
          TextButton(
            key: const ValueKey('safaeh_cancel'),
            onPressed: () => safaehPop(context, false),
            child: Text(secondary),
          ),
        FilledButton(
          key: const ValueKey('safaeh_info_primary'),
          onPressed: () => safaehPop(context, true),
          child: Text(primaryLabel),
        ),
      ],
    );
  }
}
