import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final brightness in Brightness.values) {
      testWidgets('$platform $brightness glass sheet transition', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSafaeh<void>(
                  context: context,
                  title: 'Status',
                  floatingAppearance:
                      const SafaehFloatingAppearance.tunedGlass(),
                  child: const Text('sheet-body'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pump();

        final panel = find.byKey(const ValueKey('safaeh_panel'));
        final startingTop = tester.getTopLeft(panel).dy;
        expect(startingTop, greaterThanOrEqualTo(800));
        await tester.pump(const Duration(milliseconds: 100));
        final fadingAncestors = find.ancestor(
          of: panel,
          matching: find.byWidgetPredicate((widget) {
            final opacity = switch (widget) {
              Opacity() => widget.opacity,
              FadeTransition() => widget.opacity.value,
              _ => 1.0,
            };
            return opacity > 0 && opacity < 1;
          }),
        );
        final expectedFade = platform == TargetPlatform.android
            ? findsNothing
            : findsOneWidget;
        expect(fadingAncestors, expectedFade);
        expect(tester.getTopLeft(panel).dy, lessThan(startingTop));
        expect(
          find.descendant(of: panel, matching: find.byType(BackdropFilter)),
          findsOneWidget,
          reason: 'Keep the frosted surface throughout the transition',
        );
        await tester.pumpAndSettle();
        expect(tester.getBottomLeft(panel).dy, closeTo(800, 1));

        Navigator.of(tester.element(find.text('sheet-body'))).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(fadingAncestors, expectedFade);
        await tester.pumpAndSettle();
        expect(panel, findsNothing);
      });
    }
  }

  testWidgets('host slideUp still controls the phone transition', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              slideUp: ({required animation, required child}) => FadeTransition(
                key: const ValueKey('host-transition'),
                opacity: animation,
                child: child,
              ),
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final transition = tester.widget<FadeTransition>(
      find.byKey(const ValueKey('host-transition')),
    );
    expect(transition.opacity.value, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
  });
}
