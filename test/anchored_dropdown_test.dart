import 'package:material_ui/material_ui.dart';
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

  testWidgets('scrollable menu caps its height and returns a later choice', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SafaehAnchoredDropdownChip<int>.scrollable(
              icon: Icons.filter_alt_outlined,
              label: 'Choose an option',
              selected: 1,
              maxHeight: 160,
              options: [
                for (var i = 1; i <= 12; i++)
                  SafaehDropdownOption(value: i, label: 'Option $i'),
              ],
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose an option'));
    await tester.pumpAndSettle();

    final menu = find.byType(Scrollable);
    final lastOption = find.text('Option 12').hitTestable();
    expect(tester.getSize(menu).height, lessThanOrEqualTo(160));
    expect(lastOption, findsNothing);

    await tester.dragUntilVisible(lastOption, menu, const Offset(0, -100));
    await tester.tap(lastOption);
    await tester.pumpAndSettle();

    expect(selected, 12);
    expect(menu, findsNothing);
  });

  testWidgets('checkbox choices update independently and keep the menu open', (
    tester,
  ) async {
    final selected = <int>{1};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) =>
                  SafaehAnchoredToggleDropdownChip<int>(
                    icon: Icons.filter_alt_outlined,
                    label: 'Filters',
                    selectedValues: selected,
                    options: const [
                      SafaehDropdownOption(value: 1, label: 'One'),
                      SafaehDropdownOption(value: 2, label: 'Two'),
                    ],
                    onToggled: (value, checked) => setState(() {
                      if (checked) {
                        selected.add(value);
                      } else {
                        selected.remove(value);
                      }
                    }),
                  ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    final toggles = find.byType(CheckboxMenuButton);
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(find.text('Two').hitTestable(), findsOneWidget);
    expect(tester.widgetList<CheckboxMenuButton>(toggles).map((w) => w.value), [
      true,
      true,
    ]);

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(selected, {2});
    expect(tester.widgetList<CheckboxMenuButton>(toggles).map((w) => w.value), [
      false,
      true,
    ]);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(toggles, findsNothing);
  });
}
