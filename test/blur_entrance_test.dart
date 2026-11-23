import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh/src/floating_surface_renderer.dart';

double blurSigma(WidgetTester tester) {
  final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
  return double.parse(
    RegExp(r'blur\(([^,]+),')
        .firstMatch(filter.filter!.debugShortDescription)![1]!,
  );
}

void main() {
  testWidgets('reduced motion uses full blur immediately', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SafaehBackdropFilter(
            sigmaX: 12,
            sigmaY: 12,
            child: Text('Readable'),
          ),
        ),
      ),
    );
    expect(blurSigma(tester), 12);
    expect(find.text('Readable'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SafaehBackdropFilter),
        matching: find.byType(TweenAnimationBuilder<Offset>),
      ),
      findsNothing,
    );
  });

  testWidgets('mounted glass fades its blur without fading the content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SafaehFloatingSurface(
            appearance: SafaehFloatingAppearance.tunedGlass(),
            fallbackColor: Colors.white,
            child: SizedBox(width: 180, height: 120),
          ),
        ),
      ),
    );
    expect(blurSigma(tester), 0);
    await tester.pump(const Duration(milliseconds: 40));
    expect(blurSigma(tester), allOf(greaterThan(0), lessThan(12)));
    await tester.pumpAndSettle();
    expect(blurSigma(tester), 12);
  });

  testWidgets('blur frames retain the foreground painting', (tester) async {
    final painter = _CountingPainter();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SafaehBackdropFilter(
            sigmaX: 12,
            sigmaY: 12,
            child: CustomPaint(size: const Size(180, 120), painter: painter),
          ),
        ),
      ),
    );
    final initialPaints = painter.paints;
    expect(initialPaints, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 40));
    expect(blurSigma(tester), allOf(greaterThan(0), lessThan(12)));
    await tester.pumpAndSettle();
    expect(painter.paints, initialPaints);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('sheet blur fades after route entrance on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaeh<void>(
                context: context,
                title: 'Glass',
                floatingAppearance: const SafaehFloatingAppearance.tunedGlass(),
                child: const Text('Content'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(blurSigma(tester), 0);
      final route = ModalRoute.of(tester.element(find.text('Content')))!;
      while (route.animation!.status != AnimationStatus.completed) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(blurSigma(tester), 0);
      await tester.pump(const Duration(milliseconds: 40));
      expect(blurSigma(tester), allOf(greaterThan(0), lessThan(12)));
      await tester.pumpAndSettle();
      expect(blurSigma(tester), 12);
      Navigator.of(tester.element(find.text('Content'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Content'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dismissal during blur fade disposes safely', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    showSafaeh<void>(
      context: context,
      title: 'Glass',
      floatingAppearance: const SafaehFloatingAppearance.tunedGlass(),
      child: const Text('Content'),
    );
    await tester.pump();
    final route = ModalRoute.of(tester.element(find.text('Content')))!;
    while (route.animation!.status != AnimationStatus.completed) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pump(const Duration(milliseconds: 40));
    expect(blurSigma(tester), allOf(greaterThan(0), lessThan(12)));
    Navigator.of(tester.element(find.text('Content'))).pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _CountingPainter extends CustomPainter {
  int paints = 0;

  @override
  void paint(Canvas canvas, Size size) {
    paints++;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.green);
  }

  @override
  bool shouldRepaint(_CountingPainter oldDelegate) => false;
}
