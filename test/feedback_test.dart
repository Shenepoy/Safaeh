import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';
import 'package:toastification/toastification.dart';

void main() {
  tearDown(() {
    // The underlying toast manager is a singleton shared by widget tests.
    toastification.dismissAll(delayForAnimation: false);
  });

  testWidgets('feedback host renders shared messages and actions', (
    tester,
  ) async {
    var actionCount = 0;
    await tester.pumpWidget(
      SafaehFeedbackHost(
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showSafaehFeedbackWithAction(
                'Deleted',
                actionLabel: 'Undo',
                onAction: () => actionCount++,
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Deleted', skipOffstage: false), findsOneWidget);
    expect(find.text('Undo', skipOffstage: false), findsOneWidget);
    await tester.tap(find.text('Undo', skipOffstage: false));
    expect(actionCount, 1);
    await tester.pumpAndSettle();
    expect(find.text('Deleted', skipOffstage: false), findsNothing);
  });

  testWidgets('custom feedback receives a dismissal callback', (tester) async {
    await tester.pumpWidget(
      SafaehFeedbackHost(
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showSafaehCustomFeedback(
                builder: (context, dismiss) => TextButton(
                  onPressed: dismiss,
                  child: const Text('Close feedback'),
                ),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Close feedback', skipOffstage: false), findsOneWidget);

    await tester.tap(find.text('Close feedback', skipOffstage: false));
    await tester.pumpAndSettle();
    expect(find.text('Close feedback', skipOffstage: false), findsNothing);
  });

  testWidgets('feedback dismisses on a swipe in any direction', (tester) async {
    Future<void> show(WidgetTester tester) async {
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Swipe me'), findsOneWidget);
    }

    await tester.pumpWidget(
      SafaehFeedbackHost(
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showSafaehFeedback('Swipe me'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    for (final delta in const [
      Offset(-80, 0),
      Offset(80, 0),
      Offset(0, -80),
      Offset(0, 80),
    ]) {
      await show(tester);
      await tester.drag(find.text('Swipe me'), delta);
      await tester.pumpAndSettle();
      expect(find.text('Swipe me', skipOffstage: false), findsNothing);
    }

    await show(tester);
    await tester.timedDrag(
      find.text('Swipe me'),
      const Offset(20, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    expect(find.text('Swipe me', skipOffstage: false), findsOneWidget);
  });

  testWidgets('removing the host cancels feedback timers', (tester) async {
    await tester.pumpWidget(
      SafaehFeedbackHost(
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showSafaehFeedback('Stay'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pump();
    expect(toastification.managers.values, isNotEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(
      toastification.managers.values.every(
        (manager) => manager.notifications.isEmpty,
      ),
      isTrue,
    );
  });

  testWidgets('a toast shown above the navigator still closes', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) => SafaehFeedbackHost(
          itemWidthBuilder: (context) => MediaQuery.sizeOf(context).width,
          child: Builder(
            builder: (context) {
              hostContext = context;
              return child ?? const SizedBox.shrink();
            },
          ),
        ),
        home: const Text('Home'),
      ),
    );

    hostContext.showSafaehFeedback(
      'Meter not found',
      type: SafaehFeedbackType.error,
      duration: const Duration(seconds: 4),
    );
    // The close timer used to start before the toast was inserted. Elapsing
    // that whole duration on the first frame (no draw while a scan finishes
    // in the background) left the toast on screen forever.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Meter not found', skipOffstage: false), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Meter not found', skipOffstage: false), findsNothing);
  });

  testWidgets('feedback closes itself after its duration', (tester) async {
    await tester.pumpWidget(
      SafaehFeedbackHost(
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showSafaehFeedback(
                'Meter not found',
                type: SafaehFeedbackType.error,
                duration: const Duration(seconds: 4),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Meter not found', skipOffstage: false), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Meter not found', skipOffstage: false), findsNothing);
  });

  testWidgets('relayout while a toast is open still lets it close', (
    tester,
  ) async {
    final relayout = ValueNotifier<int>(0);
    addTearDown(relayout.dispose);
    await tester.pumpWidget(
      SafaehFeedbackHost(
        relayout: relayout,
        itemWidthBuilder: (context) =>
            MediaQuery.sizeOf(context).width - relayout.value,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showSafaehFeedback(
                'Meter not found',
                type: SafaehFeedbackType.error,
                duration: const Duration(seconds: 4),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    relayout.value = 96;
    await tester.pump();
    expect(find.text('Meter not found', skipOffstage: false), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Meter not found', skipOffstage: false), findsNothing);
  });

  testWidgets('relayout drops an idle manager', (tester) async {
    final relayout = ValueNotifier<int>(0);
    addTearDown(relayout.dispose);
    await tester.pumpWidget(
      SafaehFeedbackHost(
        relayout: relayout,
        bottomInsetBuilder: (_) => relayout.value * 40,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showSafaehFeedback('Moved'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pump();
    relayout.value = 1;
    await tester.pump();
    expect(find.text('Moved', skipOffstage: false), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
