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
