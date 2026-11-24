import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

Widget _host(
  Widget child, {
  bool disableAnimations = false,
  TextDirection? dir,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: dir ?? TextDirection.ltr,
      child: MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  testWidgets('each state shows its icon and the host label', (tester) async {
    for (final state in SafaehSyncState.values) {
      await tester.pumpWidget(
        _host(
          SafaehStatusIndicator(state: state, label: 'L ${state.name}'),
          disableAnimations: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(SafaehStatusIndicator.iconFor(state)), findsOneWidget);
      expect(find.text('L ${state.name}'), findsOneWidget);
    }
  });

  testWidgets('semantics exposes one live label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const SafaehStatusIndicator(
          state: SafaehSyncState.saved,
          label: 'Saved',
        ),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Saved'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('icon-only mode hides the text', (tester) async {
    await tester.pumpWidget(
      _host(
        const SafaehStatusIndicator(
          state: SafaehSyncState.offline,
          label: 'Offline',
          showLabel: false,
        ),
        disableAnimations: true,
      ),
    );
    expect(find.text('Offline'), findsNothing);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });

  testWidgets('syncing does not animate when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SafaehStatusIndicator(
          state: SafaehSyncState.syncing,
          label: 'Syncing',
        ),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('connectivity bar is hidden when saved and shown when offline', (
    tester,
  ) async {
    var retried = 0;
    await tester.pumpWidget(
      _host(
        SafaehConnectivityBar(
          state: SafaehSyncState.saved,
          label: 'Offline',
          retryLabel: 'Retry',
          onRetry: () => retried++,
        ),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Offline'), findsNothing);

    await tester.pumpWidget(
      _host(
        SafaehConnectivityBar(
          state: SafaehSyncState.offline,
          label: 'Offline',
          retryLabel: 'Retry',
          onRetry: () => retried++,
        ),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, 1);
  });

  testWidgets('renders in RTL without overflow', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          child: SafaehStatusIndicator(
            state: SafaehSyncState.failed,
            label:
                'تعذر الحفظ — '
                'try again later please',
          ),
        ),
        disableAnimations: true,
        dir: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
