import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('scroll metrics make a short final section selectable', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final viewport = GlobalKey();
    final first = GlobalKey();
    final middle = GlobalKey();
    final last = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: SingleChildScrollView(
              key: viewport,
              controller: controller,
              child: Column(
                children: [
                  SizedBox(key: first, height: 300),
                  SizedBox(key: middle, height: 400),
                  SizedBox(key: last, height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    controller.jumpTo(100);
    await tester.pump();
    expect(
      safaehActivePageSectionId(
        sections: [('first', first), ('middle', middle), ('last', last)],
        scrollContext: viewport.currentContext!,
        metrics: controller.position,
      ),
      'middle',
    );
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    final context = viewport.currentContext!;
    expect(
      safaehActivePageSectionId(
        sections: [('first', first), ('last', last)],
        scrollContext: context,
      ),
      'first',
      reason: 'legacy threshold behavior stays compatible',
    );
    expect(
      safaehActivePageSectionId(
        sections: [('first', first), ('last', last)],
        scrollContext: context,
        metrics: controller.position,
      ),
      'last',
    );
    controller.jumpTo(0);
    await tester.pump();
    expect(
      safaehActivePageSectionId(
        sections: [('first', first), ('last', last)],
        scrollContext: context,
        metrics: controller.position,
      ),
      'first',
    );
  });
}
