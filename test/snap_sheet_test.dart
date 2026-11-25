import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

int _backgroundBuilds = 0;

Widget _app({
  required Size size,
  SafaehSnapSheetController? controller,
  ValueChanged<int>? onSnap,
  bool disableAnimations = true,
  bool rtl = false,
}) {
  return MediaQuery(
    data: MediaQueryData(size: size, disableAnimations: disableAnimations),
    child: MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: SafaehSnapSheet(
            controller: controller,
            onSnapChanged: onSnap,
            child: Builder(
              builder: (context) {
                _backgroundBuilds++;
                return const ColoredBox(
                  color: Colors.blueGrey,
                  child: SizedBox.expand(),
                );
              },
            ),
            sheetBuilder: (context, scroll) => ListView.builder(
              controller: scroll,
              itemCount: 40,
              itemBuilder: (_, i) =>
                  SizedBox(height: 56, child: Text('Row $i')),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => _backgroundBuilds = 0);

  testWidgets('phone: starts at the initial snap and scrolls its content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(size: const Size(390, 844)));
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.text('Row 0'), findsOneWidget);
    final top = tester.getTopLeft(find.byType(ClipRRect).first).dy;
    // Initial snap is index 1 = 50% height.
    expect(top, closeTo(844 * 0.5, 2));
  });

  testWidgets('controller snaps to a point and reports it', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = SafaehSnapSheetController();
    final seen = <int>[];
    await tester.pumpWidget(
      _app(
        size: const Size(390, 844),
        controller: controller,
        onSnap: seen.add,
      ),
    );
    await tester.pumpAndSettle();
    await controller.snapTo(2);
    await tester.pumpAndSettle();
    expect(controller.snapIndex, 2);
    expect(seen, contains(2));

    tester.view.physicalSize = const Size(960, 844);
    await tester.pumpWidget(
      _app(size: const Size(960, 844), controller: controller),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsNothing);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(
      _app(size: const Size(390, 844), controller: controller),
    );
    await tester.pumpAndSettle();
    expect(controller.snapIndex, 2);
    expect(
      tester.getTopLeft(find.byType(ClipRRect).first).dy,
      closeTo(844 * 0.08, 2),
    );

    await controller.snapTo(0);
    await tester.pumpAndSettle();
    expect(controller.snapIndex, 0);
  });

  testWidgets('dragging the sheet does not rebuild the content behind it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(size: const Size(390, 844)));
    await tester.pumpAndSettle();
    final before = _backgroundBuilds;
    await tester.drag(find.text('Row 0'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_backgroundBuilds, before);
  });

  testWidgets('wide screens use a side panel instead of a draggable sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(size: const Size(900, 700)));
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsNothing);
    expect(find.text('Row 0'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Row 0')).dx, lessThan(380));
  });

  testWidgets('RTL puts the side panel at the right edge', (tester) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(size: const Size(900, 700), rtl: true));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Row 0')).dx, greaterThan(500));
  });
}
