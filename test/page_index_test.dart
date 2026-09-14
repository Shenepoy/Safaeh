import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('SafaehPageIndex lists entries and reports selection', (
    tester,
  ) async {
    final alpha = GlobalKey();
    final beta = GlobalKey();
    String? active = 'alpha';
    final entries = [
      SafaehPageIndexEntry(id: 'alpha', label: 'Alpha', key: alpha),
      SafaehPageIndexEntry(id: 'beta', label: 'Beta', key: beta),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SafaehPageIndex(
                title: 'On this page',
                entries: entries,
                activeId: active,
                onSelect: (entry) => setState(() => active = entry.id),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('On this page'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Alpha')),
      isSemantics(isButton: true, isSelected: true),
    );
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(active, 'beta');
  });

  testWidgets('page index entry labelBuilder is used', (tester) async {
    final alpha = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehPageIndex(
            title: 'On this page',
            activeId: 'alpha',
            onSelect: (_) {},
            entries: [
              SafaehPageIndexEntry(
                id: 'alpha',
                label: 'Alpha',
                key: alpha,
                labelBuilder: (data, style) =>
                    Text('built-$data', style: style),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('built-Alpha'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('page index entry icon is shown', (tester) async {
    final alpha = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehPageIndex(
            title: 'On this page',
            activeId: 'alpha',
            onSelect: (_) {},
            entries: [
              SafaehPageIndexEntry(
                id: 'alpha',
                label: 'Alpha',
                key: alpha,
                icon: Icons.tag,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.tag), findsOneWidget);
  });

  testWidgets('SafaehPageIndexOverlay opens the panel', (tester) async {
    final alpha = GlobalKey();
    final entries = [
      SafaehPageIndexEntry(id: 'alpha', label: 'Alpha section', key: alpha),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              SafaehPageIndexOverlay(
                title: 'On this page',
                entries: entries,
                activeId: 'alpha',
                onSelect: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Alpha section'), findsOneWidget);
    await tester.tap(find.text('On this page').first);
    await tester.pumpAndSettle();
    expect(find.text('Alpha section'), findsWidgets);
  });

  testWidgets('scrollToPageSection reveals a section key', (tester) async {
    final target = GlobalKey();

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 900, child: Text('above')),
                SizedBox(
                  key: target,
                  height: 80,
                  child: const Text('section-z'),
                ),
                const SizedBox(height: 500),
              ],
            ),
          ),
        ),
      ),
    );

    final before = tester.getTopLeft(find.text('section-z')).dy;
    expect(before, greaterThan(800));

    await scrollToPageSection(target, ensureDuration: Duration.zero);
    await tester.pump();
    expect(find.text('section-z'), findsOneWidget);
    final after = tester.getTopLeft(find.text('section-z')).dy;
    expect(after, lessThan(before - 400));
  });

  testWidgets('scrollToPageSection does not move an outer scrollable', (
    tester,
  ) async {
    final target = GlobalKey();
    final outer = ScrollController();
    final inner = ScrollController();
    addTearDown(outer.dispose);
    addTearDown(inner.dispose);

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: outer,
            children: [
              const SizedBox(height: 400, child: Text('outer-top')),
              SizedBox(
                height: 280,
                child: ListView(
                  controller: inner,
                  children: [
                    const SizedBox(height: 200, child: Text('inner-a')),
                    SizedBox(
                      key: target,
                      height: 200,
                      child: const Text('inner-b'),
                    ),
                    const SizedBox(height: 200, child: Text('inner-c')),
                  ],
                ),
              ),
              const SizedBox(height: 800, child: Text('outer-bottom')),
            ],
          ),
        ),
      ),
    );

    expect(outer.offset, 0);
    expect(inner.offset, 0);
    await scrollToPageSection(
      target,
      controller: inner,
      ensureDuration: Duration.zero,
    );
    await tester.pump();
    expect(outer.offset, 0);
    expect(inner.offset, greaterThan(0));
  });

  testWidgets('safaehActivePageSectionId follows the viewport', (tester) async {
    final alpha = GlobalKey();
    final beta = GlobalKey();
    final scrollKey = GlobalKey();
    final controller = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            key: scrollKey,
            controller: controller,
            children: [
              SizedBox(key: alpha, height: 400, child: const Text('A')),
              SizedBox(key: beta, height: 400, child: const Text('B')),
              const SizedBox(height: 800),
            ],
          ),
        ),
      ),
    );

    final scrollContext = tester.element(find.byKey(scrollKey));
    expect(
      safaehActivePageSectionId(
        sections: [('alpha', alpha), ('beta', beta)],
        scrollContext: scrollContext,
      ),
      'alpha',
    );

    controller.jumpTo(360);
    await tester.pumpAndSettle();
    expect(
      safaehActivePageSectionId(
        sections: [('alpha', alpha), ('beta', beta)],
        scrollContext: scrollContext,
        activationOffset: 96,
      ),
      'beta',
    );
  });

  testWidgets('empty page index and overlay shrink away', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SafaehPageIndex(
                title: 'On this page',
                entries: [],
                activeId: null,
                onSelect: _noopSelect,
              ),
              Expanded(
                child: SafaehPageIndexOverlay(
                  title: 'On this page',
                  entries: [],
                  activeId: null,
                  onSelect: _noopSelect,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('On this page'), findsNothing);
  });

  testWidgets('active index marker is on the start edge in RTL', (
    tester,
  ) async {
    final alpha = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SafaehPageIndex(
              title: 'On this page',
              entries: [
                SafaehPageIndexEntry(id: 'alpha', label: 'Alpha', key: alpha),
              ],
              activeId: 'alpha',
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    );

    final box = tester.widget<Container>(
      find
          .ancestor(of: find.text('Alpha'), matching: find.byType(Container))
          .first,
    );
    expect(box.decoration, isA<BoxDecoration>());
    final border = (box.decoration! as BoxDecoration).border;
    expect(border, isA<BorderDirectional>());
    final start = (border! as BorderDirectional).start;
    expect(start.width, 2.5);
    expect(start.color, isNot(equals(Colors.transparent)));
  });

  testWidgets('scrollToPageSection zeros motion when animations are disabled', (
    tester,
  ) async {
    final target = GlobalKey();
    Duration? resolved;

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          );
        },
        home: Scaffold(
          body: Builder(
            builder: (context) {
              resolved = safaehResolvedMotion(
                context,
                const Duration(milliseconds: 280),
              );
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 900, child: Text('above')),
                    SizedBox(
                      key: target,
                      height: 80,
                      child: const Text('section-z'),
                    ),
                    const SizedBox(height: 500),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(resolved, Duration.zero);
    final before = tester.getTopLeft(find.text('section-z')).dy;
    expect(before, greaterThan(800));

    await scrollToPageSection(
      target,
      ensureDuration: const Duration(milliseconds: 280),
    );
    await tester.pump();
    expect(find.text('section-z'), findsOneWidget);
    final after = tester.getTopLeft(find.text('section-z')).dy;
    expect(after, lessThan(before - 400));
  });
}

void _noopSelect(SafaehPageIndexEntry entry) {}
