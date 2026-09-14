import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('compact ↔ full height toggle animates panel height', (
    tester,
  ) async {
    const screenH = 800.0;
    tester.view.physicalSize = const Size(400, screenH);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehCameraSheetHost(
          builder: (context, sheet) => IconButton(
            key: const ValueKey('toggle'),
            onPressed: sheet.toggleExpanded,
            icon: Icon(
              sheet.expanded ? Icons.close_fullscreen : Icons.open_in_full,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final compactBox = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('safaeh_camera_panel')),
    );
    expect(
      compactBox.size.height,
      closeTo(screenH * kSafaehCameraCompactHeightFraction, 0.5),
    );

    await tester.tap(find.byKey(const ValueKey('toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pumpAndSettle();

    final fullBox = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('safaeh_camera_panel')),
    );
    expect(fullBox.size.height, closeTo(screenH, 0.5));
  });

  testWidgets('camera handle uses expand and collapse labels', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehCameraSheetHost(
          handleExpandLabel: 'Open taller',
          handleCollapseLabel: 'Make shorter',
          builder: (context, sheet) => IconButton(
            key: const ValueKey('toggle'),
            onPressed: sheet.toggleExpanded,
            icon: Icon(
              sheet.expanded ? Icons.close_fullscreen : Icons.open_in_full,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Open taller'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('toggle')));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Make shorter'), findsOneWidget);
  });

  testWidgets('showSafaehCameraSheet rolls up and scrim dismisses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehCameraSheet<void>(
              context: context,
              builder: (context, sheet) => const Center(child: Text('lens')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    final startTop = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_camera_panel')))
        .dy;
    expect(startTop, greaterThan(400));
    final slide = tester.widget<FractionalTranslation>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('safaeh_camera_panel')),
            matching: find.byType(FractionalTranslation),
          )
          .first,
    );
    expect(slide.translation.dy, greaterThan(0));
    expect(slide.translation.dy, lessThanOrEqualTo(1));
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('safaeh_camera_panel'))).dy,
      lessThan(startTop),
    );
    await tester.pumpAndSettle();
    expect(find.text('lens'), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_camera_panel')), findsOneWidget);

    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(find.text('lens'), findsNothing);
  });

  testWidgets(
    'showSafaehCameraSheet skips slide when animations are disabled',
    (tester) async {
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
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehCameraSheet<void>(
                context: context,
                builder: (context, sheet) => const Center(child: Text('lens')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      final panel = find.byKey(const ValueKey('safaeh_camera_panel'));
      expect(panel, findsOneWidget);
      expect(
        tester.getTopLeft(panel).dy,
        closeTo(800 * (1 - kSafaehCameraCompactHeightFraction), 1),
      );
      final slide = tester.widget<FractionalTranslation>(
        find
            .ancestor(of: panel, matching: find.byType(FractionalTranslation))
            .first,
      );
      expect(slide.translation.dy, 0);
    },
  );

  testWidgets('handle drag does not rebuild the preview builder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SafaehCameraSheetHost(
          builder: (context, sheet) {
            builds++;
            return IconButton(
              key: const ValueKey('toggle'),
              onPressed: sheet.toggleExpanded,
              icon: const Icon(Icons.open_in_full),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final afterMount = builds;

    await tester.drag(find.byType(SheetHandleBar), const Offset(0, 40));
    await tester.pump();
    expect(builds, afterMount);

    await tester.tap(find.byKey(const ValueKey('toggle')));
    await tester.pump();
    expect(builds, greaterThan(afterMount));
  });

  testWidgets('camera interceptDismiss runs instead of pop', (tester) async {
    var intercepted = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SafaehCameraSheetHost(
          builder: (context, sheet) {
            sheet.interceptDismiss = () async {
              intercepted++;
            };
            return TextButton(
              onPressed: () => sheet.dismiss(),
              child: const Text('close'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('close'));
    await tester.pumpAndSettle();
    expect(intercepted, 1);
    expect(find.text('close'), findsOneWidget);
  });

  testWidgets('camera barrierDismissible false keeps the sheet on scrim tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehCameraSheet<void>(
              context: context,
              barrierDismissible: false,
              builder: (context, sheet) => const Center(child: Text('lens')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(find.text('lens'), findsOneWidget);
  });

  testWidgets('showSafaehCameraSheet system back dismisses when allowed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehCameraSheet<void>(
              context: context,
              builder: (context, sheet) => const Center(child: Text('lens')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('lens'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('lens'), findsNothing);
  });

  testWidgets('showSafaehCameraSheet system back stays when not dismissible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehCameraSheet<void>(
              context: context,
              barrierDismissible: false,
              builder: (context, sheet) => const Center(child: Text('lens')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('lens'), findsOneWidget);
  });

  testWidgets('camera system back runs interceptDismiss', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var intercepted = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehCameraSheet<void>(
              context: context,
              builder: (context, sheet) {
                sheet.interceptDismiss = () async {
                  intercepted++;
                };
                return const Center(child: Text('lens'));
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(intercepted, 1);
    expect(find.text('lens'), findsOneWidget);
  });

  testWidgets('camera handle fling stays when not dismissible', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehCameraSheet<void>(
              context: context,
              barrierDismissible: false,
              builder: (context, sheet) => const Center(child: Text('lens')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(SheetHandleBar), const Offset(0, 280), 1400);
    await tester.pumpAndSettle();
    expect(find.text('lens'), findsOneWidget);
  });

  testWidgets('camera handle omits Dismiss when tap is disabled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehCameraSheetHost(
          barrierDismissible: false,
          handleExpandLabel: 'Open taller',
          builder: (context, sheet) => const Center(child: Text('lens')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Open taller'), findsOneWidget);
    expect(find.bySemanticsLabel('Dismiss'), findsNothing);
  });
}
