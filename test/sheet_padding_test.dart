import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('wide tile picker sits below the header inset', (tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehTilePicker<int>(
                context: context,
                title: 'How to settle',
                selected: 1,
                options: const [
                  SafaehTileOption(
                    value: 1,
                    label: 'Minimal moves',
                    subtitle: 'Clear the group',
                  ),
                ],
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final header = tester.getBottomLeft(find.text('How to settle'));
    final first = tester.getTopLeft(find.text('Minimal moves'));
    expect(first.dy - header.dy, greaterThanOrEqualTo(16));
  });

  testWidgets('RTL wide tile picker keeps the same top inset', (tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehTilePicker<int>(
                context: context,
                title: 'طريقة التسوية',
                selected: 1,
                options: const [
                  SafaehTileOption(
                    value: 1,
                    label: 'أقل تحويلات',
                    subtitle: 'مسح المجموعة',
                  ),
                ],
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final header = tester.getBottomLeft(find.text('طريقة التسوية'));
    final first = tester.getTopLeft(find.text('أقل تحويلات'));
    expect(first.dy - header.dy, greaterThanOrEqualTo(16));
  });
}
