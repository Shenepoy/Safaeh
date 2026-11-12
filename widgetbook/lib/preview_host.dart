import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;

import 'package:flutter/widgets.dart';
// Widgetbook 3.x settings use SDK Material, independently of the preview.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as sdk;
import 'package:material_ui/material_ui.dart' as m;
import 'package:safaeh/safaeh.dart';
import 'package:safaeh_example/catalog.dart';
import 'package:safaeh_example/catalog_theme.dart';
import 'package:widgetbook/widgetbook.dart' as wb;

/// Settings that belong to the preview, rather than the Widgetbook interface.
class PreviewOptions {
  const PreviewOptions({
    this.platform = TargetPlatform.android,
    this.surface = SafaehFloatingSurfaceStyle.solid,
    this.reducedMotion = false,
    this.keyboardInset = 0,
    this.cutout = false,
  });

  final TargetPlatform platform;
  final SafaehFloatingSurfaceStyle surface;
  final bool reducedMotion;
  final double keyboardInset;
  final bool cutout;
}

class PreviewOptionsAddon extends wb.WidgetbookAddon<PreviewOptions> {
  PreviewOptionsAddon() : super(name: 'Environment');

  @override
  Widget buildFields(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(name, style: sdk.Theme.of(context).textTheme.titleSmall),
        for (final field in fields)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: field is wb.BooleanField
                ? sdk.SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(field.name),
                    value: field.valueFrom(
                      wb.FieldCodec.decodeQueryGroup(
                        wb.WidgetbookState.of(context).queryParams[groupName],
                      ),
                    )!,
                    onChanged: (value) =>
                        field.updateField(context, groupName, value),
                  )
                : Semantics(
                    label: field.name,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(child: Text(field.name)),
                        const SizedBox(height: 8),
                        field.build(context, groupName),
                      ],
                    ),
                  ),
          ),
      ],
    ),
  );

  @override
  List<wb.Field> get fields => [
    wb.ObjectDropdownField<TargetPlatform>(
      name: 'Platform',
      values: TargetPlatform.values,
      initialValue: TargetPlatform.android,
      labelBuilder: (value) => value.name,
    ),
    wb.ObjectDropdownField<SafaehFloatingSurfaceStyle>(
      name: 'Surface',
      values: SafaehFloatingSurfaceStyle.values,
      initialValue: SafaehFloatingSurfaceStyle.solid,
      labelBuilder: (value) => value.name,
    ),
    wb.BooleanField(name: 'Reduced motion', initialValue: false),
    wb.BooleanField(name: 'Simulated cutout', initialValue: false),
    wb.DoubleSliderField(
      name: 'Keyboard inset',
      min: 0,
      max: 360,
      divisions: 12,
    ),
  ];

  @override
  PreviewOptions valueFromQueryGroup(Map<String, String> group) =>
      PreviewOptions(
        platform: valueOf<TargetPlatform>('Platform', group)!,
        surface: valueOf<SafaehFloatingSurfaceStyle>('Surface', group)!,
        reducedMotion: valueOf<bool>('Reduced motion', group)!,
        cutout: valueOf<bool>('Simulated cutout', group)!,
        keyboardInset: valueOf<double>('Keyboard inset', group)!,
      );

  @override
  Widget buildUseCase(
    BuildContext context,
    Widget child,
    PreviewOptions setting,
  ) {
    final path = wb.WidgetbookState.of(context).path ?? '';
    return PreviewHost(
      key: ValueKey(path),
      options: setting,
      feedback: path.startsWith('feedback/feedback/'),
      child: child,
    );
  }
}

