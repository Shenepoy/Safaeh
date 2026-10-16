import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('text input validator keeps the sheet open', (tester) async {
    String? value = 'unset';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              value = await showSafaehTextInput(
                context: context,
                title: 'Number',
                doneLabel: 'Done',
                validator: (text) =>
                    double.tryParse(text) == null ? 'Enter a number' : null,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('safaeh_text_done')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a number'), findsOneWidget);
    expect(value, 'unset');

    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.byKey(const ValueKey('safaeh_text_done')));
    await tester.pumpAndSettle();
    expect(value, '12');
  });

  testWidgets('anchored motions show the host card', (tester) async {
    Future<void> open(SafaehAnchoredMotion motion) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehAnchored<void>(
                context: context,
                motion: motion,
                sourceRect: const Rect.fromLTWH(20, 40, 48, 48),
                child: const Text('Attached card'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Attached card'), findsOneWidget);
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
    }

    await open(SafaehAnchoredMotion.fadeScale);
    await open(SafaehAnchoredMotion.genie);
    await open(SafaehAnchoredMotion.drop);
  });

  testWidgets('genie popout grows from the end of its trigger', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final link = LayerLink();
    final targetKey = GlobalKey();
    final modalKey = const ValueKey('genie-modal');

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: CompositedTransformTarget(
                    link: link,
                    child: SizedBox(
                      key: targetKey,
                      width: 164,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          final box =
                              targetKey.currentContext!.findRenderObject()
                                  as RenderBox;
                          final overlay =
                              Overlay.of(context).context.findRenderObject()
                                  as RenderBox;
                          final rect =
                              box.localToGlobal(
                                Offset.zero,
                                ancestor: overlay,
                              ) &
                              box.size;
                          showSafaehAnchored<void>(
                            context: context,
                            motion: SafaehAnchoredMotion.genie,
                            link: link,
                            sourceRect: rect,
                            sourceShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              key: modalKey,
                              child: const SizedBox(
                                width: 360,
                                height: 220,
                                child: Text('Expanded calendar'),
                              ),
                            ),
                          );
                        },
                        child: const Text('Date'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Date'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final trigger = tester.getRect(find.byKey(targetKey));
    final modal = tester.getRect(find.byKey(modalKey));
    expect(modal.right, closeTo(trigger.right, 1));
    expect(modal.top, closeTo(trigger.bottom + 8, 1));
    expect(find.text('Expanded calendar'), findsOneWidget);
  });

  testWidgets(
    'genie panels stay inside physical safe edges on either landscape side',
    (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(right: 52, bottom: 24);
      tester.view.viewPadding = const FakeViewPadding(right: 52, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      final link = LayerLink();
      final targetKey = GlobalKey();
      const panelKey = ValueKey('camera-safe-panel');
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CompositedTransformTarget(
                      link: link,
                      child: SizedBox(
                        key: targetKey,
                        width: 164,
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            final box =
                                targetKey.currentContext!.findRenderObject()
                                    as RenderBox;
                            showSafaehAnchored<void>(
                              context: context,
                              motion: SafaehAnchoredMotion.genie,
                              link: link,
                              sourceRect:
                                  box.localToGlobal(Offset.zero) & box.size,
                              child: const Material(
                                key: panelKey,
                                child: SizedBox(
                                  width: 360,
                                  height: 220,
                                  child: Text('Safe calendar'),
                                ),
                              ),
                            );
                          },
                          child: const Text('Open date'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open date'));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(panelKey)).right,
        closeTo(tester.getRect(find.byKey(targetKey)).right, 1),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(panelKey)).right,
        lessThanOrEqualTo(736),
      );
      expect(
        tester.getRect(find.byKey(panelKey)).bottom,
        lessThanOrEqualTo(364),
      );
      tester.view.padding = const FakeViewPadding(left: 52, bottom: 24);
      tester.view.viewPadding = const FakeViewPadding(left: 52, bottom: 24);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(panelKey)).right, closeTo(788, 1));
      expect(
        tester.getRect(find.byKey(panelKey)).left,
        greaterThanOrEqualTo(64),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('month calendar paints the host month and a day', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehMonthCalendar(
            month: DateTime(2026, 10),
            firstDate: DateTime(2026, 1, 1),
            lastDate: DateTime(2026, 12, 31),
            monthLabel: 'October 2026',
            weekdayLabels: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
            previousTooltip: 'Previous',
            nextTooltip: 'Next',
            onPreviousMonth: () {},
            onNextMonth: () {},
            onDayTap: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('swatch picker reports a color and none', (tester) async {
    Color? selected = const Color(0xFFFF0000);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SafaehSwatchPicker(
              colors: const [Color(0xFFFF0000), Color(0xFF00FF00)],
              selected: selected,
              showNone: true,
              onSelected: (color) => setState(() => selected = color),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.block));
    await tester.pump();
    expect(selected, isNull);
  });

  testWidgets('labeled option tile shows its string title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SafaehLabeledOptionTile(title: 'Advanced')),
      ),
    );
    expect(find.text('Advanced'), findsOneWidget);
  });
}
