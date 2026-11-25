import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('crossfades titles and clamps the action page', (tester) async {
    final actionPages = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: SafaehMorphingAppBar(
            page: 99,
            titles: const [Text('Home'), Text('Settings')],
            leading: const SizedBox(width: kToolbarHeight),
            actionsBuilder: (context, page) {
              actionPages.add(page);
              return const SizedBox.shrink();
            },
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Home'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
    expect(actionPages, [1]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: SafaehMorphingAppBar(
            page: 0.5,
            titles: const [Text('Home'), Text('Settings')],
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.text('Home'),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      closeTo(0.5, 0.001),
    );
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.text('Settings'),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      closeTo(0.5, 0.001),
    );
  });

  testWidgets('keeps the title centered while actions morph', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const titleKey = ValueKey('morphing-title');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: SafaehMorphingAppBar(
            page: 0,
            titles: [Text('Centered', key: titleKey)],
            leading: SizedBox(width: kToolbarHeight),
            actionsBuilder: _actionBuilder,
          ),
          body: SizedBox.shrink(),
        ),
      ),
    );

    expect(tester.getCenter(find.byKey(titleKey)).dx, closeTo(400, 1));
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('page-aware actions fade and stop accepting input', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SafaehMorphingAppBarAction(
              page: 0.25,
              targetPage: 0,
              child: SizedBox(key: ValueKey('action')),
            ),
          ),
        ),
      ),
    );

    final action = find.byKey(const ValueKey('action'));
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: action, matching: find.byType(Opacity)).first,
          )
          .opacity,
      0.75,
    );
    expect(
      tester
          .widget<IgnorePointer>(
            find
                .ancestor(of: action, matching: find.byType(IgnorePointer))
                .first,
          )
          .ignoring,
      isFalse,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SafaehMorphingAppBarAction(
              page: 1,
              targetPage: 0,
              child: SizedBox(key: ValueKey('action')),
            ),
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: action, matching: find.byType(Opacity)).first,
          )
          .opacity,
      0,
    );
    expect(
      tester
          .widget<IgnorePointer>(
            find
                .ancestor(of: action, matching: find.byType(IgnorePointer))
                .first,
          )
          .ignoring,
      isTrue,
    );
  });

  test('morphing bottom reports its visible height', () {
    const bottom = SafaehMorphingAppBarBottom(
      factor: 0.5,
      height: 80,
      child: SizedBox.shrink(),
    );
    expect(bottom.preferredSize.height, 40);

    const hidden = SafaehMorphingAppBarBottom(
      factor: 2,
      height: 80,
      child: SizedBox.shrink(),
    );
    expect(hidden.preferredSize.height, 80);
  });

  testWidgets('a partially faded action leaves focus and semantics', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    Future<void> showAction(double page) => tester.pumpWidget(
      MaterialApp(
        home: SafaehMorphingAppBarAction(
          page: page,
          targetPage: 0,
          child: Focus(
            focusNode: node,
            child: Semantics(
              label: 'Open search',
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    await showAction(0.25);
    node.requestFocus();
    await tester.pump();
    expect(node.hasFocus, isTrue);
    expect(find.semantics.byLabel('Open search'), findsOne);

    await showAction(0.75);
    await tester.pump();
    expect(node.canRequestFocus, isFalse);
    expect(node.hasFocus, isFalse);
    expect(find.semantics.byLabel('Open search'), findsNothing);
  });
}

Widget _actionBuilder(BuildContext context, double page) =>
    const SizedBox.shrink();
