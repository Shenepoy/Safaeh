import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  test('safaehBandMetrics centers a capped band', () {
    final metrics = safaehBandMetrics(contentAreaWidth: 1000, maxWidth: 600);
    expect(metrics.bandWidth, 600);
    expect(metrics.leftOffset, 200);
    expect(metrics.endFree, 200);
  });

  test('safaehBandMetrics honors reservedStartWidth', () {
    final metrics = safaehBandMetrics(
      contentAreaWidth: 1000,
      maxWidth: 600,
      reservedStartWidth: 80,
    );
    expect(metrics.bandWidth, 600);
    expect(metrics.leftOffset, 240);
    expect(metrics.endFree, 160);
  });

  test('safaehBandMetrics fills when narrower than maxWidth', () {
    final metrics = safaehBandMetrics(contentAreaWidth: 400, maxWidth: 600);
    expect(metrics.bandWidth, 400);
    expect(metrics.leftOffset, 0);
    expect(metrics.endFree, 0);
  });

  testWidgets('SafaehEndAsideLayout shows aside when endFree is wide', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 900,
          height: 400,
          child: SafaehEndAsideLayout(
            leftOffset: 80,
            bandWidth: 400,
            endFree: 300,
            aside: Text('aside-here'),
            child: Text('band-body'),
          ),
        ),
      ),
    );

    expect(find.text('band-body'), findsOneWidget);
    expect(find.text('aside-here'), findsOneWidget);
  });

  testWidgets('SafaehEndAsideLayout places aside before the band in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 900,
          height: 400,
          child: SafaehEndAsideLayout(
            leftOffset: 200,
            bandWidth: 400,
            endFree: 300,
            isRtl: true,
            asideWidth: 200,
            aside: Text('aside-here'),
            child: Text('band-body'),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('aside-here')).dx,
      lessThan(tester.getTopLeft(find.text('band-body')).dx),
    );
  });

  testWidgets('SafaehEndAsideLayout hides aside when endFree is tight', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 600,
          height: 400,
          child: SafaehEndAsideLayout(
            leftOffset: 40,
            bandWidth: 400,
            endFree: 80,
            aside: Text('aside-here'),
            child: Text('band-body'),
          ),
        ),
      ),
    );

    expect(find.text('band-body'), findsOneWidget);
    expect(find.text('aside-here'), findsNothing);
  });

  testWidgets('SafaehContentAlignedAppBar places title in the band', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const titleKey = Key('aligned-title');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: SafaehContentAlignedAppBar(
            leftOffset: 100,
            bandWidth: 400,
            title: Text('Band title', key: titleKey),
          ),
          body: SizedBox.shrink(),
        ),
      ),
    );

    final titleCenter = tester.getCenter(find.byKey(titleKey));
    expect(titleCenter.dx, closeTo(300, 1));
  });

  testWidgets('SafaehContentAlignedFabLocation equals on same metrics', (
    tester,
  ) async {
    const a = SafaehContentAlignedFabLocation(
      leftOffset: 120,
      bandWidth: 480,
      textDirection: TextDirection.ltr,
    );
    const b = SafaehContentAlignedFabLocation(
      leftOffset: 120,
      bandWidth: 480,
      textDirection: TextDirection.ltr,
    );
    const c = SafaehContentAlignedFabLocation(
      leftOffset: 80,
      bandWidth: 480,
      textDirection: TextDirection.ltr,
    );
    expect(a, equals(b));
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(equals(c)));

    expect(
      SafaehContentAlignedFabLocation.resolve(
        leftOffset: 0,
        bandWidth: 400,
        endFree: 40,
        textDirection: TextDirection.ltr,
      ),
      FloatingActionButtonLocation.endFloat,
    );
  });

  testWidgets(
    'safaehResolvedMotion is Duration.zero when animations are disabled',
    (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true, size: Size(400, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox.shrink(),
          ),
        ),
      );
      final context = tester.element(find.byType(SizedBox));
      expect(
        safaehResolvedMotion(context, const Duration(milliseconds: 320)),
        Duration.zero,
      );
    },
  );

  testWidgets('SafaehContentBand shows aside when wide', (tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const SafaehTheme(
        data: SafaehThemeData(
          contentMaxWidth: 400,
          contentMaxWidthDesktop: 400,
        ),
        child: MaterialApp(
          home: Scaffold(
            body: SafaehContentBand(
              aside: Text('aside-rail'),
              child: Text('band-body'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('band-body'), findsOneWidget);
    expect(find.text('aside-rail'), findsOneWidget);
  });

  testWidgets('SafaehTheme.maybeOf is null without an ancestor', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.shrink(),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    expect(SafaehTheme.maybeOf(context), isNull);
    expect(SafaehTheme.of(context).tabletBreakpoint, 600);
  });

  testWidgets('SafaehContentAlignedFabLocation sits past the band', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const fabKey = Key('aligned-fab');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          floatingActionButtonLocation: SafaehContentAlignedFabLocation(
            leftOffset: 100,
            bandWidth: 400,
            textDirection: TextDirection.ltr,
          ),
          floatingActionButton: FloatingActionButton(
            key: fabKey,
            onPressed: null,
            child: Icon(Icons.add),
          ),
          body: SizedBox.expand(),
        ),
      ),
    );

    final fabLeft = tester.getTopLeft(find.byKey(fabKey)).dx;
    expect(fabLeft, closeTo(516, 2));
  });

  testWidgets('SafaehContentAlignedFabLocation sits before the band in RTL', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const fabKey = Key('rtl-fab');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          floatingActionButtonLocation: SafaehContentAlignedFabLocation(
            leftOffset: 100,
            bandWidth: 400,
            textDirection: TextDirection.rtl,
          ),
          floatingActionButton: FloatingActionButton(
            key: fabKey,
            onPressed: null,
            child: Icon(Icons.add),
          ),
          body: SizedBox.expand(),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(fabKey)).dx, closeTo(28, 2));
  });

  testWidgets('SafaehContentAlignedAppBar start-aligns the title', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const titleKey = Key('start-title');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: SafaehContentAlignedAppBar(
            leftOffset: 80,
            bandWidth: 400,
            centerTitle: false,
            title: Text('Start title', key: titleKey),
          ),
          body: SizedBox.shrink(),
        ),
      ),
    );

    final titleLeft = tester.getTopLeft(find.byKey(titleKey)).dx;
    expect(titleLeft, closeTo(88, 2));
  });

  testWidgets('safaehRailAwareBandMetrics is a passthrough on phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SafaehTheme(
        data: SafaehThemeData(),
        child: MediaQuery(
          data: MediaQueryData(size: Size(400, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    final metrics = safaehRailAwareBandMetrics(context, 400);
    expect(metrics.leftOffset, 0);
    expect(metrics.bandWidth, 400);
    expect(metrics.endFree, 0);
  });

  testWidgets('safaehRailAwareBandMetrics centers around an LTR rail', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SafaehTheme(
        data: SafaehThemeData(),
        child: MediaQuery(
          data: MediaQueryData(size: Size(1200, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    // Desktop: contentMaxWidthDesktop 720, rail 240, content area 960.
    final metrics = safaehRailAwareBandMetrics(context, 960);
    expect(metrics.bandWidth, 720);
    expect(metrics.leftOffset, closeTo(0, 0.1));
    expect(metrics.endFree, closeTo(240, 0.1));
  });

  testWidgets('safaehRailAwareBandMetrics is RTL-aware', (tester) async {
    await tester.pumpWidget(
      const SafaehTheme(
        data: SafaehThemeData(),
        child: MediaQuery(
          data: MediaQueryData(size: Size(1200, 800)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    final metrics = safaehRailAwareBandMetrics(context, 960);
    expect(metrics.bandWidth, 720);
    expect(metrics.endFree, metrics.leftOffset);
  });
}
