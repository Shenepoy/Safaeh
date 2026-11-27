import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  Future<void> open(
    WidgetTester tester,
    void Function(BuildContext) show, {
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            Directionality(textDirection: direction, child: child!),
        home: SafaehContentInset(
          start: 240,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a wide sheet centers beside the inset, not in the window', (
    tester,
  ) async {
    await open(
      tester,
      (c) => showSafaeh<void>(
        context: c,
        title: 'Sheet',
        child: const SizedBox(height: 120),
      ),
    );
    final panel = tester.getRect(find.byKey(const ValueKey('safaeh_panel')));
    // The page is x 240..1400, so its middle is 820.
    expect(panel.center.dx, moreOrLessEquals(820, epsilon: 1));
  });

  testWidgets('in RTL the inset is on the right', (tester) async {
    await open(
      tester,
      (c) => showSafaeh<void>(
        context: c,
        title: 'Sheet',
        child: const SizedBox(height: 120),
      ),
      direction: TextDirection.rtl,
    );
    final panel = tester.getRect(find.byKey(const ValueKey('safaeh_panel')));
    expect(panel.center.dx, moreOrLessEquals(580, epsilon: 1));
  });

  testWidgets('a dialog centers beside the inset too', (tester) async {
    await open(
      tester,
      (c) => showSafaehDialog<void>(
        context: c,
        builder: (_) => const SizedBox(
          key: ValueKey('body'),
          width: 300,
          height: 100,
        ),
      ),
    );
    final body = tester.getRect(find.byKey(const ValueKey('body')));
    expect(body.center.dx, moreOrLessEquals(820, epsilon: 1));
  });
}
