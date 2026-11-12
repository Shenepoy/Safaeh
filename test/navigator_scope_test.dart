import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  for (final local in [false, true]) {
    testWidgets('anchored route respects local scope $local', (tester) async {
      final root = GlobalKey<NavigatorState>();
      final nested = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: root,
          home: SafaehNavigatorScope(
            useRootNavigator: !local,
            child: Navigator(
              key: nested,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showSafaehAnchored<void>(
                      context: context,
                      motion: SafaehAnchoredMotion.fadeScale,
                      child: const Text('Scoped popout'),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        Navigator.of(tester.element(find.text('Scoped popout'))),
        same(local ? nested.currentState : root.currentState),
      );
      (local ? nested : root).currentState!.pop();
      await tester.pumpAndSettle();
    });

    testWidgets('feedback overlay respects local scope $local', (tester) async {
      final root = GlobalKey<NavigatorState>();
      final nested = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        SafaehFeedbackHost(
          child: MaterialApp(
            navigatorKey: root,
            home: SafaehNavigatorScope(
              useRootNavigator: !local,
              child: Navigator(
                key: nested,
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () =>
                          context.showSafaehFeedback('Scoped feedback'),
                      child: const Text('Show'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        Overlay.of(tester.element(find.byType(SafaehFeedbackSurface))),
        same((local ? nested : root).currentState!.overlay),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
