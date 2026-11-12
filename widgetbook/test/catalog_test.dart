import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as m;
import 'package:safaeh/safaeh.dart';
import 'package:safaeh_widgetbook/catalog.dart';
import 'package:safaeh_widgetbook/main.dart';
import 'package:safaeh_widgetbook/preview_host.dart';
import 'package:safaeh_widgetbook/use_cases/common.dart';
import 'package:widgetbook/widgetbook.dart' as wb;

Future<void> openStory(WidgetTester tester, String path) async {
  tester.view.physicalSize = const Size(1600, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    SafaehWidgetbook(key: ValueKey(path), initialRoute: '?path=$path'),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

wb.WidgetbookState stateOf(WidgetTester tester) =>
    wb.WidgetbookState.of(tester.element(find.byType(PreviewHost)));

void setting(
  wb.WidgetbookState state,
  String group,
  String field,
  String value,
) => state.updateQueryField(group: group, field: field, value: value);

void main() {
  final root = wb.WidgetbookRoot(children: catalogDirectories);
  final stories = root.leaves.whereType<wb.WidgetbookUseCase>().toList();

  for (final story in stories) {
    testWidgets('renders ${story.path}', (tester) async {
      await openStory(tester, story.path);
      expect(find.byType(PreviewHost), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets('live knobs update content in the persistent preview route', (
    tester,
  ) async {
    await openStory(tester, 'controls/option-tile/default');
    final state = stateOf(tester);
    final before = Navigator.of(tester.element(find.byType(SafaehOptionTile)));
    setting(state, 'knobs', 'Title', 'Edited label');
    setting(state, 'knobs', 'Selected', 'false');
    await tester.pumpAndSettle();
    final tile = tester.widget<SafaehOptionTile>(find.byType(SafaehOptionTile));
    expect(tile.selected, isFalse);
    expect(find.text('Edited label'), findsWidgets);
    expect(
      Navigator.of(tester.element(find.byType(SafaehOptionTile))),
      same(before),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'open sheet keeps live copy and environment across a breakpoint',
    (tester) async {
      await openStory(tester, 'sheets/adaptive-sheet/default');
      final state = stateOf(tester);
      final launcher = find.descendant(
        of: find.byType(StoryResult),
        matching: find.byType(m.FilledButton),
      );
      await tester.tap(launcher);
      await tester.pumpAndSettle();
      final body = find.byKey(const ValueKey('adaptive_body'));
      final navigator = Navigator.of(tester.element(body));
      final narrow = MediaQuery.sizeOf(tester.element(body)).width;
      expect(narrow, 390);

      setting(state, 'knobs', 'Body', 'Live modal copy');
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(body).data,
        'Live modal copy',
        reason: 'copy update before environment changes',
      );
      setting(state, 'theme', 'name', 'Dark');
      setting(state, 'locale', 'name', 'ar');
      setting(state, 'text-scale', 'factor', '1.3');
      setting(state, 'viewport', 'name', '840 px');
      setting(state, 'environment', 'Reduced motion', 'true');
      setting(state, 'environment', 'Platform', 'iOS');
      await tester.pumpAndSettle();
      final context = tester.element(body);
      expect(tester.widget<Text>(body).data, 'Live modal copy');
      expect(Navigator.of(context), same(navigator));
      expect(MediaQuery.sizeOf(context).width, 840);
      expect(MediaQuery.textScalerOf(context).scale(10), 13);
      expect(MediaQuery.disableAnimationsOf(context), isTrue);
      expect(m.Theme.of(context).brightness, Brightness.dark);
      expect(m.Theme.of(context).platform, TargetPlatform.iOS);
      expect(Localizations.localeOf(context).languageCode, 'ar');
      expect(Directionality.of(context), TextDirection.rtl);
      expect(tester.takeException(), isNull);
      navigator.pop();
      await tester.pumpAndSettle();
      expect(body, findsNothing);
    },
  );

  testWidgets('reset dismisses modal and restores the initial story', (
    tester,
  ) async {
    await openStory(tester, 'sheets/adaptive-sheet/default');
    await tester.tap(
      find.descendant(
        of: find.byType(StoryResult),
        matching: find.byType(m.FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('adaptive_body')), findsOneWidget);
    await tester.tap(find.byTooltip('Reset preview'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('adaptive_body')), findsNothing);
    expect(find.byType(StoryResult), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('anchored popout uses the preview navigator', (tester) async {
    await openStory(tester, 'controls/anchored-popout/default');
    final button = find.descendant(
      of: find.byType(StoryPage),
      matching: find.byType(m.FilledButton),
    );
    final local = Navigator.of(tester.element(button));
    await tester.tap(button);
    await tester.pumpAndSettle();
    final card = find.byType(SafaehContentPanel);
    expect(card, findsOneWidget);
    expect(Navigator.of(tester.element(card)), same(local));
    expect(MediaQuery.sizeOf(tester.element(card)).width, 390);
    expect(tester.takeException(), isNull);
    local.pop();
    await tester.pumpAndSettle();
  });

  testWidgets('feedback stays local and is cleared on story change', (
    tester,
  ) async {
    await openStory(tester, 'feedback/feedback/default');
    final button = find.descendant(
      of: find.byType(StoryPage),
      matching: find.byType(m.FilledButton),
    );
    final overlay = Navigator.of(tester.element(button)).overlay;
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    final feedback = find.byType(SafaehFeedbackSurface);
    expect(feedback, findsOneWidget);
    expect(Overlay.of(tester.element(feedback)), same(overlay));
    expect(MediaQuery.sizeOf(tester.element(feedback)).width, 390);
    await tester.ensureVisible(find.text('Meta chip').first);
    await tester.tap(find.text('Meta chip').first);
    await tester.pumpAndSettle();
    expect(find.byType(SafaehMetaChip), findsOneWidget);
    expect(feedback, findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final path in [
    'controls/option-tile/long-mixed-text',
    'feedback/inline-banner/error',
    'display/content-panel/default',
    'onboarding/auth/zen',
  ]) {
    testWidgets('large Arabic text in $path', (tester) async {
      await openStory(tester, path);
      final state = stateOf(tester);
      setting(state, 'locale', 'name', 'ar');
      setting(state, 'theme', 'name', 'Dark');
      setting(state, 'text-scale', 'factor', '2.0');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