List<wb.WidgetbookAddon> previewAddons() => [
  wb.ViewportAddon([
    for (final width in [
      390.0,
      320.0,
      599.0,
      600.0,
      601.0,
      839.0,
      840.0,
      841.0,
      1280.0,
    ])
      wb.ViewportData(
        name: '${width.toInt()} px',
        width: width,
        height: 844,
        pixelRatio: 1,
        platform: TargetPlatform.android,
      ),
    const wb.ViewportData(
      name: 'Phone with safe areas',
      width: 390,
      height: 844,
      pixelRatio: 1,
      platform: TargetPlatform.android,
      safeAreas: EdgeInsets.only(top: 44, bottom: 34),
    ),
  ]),
  wb.ThemeAddon<m.ThemeData>(
    themes: [
      wb.WidgetbookTheme(name: 'Light', data: catalogTheme(Brightness.light)),
      wb.WidgetbookTheme(name: 'Dark', data: catalogTheme(Brightness.dark)),
    ],
    themeBuilder: (_, theme, child) => m.Theme(data: theme, child: child),
  ),
  wb.LocalizationAddon(
    locales: [for (final item in catalogLocales) item.locale],
    initialLocale: const Locale('en'),
    localizationsDelegates: m.GlobalMaterialLocalizations.delegates,
  ),
  wb.TextScaleAddon(min: 1, max: 2, divisions: 10),
  PreviewOptionsAddon(),
];

/// Owns a local Navigator, with every environment setting above its routes.
/// Story identity is supplied by the caller's key; setting changes keep routes.
class PreviewHost extends StatefulWidget {
  const PreviewHost({
    super.key,
    required this.child,
    this.options = const PreviewOptions(),
    this.feedback = false,
  });

  final Widget child;
  final PreviewOptions options;
  final bool feedback;

  /// Widgetbook keys its use-case builder by the entire URL. Preserve the
  /// story's state when a knob/addon changes that URL, but reset on story change.
  static Widget preserveStoryState(BuildContext context, Widget child) =>
      KeyedSubtree(
        key: context
            .dependOnInheritedWidgetOfExactType<_PreviewContent>()!
            .storyKey,
        child: child,
      );

  @override
  State<PreviewHost> createState() => _PreviewHostState();
}

class _PreviewHostState extends State<PreviewHost> {
  int _generation = 0;
  GlobalKey _storyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final media = MediaQuery.of(context);
    final keyboard = options.keyboardInset;
    final theme = m.Theme.of(context).copyWith(platform: options.platform);
    Widget content = _PreviewContent(
      content: widget.child,
      storyKey: _storyKey,
      child: Navigator(
        key: ValueKey(_generation),
        onGenerateRoute: (_) => PageRouteBuilder<void>(
          pageBuilder: (context, _, _) => _PreviewContent.of(context),
        ),
      ),
    );
    if (widget.feedback) {
      content = SafaehFeedbackHost(
        key: ValueKey(_generation),
        itemWidthBuilder: (context) =>
            (MediaQuery.sizeOf(context).width - 32).clamp(0, 560),
        child: content,
      );
    }
    return m.Theme(
      data: theme,
      child: MediaQuery(
        data: media.copyWith(
          disableAnimations: options.reducedMotion,
          viewInsets: EdgeInsets.only(bottom: keyboard),
          padding: media.padding.copyWith(
            bottom: keyboard > 0 ? 0 : media.padding.bottom,
          ),
          displayFeatures: options.cutout
              ? [
                  const DisplayFeature(
                    bounds: Rect.fromLTWH(16, 8, 32, 32),
                    type: DisplayFeatureType.cutout,
                    state: DisplayFeatureState.unknown,
                  ),
                ]
              : const [],
        ),
        child: SafaehTheme(
          data: SafaehThemeData(
            floatingAppearance: SafaehFloatingAppearance(
              style: options.surface,
            ),
          ),
          child: SafaehNavigatorScope(
            useRootNavigator: false,
            child: m.Material(
              color: theme.colorScheme.surface,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  content,
                  PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: m.IconButton.filledTonal(
                      tooltip: 'Reset preview',
                      onPressed: () => setState(() {
                        _generation++;
                        _storyKey = GlobalKey();
                      }),
                      icon: const m.Icon(m.Icons.restart_alt),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps the live story child available to an already mounted initial route.
class _PreviewContent extends InheritedWidget {
  const _PreviewContent({
    required this.content,
    required this.storyKey,
    required super.child,
  });
  final Widget content;
  final GlobalKey storyKey;

  static Widget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PreviewContent>()!.content;

  @override
  bool updateShouldNotify(_PreviewContent oldWidget) =>
      content != oldWidget.content || storyKey != oldWidget.storyKey;
}
