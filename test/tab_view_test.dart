import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

Widget host(
  List<Widget> children, {
  TabController? controller,
  bool reduced = false,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: DefaultTabController(
      length: children.length,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TabBar(
                controller: controller,
                tabs: [
                  for (var i = 0; i < children.length; i++) Tab(text: 'Tab $i'),
                ],
              ),
              SafaehTabView(controller: controller, children: children),
            ],
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('fits scrollable content and animates between unequal heights', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const [SizedBox(height: 80), SizedBox(height: 240)]),
    );
    final view = find.byType(SafaehTabView);
    expect(tester.getSize(view).height, 80);
    await tester.tap(find.text('Tab 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.getSize(view).height, greaterThan(80));
    expect(tester.getSize(view).height, lessThan(240));
    await tester.pumpAndSettle();
    expect(tester.getSize(view).height, 240);
    await tester.tap(find.text('Tab 0'));
    await tester.pumpAndSettle();
    expect(tester.getSize(view).height, 80);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'retains edited fields and excludes inactive focus and semantics',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        host([
          TextField(
            focusNode: focus,
            decoration: const InputDecoration(labelText: 'First form'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Second form'),
          ),
        ]),
      );
      await tester.enterText(find.byType(TextField), 'Keep this draft');
      expect(focus.hasFocus, isTrue);
      final tabs = DefaultTabController.of(
        tester.element(find.byType(SafaehTabView)),
      );
      tabs.animateTo(1);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isFalse);
      expect(focus.canRequestFocus, isFalse);
      expect(find.bySemanticsLabel('First form'), findsNothing);
      expect(find.bySemanticsLabel('Second form'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Second draft');
      tabs.animateTo(0);
      await tester.pumpAndSettle();
      expect(find.text('Keep this draft'), findsOneWidget);
      expect(find.text('Second draft'), findsNothing);
      expect(focus.canRequestFocus, isTrue);
      semantics.dispose();
    },
  );

  testWidgets('inactive children have tickers disabled', (tester) async {
    final enabled = <int, bool>{};
    await tester.pumpWidget(
      host([
        for (var i = 0; i < 2; i++)
          Builder(
            builder: (context) {
              enabled[i] = TickerMode.valuesOf(context).enabled;
              return const SizedBox(height: 40);
            },
          ),
      ]),
    );
    expect(enabled, {0: true, 1: false});
    await tester.tap(find.text('Tab 1'));
    await tester.pumpAndSettle();
    expect(enabled, {0: false, 1: true});
  });

  testWidgets('reduced motion resizes immediately', (tester) async {
    await tester.pumpWidget(
      host(const [SizedBox(height: 80), SizedBox(height: 240)], reduced: true),
    );
    await tester.tap(find.text('Tab 1'));
    await tester.pump();
    expect(tester.getSize(find.byType(SafaehTabView)).height, 240);
  });

  testWidgets('responds to content changing height within the active tab', (
    tester,
  ) async {
    final expanded = ValueNotifier(false);
    addTearDown(expanded.dispose);
    await tester.pumpWidget(
      host([
        ValueListenableBuilder<bool>(
          valueListenable: expanded,
          builder: (_, value, _) => SizedBox(height: value ? 180 : 60),
        ),
        const SizedBox(height: 100),
      ]),
    );
    expanded.value = true;
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SafaehTabView)).height, 180);
  });

  testWidgets('replaces external controller and handles rapid changes', (
    tester,
  ) async {
    final first = TabController(length: 3, vsync: tester);
    final second = TabController(length: 3, vsync: tester, initialIndex: 2);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    const children = [
      SizedBox(height: 60),
      SizedBox(height: 120),
      SizedBox(height: 180),
    ];
    await tester.pumpWidget(host(children, controller: first));
    first.animateTo(1);
    await tester.pump();
    first.animateTo(2);
    await tester.pump(const Duration(milliseconds: 30));
    first.animateTo(0);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SafaehTabView)).height, 60);
    await tester.pumpWidget(host(children, controller: second));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SafaehTabView)).height, 180);
    first.animateTo(1);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SafaehTabView)).height, 180);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stable keys retain state when tabs reorder', (tester) async {
    const a = TextField(key: ValueKey('a'));
    const b = TextField(key: ValueKey('b'));
    await tester.pumpWidget(host([a, b]));
    await tester.enterText(find.byType(TextField), 'Draft A');
    await tester.pumpWidget(host([b, a]));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tab 1'));
    await tester.pumpAndSettle();
    expect(find.text('Draft A'), findsOneWidget);
  });
  testWidgets('changing reduced motion preserves the current draft', (
    tester,
  ) async {
    const fields = [TextField(), TextField()];
    await tester.pumpWidget(host(fields));
    await tester.enterText(find.byType(TextField), 'Persistent draft');
    await tester.pumpWidget(host(fields, reduced: true));
    await tester.pumpAndSettle();
    expect(find.text('Persistent draft'), findsOneWidget);
    await tester.pumpWidget(host(fields));
    await tester.pumpAndSettle();
    expect(find.text('Persistent draft'), findsOneWidget);
  });
  testWidgets('accepts globally keyed forms without duplicating their keys', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      host([
        Form(key: formKey, child: TextFormField()),
        const SizedBox(height: 80),
      ]),
    );
    final initial = formKey.currentState;
    await tester.tap(find.text('Tab 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tab 0'));
    await tester.pumpAndSettle();
    expect(formKey.currentState, same(initial));
    expect(tester.takeException(), isNull);
  });
}
