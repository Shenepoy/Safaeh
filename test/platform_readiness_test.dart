import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

const _forms = <String, Size>{
  'phone': Size(390, 844),
  'small phone': Size(320, 568),
  'phone landscape': Size(844, 390),
  'tablet': Size(820, 1180),
  'desktop': Size(1440, 900),
};

Widget _combined({TextDirection dir = TextDirection.ltr}) {
  final sections = [
    for (var i = 0; i < 12; i++)
      SafaehSection(id: 's$i', label: 'Section number $i', count: i),
  ];
  return Directionality(
    textDirection: dir,
    child: MaterialApp(
      home: Scaffold(
        body: SafaehSnapSheet(
          handleLabel: 'Resize',
          child: const ColoredBox(
            color: Colors.blueGrey,
            child: SizedBox.expand(),
          ),
          sheetBuilder: (context, scroll) => ListView(
            controller: scroll,
            children: [
              SafaehConnectivityBar(
                state: SafaehSyncState.offline,
                label: 'Offline — changes are saved on this device',
                retryLabel: 'Retry',
                onRetry: () {},
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: SafaehStatusIndicator(
                  state: SafaehSyncState.syncing,
                  label: 'Syncing 2 changes',
                ),
              ),
              SafaehSectionChips(
                sections: sections,
                selectedId: 's1',
                onSelected: (_) {},
                onAdd: () {},
                addLabel: 'Add',
              ),
              SizedBox(
                height: 360,
                child: SafaehTimeline<String>(
                  items: const ['A', 'B', 'C'],
                  itemKey: ValueKey.new,
                  itemBuilder: (_, s, _) =>
                      SizedBox(height: 64, child: Text('Stop $s')),
                  legBuilder: (_, s, _) =>
                      const SizedBox(height: 28, child: Text('11 min walk')),
                  onReorder: (_, _) {},
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ]) {
    for (final form in _forms.entries) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          '${form.key} on ${platform.name} at ${scale}x text has no errors',
          (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            addTearDown(() => debugDefaultTargetPlatformOverride = null);
            tester.view.physicalSize = form.value;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  size: form.value,
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: _combined(),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('RTL at tablet width has no errors', (tester) async {
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(820, 1180),
          disableAnimations: true,
        ),
        child: _combined(dir: TextDirection.rtl),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('mouse can click and drag-scroll the section chips', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? picked;
    final sections = [
      for (var i = 0; i < 20; i++) SafaehSection(id: 's$i', label: 'Item $i'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 500,
              child: SafaehSectionChips(
                sections: sections,
                selectedId: 's0',
                onSelected: (id) => picked = id,
              ),
            ),
          ),
        ),
      ),
    );
    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(
      mouse.hover(tester.getCenter(find.text('Item 1'))),
    );
    await tester.tap(find.text('Item 1'));
    expect(picked, 's1');
    expect(find.text('Item 15'), findsNothing);
    await tester.dragFrom(
      const Offset(300, 22),
      const Offset(-400, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Item 5'), findsOneWidget);
  });

  testWidgets('keyboard can activate a chip and cycle the snap sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final seen = <int>[];
    String? picked;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          disableAnimations: true,
        ),
        child: MaterialApp(
          home: Scaffold(
            body: SafaehSnapSheet(
              onSnapChanged: seen.add,
              handleLabel: 'Resize',
              child: const SizedBox.expand(),
              sheetBuilder: (context, scroll) => ListView(
                controller: scroll,
                children: [
                  SafaehSectionChips(
                    sections: const [
                      SafaehSection(id: 'a', label: 'Alpha'),
                      SafaehSection(id: 'b', label: 'Beta'),
                    ],
                    selectedId: 'a',
                    onSelected: (id) => picked = id,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Handle first in focus order: Enter cycles to the next snap point.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(seen, isNotEmpty);
    // Next focus stop is the first chip, then the second.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked, 'b');
  });

  testWidgets('keyboard Alt+Down moves a timeline stop', (tester) async {
    final moves = <(int, int)>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: SafaehTimeline<String>(
              items: const ['A', 'B', 'C'],
              itemKey: ValueKey.new,
              itemBuilder: (_, s, _) =>
                  SizedBox(height: 60, child: Text('Stop $s')),
              onReorder: (o, n) => moves.add((o, n)),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    expect(moves, [(0, 1)]);
  });
}
