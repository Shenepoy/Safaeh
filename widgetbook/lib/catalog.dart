import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh_example/pages.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/common.dart';
import 'use_cases/controls.dart';
import 'use_cases/display.dart';
import 'use_cases/flows.dart';
import 'use_cases/layout.dart';
import 'use_cases/sheets.dart';
import 'preview_host.dart';

WidgetbookComponent _component(String name, Map<String, WidgetBuilder> cases) =>
    WidgetbookComponent(
      name: name,
      useCases: [
        for (final entry in cases.entries)
          WidgetbookUseCase(
            name: entry.key,
            builder: (context) =>
                PreviewHost.preserveStoryState(context, entry.value(context)),
          ),
      ],
    );

WidgetBuilder _demo(
  Widget Function(String Function(String) t) build, {
  bool fullPage = false,
}) => (context) {
  final child = build((key) => storyText(context, key));
  return fullPage
      ? Scaffold(body: SafeArea(child: child))
      : StoryPage(child: child);
};

WidgetBuilder _sidenavDemo(
  Widget Function(String Function(String) t, int count) build,
) => (context) {
  final count = context.knobs.int.slider(
    label: 'Item count',
    initialValue: 20,
    min: 2,
    max: 50,
  );
  return Scaffold(
    body: SafeArea(child: build((key) => storyText(context, key), count)),
  );
};

