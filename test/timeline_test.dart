import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 390, height: 700, child: child)),
);

void main() {
  const stops = ['Colosseum', 'Lunch', 'Vatican'];

  testWidgets('shows numbered markers and legs between stops only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SafaehTimeline<String>(
          items: stops,
          itemKey: (s) => ValueKey(s),
          itemBuilder: (_, s, _) => SizedBox(height: 60, child: Text(s)),
          legBuilder: (_, s, i) => SizedBox(height: 30, child: Text('leg $i')),
        ),
      ),
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('leg 0'), findsOneWidget);
    expect(find.text('leg 1'), findsOneWidget);
    expect(find.text('leg 2'), findsNothing);
    expect(find.byIcon(Icons.drag_indicator), findsNothing);
  });

  testWidgets('reorderable mode shows handles and reports a move', (
    tester,
  ) async {
    final moves = <(int, int)>[];
    await tester.pumpWidget(
      _host(
        SafaehTimeline<String>(
          items: stops,
          itemKey: (s) => ValueKey(s),
          itemBuilder: (_, s, _) => SizedBox(height: 60, child: Text(s)),
          onReorder: (o, n) => moves.add((o, n)),
        ),
      ),
    );
    expect(find.byIcon(Icons.drag_indicator), findsNWidgets(3));
    await tester.drag(
      find.byIcon(Icons.drag_indicator).first,
      const Offset(0, 150),
      touchSlopY: 0,
    );
    await tester.pumpAndSettle();
    expect(moves, isNotEmpty);
    expect(moves.first.$1, 0);
    expect(moves.first.$2, greaterThan(0));
  });

  testWidgets('custom marker replaces the number', (tester) async {
    await tester.pumpWidget(
      _host(
        SafaehTimeline<String>(
          items: stops,
          itemKey: (s) => ValueKey(s),
          itemBuilder: (_, s, _) => SizedBox(height: 60, child: Text(s)),
          markerBuilder: (_, s, _) => const Icon(Icons.place),
        ),
      ),
    );
    expect(find.byIcon(Icons.place), findsNWidgets(3));
    expect(find.text('1'), findsNothing);
  });

  testWidgets('RTL layout builds without errors', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: _host(
          SafaehTimeline<String>(
            items: const ['الكولوسيوم', 'غداء'],
            itemKey: (s) => ValueKey(s),
            itemBuilder: (_, s, _) => SizedBox(height: 60, child: Text(s)),
            legBuilder: (_, s, i) =>
                const SizedBox(height: 30, child: Text('٩ دقائق')),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
