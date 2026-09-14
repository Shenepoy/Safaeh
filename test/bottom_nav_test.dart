import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('bottom-nav metrics separate visual and content clearance', (
    tester,
  ) async {
    late SafaehBottomNavMetrics metrics;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            metrics = SafaehBottomNavMetrics.fromContext(
              context,
              visible: true,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(metrics.visible, isTrue);
    expect(metrics.visualInset, 80);
    expect(metrics.contentInset, 112);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    expect(metrics.visible, isFalse);
    expect(metrics.visualInset, 0);
    expect(metrics.contentInset, 0);
  });

  testWidgets('scope supplies metrics to page-index overlays', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sectionKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: SafaehBottomNavScope(
          child: Stack(
            children: [
              const SizedBox.expand(),
              SafaehPageIndexOverlay(
                title: 'On this page',
                entries: [
                  SafaehPageIndexEntry(
                    id: 'section',
                    label: 'Section',
                    key: sectionKey,
                  ),
                ],
                activeId: 'section',
                onSelect: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    final trigger = find.byIcon(Icons.list_alt_rounded);
    expect(trigger, findsOneWidget);
    final triggerRect = tester.getRect(trigger);
    expect(triggerRect.bottom, lessThan(800 - 72));
  });

  testWidgets('keyboard-aware nav removes its child while the IME is visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SafaehKeyboardAwareNav(child: Text('nav'))),
    );
    expect(find.text('nav'), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(find.text('nav'), findsNothing);
  });
}