final catalogDirectories = <WidgetbookNode>[
  WidgetbookFolder(
    name: 'Controls',
    children: [
      _component('Option tile', {
        'Default': optionTileStory,
        'Long mixed text': (context) =>
            optionTileStory(context, longText: true),
        'Labeled and disabled rows': _demo((t) => OptionTilesDemo(t: t)),
      }),
      _component('Dropdown', {'Default': dropdownStory}),
      _component('Anchored popout', {'Default': anchoredStory}),
      _component('Calendar', {'Default': (_) => const CalendarStory()}),
      _component('Swatch picker', {
        'Default': _demo((t) => SwatchPickerDemo(t: t)),
      }),
      _component('Cycle button', {
        'Default': (context) => CycleStory(
          enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
        ),
      }),
    ],
  ),
  WidgetbookFolder(
    name: 'Display',
    children: [
      _component('Meta chip', {'Default': metaChipStory}),
      _component('Content panel', {'Default': contentPanelStory}),
      _component('KPI card', {'Default': kpiStory}),
      _component('Glyph avatar', {
        'Default': _demo((t) => GlyphAvatarDemo(t: t)),
      }),
      _component('Bordered list', {
        'Default': _demo((t) => BorderedListDemo(t: t)),
      }),
      _component('Section header', {
        'Default': _demo((t) => SectionHeaderDemo(t: t)),
      }),
      _component('User text', {'Mixed direction': userTextStory}),
      _component('Accent surfaces', {
        'Default': _demo((t) => AccentSurfacesDemo(t: t)),
      }),
      _component('Material chrome', {
        'Default': _demo((t) => MaterialChromeDemo(t: t)),
      }),
      _component('Floating surfaces', {
        'Presets': _demo((t) => const FloatingSurfaceStylesDemo()),
      }),
    ],
  ),
  WidgetbookFolder(
    name: 'Feedback',
    children: [
      _component('Inline banner', {
        'Info': inlineBannerStory,
        'Error': (context) =>
            inlineBannerStory(context, initialTone: SafaehBannerTone.error),
      }),
      _component('Empty state', {'Default': emptyStateStory}),
      _component('Async body', {
        for (final state in AsyncScenario.values)
          state.name: (context) => asyncStory(context, state),
      }),
      _component('Status body', {'Default': statusStory}),
      _component('Feedback', {'Default': feedbackStory}),
    ],
  ),
  WidgetbookFolder(
    name: 'Sheets',
    children: [
      _component('Adaptive sheet', {'Default': adaptiveSheetStory}),
      _component('Confirm', {
        'Default': confirmStory,
        'Destructive': (context) => confirmStory(context, destructive: true),
      }),
      _component('Timed confirm', {'Default': timedConfirmStory}),
      _component('Dialog', {'Default': dialogStory}),
      _component('Information', {'Default': infoStory}),
      _component('Actions', {'Default': actionsStory}),
      _component('Text input', {'Validation': textInputStory}),
      _component('Card picker', {'Default': pickerStory}),
      _component('Tile picker', {
        'Search': (context) => pickerStory(context, tiles: true),
        'Empty': (context) => pickerStory(context, tiles: true, empty: true),
        'Multiple': (context) => pickerStory(context, tiles: true, multi: true),
      }),
      _component('Sheet shell', {'Default': shellStory}),
      _component('Sheet template', {'Default': templateStory}),
      _component('Sheet loading', {'Default': sheetLoadingStory}),
      _component('Sheet action', {'Default': sheetActionStory}),
      _component('Sheet padding', {
        'Default': _demo((t) => SheetPaddingDemo(t: t)),
      }),
    ],
  ),
  WidgetbookFolder(
    name: 'Navigation',
    children: [
      _component('Sidenav', {
        'Rail': _sidenavDemo(
          (t, count) => SidenavRailDemo(t: t, itemCount: count),
        ),
        'Drawer': _sidenavDemo(
          (t, count) => SidenavDrawerDemo(t: t, itemCount: count),
        ),
        'Overlay': _sidenavDemo(
          (t, count) => SidenavOverlayDemo(t: t, itemCount: count),
        ),
      }),
      _component('Floating nav', {
        'Default': _demo((t) => FloatingNavDemo(t: t), fullPage: true),
      }),
      _component('Page index', {
        'Rail': _demo((t) => PageIndexRailDemo(t: t), fullPage: true),
        'Overlay': _demo((t) => PageIndexOverlayDemo(t: t), fullPage: true),
      }),
      _component('App bar', {
        'Morphing': _demo((t) => MorphingAppBarDemo(t: t), fullPage: true),
      }),
    ],
  ),
  WidgetbookFolder(
    name: 'Layout',
    children: [
      _component('Keyboard and navigation', {
        'Default': (_) => const BottomNavStory(),
      }),
      _component('Cutout avoidance', {
        'Floating control': (_) => const BottomNavStory(topFab: true),
      }),
      _component('Aligned page', {'Default': alignedPageStory}),
      _component('Content band', {
        'Default': _demo((t) => ContentBandDemo(t: t), fullPage: true),
      }),
      _component('End aside', {
        'Default': _demo((t) => EndAsideDemo(t: t), fullPage: true),
      }),
      _component('Aligned chrome', {
        'Default': _demo((t) => AlignedChromeDemo(t: t), fullPage: true),
      }),
    ],
  ),
  WidgetbookFolder(
    name: 'Camera',
    children: [
      _component('Camera sheet', {
        'Mock feed': (context) => cameraStory(context, 'camera'),
      }),
      _component('QR scanner', {
        'Overlay': (context) => cameraStory(context, 'qr_overlay'),
        'Permission message': (context) => cameraStory(context, 'qr_message'),
      }),
    ],
  ),
  WidgetbookFolder(
    name: 'Onboarding',
    children: [
      _component('Flow', {
        for (final design in SafaehOnboardingDesign.values)
          design.name: (context) => onboardingStory(context, design),
      }),
      _component('Auth', {
        for (final design in SafaehOnboardingDesign.values)
          design.name: (context) => authStory(context, design),
      }),
    ],
  ),
  WidgetbookFolder(
    name: 'Developer tools',
    children: [
      _component('Debug menu', {'Default': debugStory}),
      _component('Translation editor', {
        'In memory': _demo((t) => L10nEditorDemo(t: t)),
      }),
    ],
  ),
];
