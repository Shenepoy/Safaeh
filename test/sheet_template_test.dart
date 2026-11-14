import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

Widget host(
  Widget child, {
  SafaehThemeData theme = const SafaehThemeData(),
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
}) => MaterialApp(
  home: SafaehTheme(
    data: theme,
    child: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: child),
      ),
    ),
  ),
);

void main() {
  testWidgets('local template overrides cross the modal route', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              contentPadding: EdgeInsets.zero,
              child: const SafaehSheetTemplate(
                body: SafaehSheetSurface(child: Text('Route surface')),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
        theme: const SafaehThemeData(
          sheetTemplate: SafaehSheetTemplateStyle(
            surfaceColor: Colors.orange,
            padding: EdgeInsets.all(8),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('Route surface'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color!.toARGB32(), Colors.orange.toARGB32());
    expect(
      SafaehTheme.of(tester.element(find.text('Route surface')))
          .sheetTemplate
          .padding,
      const EdgeInsets.all(8),
    );
  });

  testWidgets('app-wide theme remains live while the sheet is open', (
    tester,
  ) async {
    final color = ValueNotifier<Color>(Colors.blue);
    addTearDown(color.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<Color>(
        valueListenable: color,
        builder: (_, value, child) => SafaehTheme(
          data: SafaehThemeData(
            sheetTemplate: SafaehSheetTemplateStyle(surfaceColor: value),
          ),
          child: child!,
        ),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSafaeh<void>(
                  context: context,
                  child: const SafaehSheetSurface(child: Text('Live surface')),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    color.value = Colors.purple;
    await tester.pumpAndSettle();
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('Live surface'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color!.toARGB32(), Colors.purple.toARGB32());
  });

  test('template theme participates in copying and equality', () {
    const style = SafaehSheetTemplateStyle(
      surfaceColor: Colors.white,
      darkSurfaceColor: Colors.black,
      padding: EdgeInsetsDirectional.only(start: 12),
    );
    final theme = const SafaehThemeData().copyWith(sheetTemplate: style);
    expect(theme.copyWith(), theme);
    expect(theme.copyWith().hashCode, theme.hashCode);
    expect(
      theme.copyWith(sheetTemplate: style.copyWith(headerGap: 30)),
      isNot(theme),
    );
    expect(style.copyWith(surfaceRadius: 8).darkSurfaceColor, Colors.black);
  });

  for (final direction in TextDirection.values) {
    testWidgets(
      'pinned footer survives long content and large text in $direction',
      (tester) async {
        var saved = false;
        await tester.pumpWidget(
          host(
            SizedBox(
              width: 320,
              height: 420,
              child: SafaehSheetTemplate(
                header: const SafaehSheetHeading(
                  title: 'A long editable sheet title',
                  leading: Icon(Icons.edit),
                  maxLines: null,
                ),
                body: Column(
                  children: [for (var i = 0; i < 30; i++) Text('Item $i')],
                ),
                footer: FilledButton(
                  onPressed: () => saved = true,
                  child: const Text('Save'),
                ),
              ),
            ),
            direction: direction,
            textScale: 2,
          ),
        );
        expect(tester.takeException(), isNull);
        final before = tester.getRect(find.text('Save'));
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.text('Save')), before);
        await tester.tap(find.text('Save'));
        expect(saved, isTrue);
      },
    );

    testWidgets(
      'heading uses logical order and accepts trailing content in $direction',
      (tester) async {
        await tester.pumpWidget(
          host(
            const SafaehSheetHeading(
              title: 'Name',
              leading: Icon(Icons.edit),
              trailing: Icon(Icons.help),
            ),
            direction: direction,
          ),
        );
        final leading = tester.getCenter(find.byIcon(Icons.edit)).dx;
        final trailing = tester.getCenter(find.byIcon(Icons.help)).dx;
        expect(
          direction == TextDirection.ltr
              ? leading < trailing
              : leading > trailing,
          isTrue,
        );
      },
    );
  }

  testWidgets(
    'selection template supports its own list without adding a footer',
    (tester) async {
      var choice = -1;
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 300,
            child: SafaehSheetTemplate(
              header: const Text('Choose'),
              scrollBody: false,
              body: ListView(
                children: [
                  for (var i = 0; i < 30; i++)
                    ListTile(title: Text('Item $i'), onTap: () => choice = i),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      await tester.tap(find.text('Item 0'));
      expect(choice, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('theme defaults and per-surface overrides remain independent', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Column(
          children: [
            SafaehSheetSurface(child: Text('Default')),
            SafaehSheetSurface(
              color: Colors.blue,
              radius: 4,
              child: Text('Custom'),
            ),
          ],
        ),
        theme: const SafaehThemeData(
          sheetTemplate: SafaehSheetTemplateStyle(
            surfaceColor: Colors.green,
            surfaceRadius: 20,
          ),
        ),
      ),
    );
    Material surface(String text) => tester.widget<Material>(
      find.ancestor(of: find.text(text), matching: find.byType(Material)).first,
    );
    expect(surface('Default').color!.toARGB32(), Colors.green.toARGB32());
    expect(surface('Custom').color!.toARGB32(), Colors.blue.toARGB32());
    expect(
      (surface('Custom').shape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(4),
    );
  });

  testWidgets('cached read bypasses work and keeps edits on parent rebuild', (
    tester,
  ) async {
    var calls = 0;
    Widget editor(String initial) => host(
      SafaehSheetDataLoader<String>(
        initialData: initial,
        load: (_) {
          calls++;
          return 'replacement';
        },
        builder: (_, value) => TextFormField(initialValue: value),
      ),
    );
    await tester.pumpWidget(editor('Cached'));
    await tester.enterText(find.byType(TextFormField), 'Draft');
    await tester.pumpWidget(editor('Refreshed'));
    expect(find.text('Draft'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets(
    'custom loading and error slots receive safe retry and report once',
    (tester) async {
      final pending = Completer<String>();
      var calls = 0, reports = 0;
      await tester.pumpWidget(
        host(
          SafaehSheetDataLoader<String>(
            load: (retry) {
              calls++;
              return retry ? 'Recovered' : pending.future;
            },
            builder: (_, value) => Text(value),
            loadingBuilder: (_) => const Text('Host skeleton'),
            errorBuilder: (_, error, stack, retry) =>
                TextButton(onPressed: retry, child: const Text('Host retry')),
            onError: (_, _) => reports++,
          ),
        ),
      );
      expect(find.text('Host skeleton'), findsOneWidget);
      pending.completeError(StateError('private error'));
      await tester.pumpAndSettle();
      expect(find.textContaining('private error'), findsNothing);
      await tester.tap(find.text('Host retry'));
      await tester.tap(find.text('Host retry'));
      await tester.pumpAndSettle();
      expect(find.text('Recovered'), findsOneWidget);
      expect(calls, 2);
      expect(reports, 1);
    },
  );

  testWidgets('timeout result cannot replace a successful retry', (
    tester,
  ) async {
    final pending = Completer<String>();
    await tester.pumpWidget(
      host(
        SafaehSheetDataLoader<String>(
          timeout: const Duration(seconds: 1),
          load: (retry) => retry ? 'New' : pending.future,
          builder: (_, value) => Text(value),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    pending.complete('Old');
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Old'), findsNothing);
  });

  testWidgets('disposing a stalled read cancels its timeout timer', (
    tester,
  ) async {
    final pending = Completer<String>();
    await tester.pumpWidget(
      host(
        SafaehSheetDataLoader<String>(
          load: (_) => pending.future,
          builder: (_, value) => Text(value),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    // Intentionally leave the host read unresolved. No package-owned timer
    // should remain pending at test teardown.
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'disposed read cannot mount data or report into a different sheet',
    (tester) async {
      final pending = Completer<String>();
      var reports = 0;
      await tester.pumpWidget(
        host(
          SafaehSheetDataLoader<String>(
            load: (_) => pending.future,
            builder: (_, value) => Text(value),
            onError: (_, _) => reports++,
          ),
        ),
      );
      await tester.pumpWidget(host(const Text('Different route')));
      pending.completeError(StateError('Late error'));
      await tester.pumpAndSettle();
      expect(reports, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('localized loading and error reserve the same footprint', (
    tester,
  ) async {
    final pending = Completer<String>();
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 320,
          height: 500,
          child: SafaehSheetDataLoader<String>(
            load: (_) => pending.future,
            builder: (_, value) => Text(value),
            labels: const SafaehSheetLoadLabels(
              loading: 'تحميل',
              error: 'تعذّر تحميل التفاصيل. حاول مرة أخرى.',
              retry: 'إعادة المحاولة',
            ),
          ),
        ),
        direction: TextDirection.rtl,
        textScale: 2,
      ),
    );
    final before = tester.getSize(find.byType(SafaehSheetSurface));
    pending.completeError(StateError('Hidden'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SafaehSheetSurface)), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('action state blocks primary and auxiliary clicks while active', (
    tester,
  ) async {
    var primary = 0, auxiliary = 0;
    for (final state in SafaehSheetActionState.values) {
      await tester.pumpWidget(
        host(
          SafaehSheetActionButton(
            label: 'Continue',
            activity: const AlwaysStoppedAnimation(.5),
            state: state,
            onPressed: () => primary++,
            leading: IconButton(
              onPressed: () => auxiliary++,
              icon: const Icon(Icons.info),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final active =
          state == SafaehSheetActionState.cooldown ||
          state == SafaehSheetActionState.working;
      final priorPrimary = primary, priorAux = auxiliary;
      await tester.tap(find.text('Continue'));
      await tester.tap(find.byIcon(Icons.info), warnIfMissed: !active);
      expect(primary, priorPrimary + (active ? 0 : 1));
      expect(auxiliary, priorAux + (active ? 0 : 1));
    }
  });

  testWidgets('button label and auxiliary slots do not shift between states', (
    tester,
  ) async {
    Rect? before;
    for (final state in SafaehSheetActionState.values) {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 320,
            child: SafaehSheetActionButton(
              buttonKey: const ValueKey('action'),
              label: state == SafaehSheetActionState.failed
                  ? 'Try again with changes'
                  : 'Save',
              stateLabels: const ['Save', 'Try again with changes'],
              reserveActionSpace: true,
              activity: const AlwaysStoppedAnimation(.5),
              state: state,
              onPressed: () {},
              trailing: state == SafaehSheetActionState.failed
                  ? const Icon(Icons.share)
                  : null,
            ),
          ),
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byKey(const ValueKey('action')));
      expect(rect, before ?? rect);
      before = rect;
      expect(tester.takeException(), isNull);
    }
  });
}
