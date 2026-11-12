import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh_example/pages.dart';

String translate(String key) => key == 'section_copy'
    ? List.filled(30, 'A section with enough content to scroll.').join(' ')
    : key;

void main() {
  for (final environment in [
    (TextDirection.ltr, 1.0, false),
    (TextDirection.rtl, 1.5, false),
    (TextDirection.rtl, 2.0, true),
  ]) {
    final (direction, scale, reducedMotion) = environment;
    for (final config in [(390.0, false), (840.0, false), (390.0, true)]) {
      final (width, overlay) = config;
      testWidgets(
        'page index stays synchronized at $width, overlay=$overlay $environment',
        (tester) async {
          tester.view.physicalSize = Size(width, 600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => Directionality(
                textDirection: direction,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: reducedMotion,
                  ),
                  child: child!,
                ),
              ),
              home: Scaffold(
                body: overlay
                    ? PageIndexOverlayDemo(t: translate)
                    : PageIndexRailDemo(t: translate),
              ),
            ),
          );
          await tester.pumpAndSettle();
          String? active() => find.byType(SafaehPageIndex).evaluate().isNotEmpty
              ? tester
                    .widget<SafaehPageIndex>(find.byType(SafaehPageIndex))
                    .activeId
              : tester
                    .widget<SafaehPageIndexOverlay>(
                      find.byType(SafaehPageIndexOverlay),
                    )
                    .activeId;
          List<SafaehPageIndexEntry> entries() =>
              find.byType(SafaehPageIndex).evaluate().isNotEmpty
              ? tester
                    .widget<SafaehPageIndex>(find.byType(SafaehPageIndex))
                    .entries
              : tester
                    .widget<SafaehPageIndexOverlay>(
                      find.byType(SafaehPageIndexOverlay),
                    )
                    .entries;
          void select(SafaehPageIndexEntry entry) {
            if (find.byType(SafaehPageIndex).evaluate().isNotEmpty) {
              tester
                  .widget<SafaehPageIndex>(find.byType(SafaehPageIndex))
                  .onSelect(entry);
            } else {
              tester
                  .widget<SafaehPageIndexOverlay>(
                    find.byType(SafaehPageIndexOverlay),
                  )
                  .onSelect(entry);
            }
          }

          final last = entries().last;
          final list = find.byKey(
            ValueKey(
              overlay ? 'page_index_overlay_demo_list' : 'page_index_demo_list',
            ),
          );
          final scrollable = tester.state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)),
          );
          var previousOffset = scrollable.position.pixels;
          select(last);
          for (var frame = 0; frame < 20; frame++) {
            await tester.pump(const Duration(milliseconds: 20));
            expect(
              active(),
              last.id,
              reason: 'scroll-spy must not override a jump',
            );
            expect(
              scrollable.position.pixels,
              greaterThanOrEqualTo(previousOffset),
              reason: 'a jump must not scan backward through the page',
            );
            previousOffset = scrollable.position.pixels;
          }
          await tester.pumpAndSettle();
          await tester.drag(list, const Offset(0, 5000));
          await tester.pumpAndSettle();
          expect(active(), 'alpha');
          await tester.drag(list, const Offset(0, -5000));
          await tester.pumpAndSettle();
          expect(
            active(),
            last.id,
            reason: 'the last section remains reachable',
          );
          select(entries().first);
          await tester.pump(const Duration(milliseconds: 40));
          select(last);
          await tester.pumpAndSettle();
          expect(active(), last.id);
          select(entries().first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 80));
          await tester.drag(list, const Offset(0, -5000));
          await tester.pumpAndSettle();
          expect(
            active(),
            last.id,
            reason: 'user input cancels a pending jump',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
