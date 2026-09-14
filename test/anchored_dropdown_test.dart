import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('menu is at least as wide as its trigger', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SafaehAnchoredDropdownChip<int>(
              key: const ValueKey('dropdown'),
              icon: Icons.filter_alt_outlined,
              label: 'A long trigger label',
              selected: 1,
              options: const [
                SafaehDropdownOption(value: 1, label: 'One'),
                SafaehDropdownOption(value: 2, label: 'Two'),
              ],
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final trigger = find.byKey(const ValueKey('dropdown'));
    final triggerWidth = tester.getSize(trigger).width;

    await tester.tap(find.text('A long trigger label'));
    await tester.pumpAndSettle();

    final menuItem = find.byType(MenuItemButton).first;
    final menu = find
        .ancestor(of: menuItem, matching: find.byType(Material))
        .first;
    expect(tester.getSize(menu).width, closeTo(triggerWidth, 0.01));
  });
}
