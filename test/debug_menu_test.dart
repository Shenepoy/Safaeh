import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('showSafaehDebugMenu lists host sections', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehDebugMenu(
                context,
                title: 'Debug',
                identity: const SafaehDebugIdentityCard(
                  package: 'demo',
                  version: '1.0.0',
                  chips: ['Debug'],
                ),
                sections: [
                  SafaehDebugSection(
                    title: 'Tools',
                    icon: Icons.build_outlined,
                    initiallyExpanded: true,
                    children: [
                      SafaehDebugActionTile(
                        icon: Icons.refresh,
                        label: 'Reload',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
                statusMessage: 'Ready',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Debug console'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('debug host ignores a short drag and clamps a long-press drag', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehDebugMenuHost(
          onOpen: _noopOpen,
          child: const SizedBox.expand(),
        ),
      ),
    );

    final fab = find.byType(FloatingActionButton);
    final before = tester.getTopLeft(fab);
    expect(before, const Offset(8, 664));

    final movedBeforeHold = await tester.startGesture(tester.getCenter(fab));
    await movedBeforeHold.moveBy(const Offset(24, 12));
    await movedBeforeHold.up();
    await tester.pump();
    expect(tester.getTopLeft(fab), before);

    final held = await tester.startGesture(tester.getCenter(fab));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await held.moveBy(const Offset(2000, 2000));
    await tester.pump();
    await held.up();
    await tester.pump();

    final after = tester.getTopLeft(fab);
    expect(after, isNot(before));
    expect(after.dx, inInclusiveRange(8, 400 - 8 - 40));
    expect(after.dy, inInclusiveRange(8, 800 - 8 - 40));
  });

  testWidgets('debug host hides the button until open finishes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final gate = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: SafaehDebugMenuHost(
          onOpen: () => gate.future,
          child: const SizedBox.expand(),
        ),
      ),
    );

    final before = tester.getTopLeft(find.byType(FloatingActionButton));
    await tester.tap(find.byType(SafaehDebugMenuFab), warnIfMissed: false);
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsNothing);

    gate.complete();
    await tester.pump();
    await tester.pump();
    expect(tester.getTopLeft(find.byType(FloatingActionButton)), before);
  });

  testWidgets(
    'debug host shows the button again when open returns immediately',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: SafaehDebugMenuHost(
            onOpen: () async => opened += 1,
            child: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.byType(SafaehDebugMenuFab), warnIfMissed: false);
      await tester.pump();
      expect(opened, 1);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );

  testWidgets('debug host fills a loosely sized box', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previous);
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 390,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 160,
                child: SafaehDebugMenuHost(
                  onOpen: _noopOpen,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Host-registered sections'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(errors, isEmpty);
    expect(find.text('Host-registered sections'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  test('SafaehL10nOverrideStore reverse-looks up keys', () {
    final store = SafaehL10nOverrideStore(locales: const ['en', 'ar']);
    store.setBundled('en', {'hello': 'Hello', 'bye': 'Goodbye {name}'});
    expect(store.findKeysForText('Hello', 'en'), ['hello']);
    expect(store.findKeysForText('Goodbye Ada', 'en'), ['bye']);
    store.set('en', 'hello', 'Hi');
    expect(store.exportJson(), contains('"hello": "Hi"'));
  });
}

Future<void> _noopOpen() async {}
