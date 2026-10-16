import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('each cycle button animates and invokes only its own action', (
    tester,
  ) async {
    final calls = [0, 0];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              for (var slot = 0; slot < 2; slot++)
                SafaehCycleButton(
                  tooltip: 'Cycle $slot',
                  onPressed: () => calls[slot]++,
                ),
            ],
          ),
        ),
      ),
    );
    final first = find.byTooltip('Cycle 0');
    for (var tap = 0; tap < 10; tap++) {
      await tester.tap(first);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(calls, [10, 0]);
    await tester.tap(find.byTooltip('Cycle 1'));
    await tester.pumpAndSettle();
    expect(calls, [10, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a disabled button has no action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SafaehCycleButton(tooltip: 'Cycle', onPressed: null),
      ),
    );
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
  });
}
