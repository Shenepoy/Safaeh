import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

const _sections = [
  SafaehSection(id: 'days', label: 'Days'),
  SafaehSection(id: 'food', label: 'Restaurants', count: 11),
  SafaehSection(id: 'shops', label: 'Shops', count: 5),
];

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    Directionality(
      textDirection: dir,
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  testWidgets('shows labels with counts and reports selection', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _host(
        SafaehSectionChips(
          sections: _sections,
          selectedId: 'days',
          onSelected: (id) => picked = id,
        ),
      ),
    );
    expect(find.text('Days'), findsOneWidget);
    expect(find.text('Restaurants · 11'), findsOneWidget);
    await tester.tap(find.text('Shops · 5'));
    expect(picked, 'shops');
  });

  testWidgets('selected chip is exposed as selected to semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        SafaehSectionChips(
          sections: _sections,
          selectedId: 'food',
          onSelected: (_) {},
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Restaurants · 11')),
      matchesSemantics(
        label: 'Restaurants · 11',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('add chip and long press call back', (tester) async {
    var added = 0;
    String? pressed;
    await tester.pumpWidget(
      _host(
        SafaehSectionChips(
          sections: _sections,
          selectedId: 'days',
          onSelected: (_) {},
          onAdd: () => added++,
          addLabel: 'Add section',
          onLongPress: (id) => pressed = id,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add));
    expect(added, 1);
    await tester.longPress(find.text('Days'));
    expect(pressed, 'days');
  });

  testWidgets('reorder mode builds, shows add, and supports RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SafaehSectionChips(
          sections: _sections,
          selectedId: 'days',
          onSelected: (_) {},
          onAdd: () {},
          addLabel: 'Add',
          onReorder: (_, _) {},
        ),
        dir: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
