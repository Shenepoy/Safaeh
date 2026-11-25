import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

const _groups = ValueKey('groups');
const _expenses = ValueKey('expenses');
const _expense = ValueKey('expense');
const _map = ValueKey('map');
const _profile = ValueKey('profile');

SafaehBranchNavItem _item(Key id, String label, {int depth = 0}) =>
    SafaehBranchNavItem(
      id: id,
      label: label,
      icon: Icons.circle_outlined,
      depth: depth,
      onTap: () {},
    );

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MaterialApp(
      home: Directionality(
        textDirection: dir,
        child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              child,
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

SafaehBranchSidenav _nav({
  bool inList = false,
  bool withExpense = false,
  Key? selected,
  bool collapsed = false,
  VoidCallback? onToggle,
}) => SafaehBranchSidenav(
  title: inList ? 'Personal Test' : 'Demo',
  selectedId: selected,
  collapsed: collapsed,
  onToggleCompact: onToggle,
  items: [
    _item(_groups, 'Groups'),
    if (inList) ...[
      _item(_expenses, 'Expenses', depth: 1),
      if (withExpense) _item(_expense, 'Chai', depth: 2),
      _item(_map, 'Map', depth: 1),
    ],
  ],
  pinnedItems: [_item(_profile, 'Profile')],
);

void main() {
  testWidgets('rows indent by depth', (tester) async {
    await tester.pumpWidget(_host(_nav(inList: true, withExpense: true)));
    final groups = tester.getTopLeft(find.byKey(_groups)).dx;
    final expenses = tester.getTopLeft(find.byKey(_expenses)).dx;
    final expense = tester.getTopLeft(find.byKey(_expense)).dx;
    expect(expenses - groups, 16);
    expect(expense - expenses, 16);
  });

  testWidgets('a selected depth-2 row expands its parent', (tester) async {
    await tester.pumpWidget(
      _host(_nav(inList: true, withExpense: true, selected: _expense)),
    );
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    final parent = tester.widget<Text>(
      find.descendant(
        of: find.byKey(_expenses),
        matching: find.text('Expenses'),
      ),
    );
    expect(parent.style?.fontWeight, FontWeight.w700);
    await tester.pumpWidget(_host(_nav(inList: true, selected: _map)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });

  testWidgets('context rows grow in and shrink out; the rail stays', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_nav()));
    final rail = find.byKey(const ValueKey('safaeh_branch_nav_rail'));
    final before = tester.element(rail);
    final groupsTop = tester.getTopLeft(find.byKey(_groups));
    final profileTop = tester.getTopLeft(find.byKey(_profile));

    await tester.pumpWidget(_host(_nav(inList: true)));
    await tester.pump(const Duration(milliseconds: 100));
    // Mid-insert: the new rows are there but not yet full height.
    final sizes = tester.widgetList<SizeTransition>(
      find.ancestor(
        of: find.byKey(_expenses),
        matching: find.byType(SizeTransition),
      ),
    );
    expect(sizes.first.sizeFactor.value, inExclusiveRange(0.0, 1.0));
    await tester.pumpAndSettle();
    expect(identical(tester.element(rail), before), isTrue);
    // The row that stayed did not move.
    expect(tester.getTopLeft(find.byKey(_groups)), groupsTop);
    expect(tester.getTopLeft(find.byKey(_profile)), profileTop);
    expect(find.text('Expenses'), findsOneWidget);

    await tester.pumpWidget(_host(_nav()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Expenses'), findsOneWidget); // still leaving
    await tester.pumpAndSettle();
    expect(find.text('Expenses'), findsNothing);
    expect(tester.getTopLeft(find.byKey(_profile)), profileTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the title crossfades between contexts', (tester) async {
    await tester.pumpWidget(_host(_nav()));
    await tester.pumpWidget(_host(_nav(inList: true)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Demo'), findsOneWidget);
    expect(find.text('Personal Test'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Demo'), findsNothing);
  });

  testWidgets('collapsing morphs the width and keeps pinned rows', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_nav(onToggle: () {})));
    final rail = find.byKey(const ValueKey('safaeh_branch_nav_rail'));
    expect(tester.getSize(rail).width, 240);
    expect(find.byKey(const ValueKey('safaeh_branch_nav_collapse')), findsOne);
    await tester.pumpWidget(_host(_nav(collapsed: true, onToggle: () {})));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getSize(rail).width, inExclusiveRange(72.0, 240.0));
    await tester.pumpAndSettle();
    expect(tester.getSize(rail).width, 72);
    expect(find.byKey(const ValueKey('safaeh_branch_nav_expand')), findsOne);
    expect(find.byKey(_profile), findsOneWidget);
  });

  testWidgets('taps reach the row and RTL lays out', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _host(
        SafaehBranchSidenav(
          title: 'مخطط الرحلات',
          items: [
            SafaehBranchNavItem(
              id: _groups,
              label: 'الرحلات',
              icon: Icons.luggage,
              onTap: () => tapped++,
            ),
            _item(_expenses, 'الخطة', depth: 1),
          ],
        ),
        dir: TextDirection.rtl,
      ),
    );
    await tester.tap(find.byKey(_groups));
    expect(tapped, 1);
    // Indent grows from the start (right) edge in RTL.
    final a = tester.getTopRight(find.byKey(_groups)).dx;
    final b = tester.getTopRight(find.byKey(_expenses)).dx;
    expect(a - b, 16);
    expect(tester.takeException(), isNull);
  });
}
