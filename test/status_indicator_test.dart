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

  group('SafaehSyncChip', () {
    testWidgets('saved shows its label, then collapses to the icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SafaehSyncChip(state: SafaehSyncState.saved, label: 'Synced'),
          disableAnimations: true,
        ),
      );
      expect(find.text('Synced'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Synced'), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('offline keeps its label and a state change re-expands', (
      tester,
    ) async {
      Widget chip(SafaehSyncState state, String label) => _host(
        SafaehSyncChip(state: state, label: label),
        disableAnimations: true,
      );
      await tester.pumpWidget(chip(SafaehSyncState.offline, 'Offline'));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Offline'), findsOneWidget);

      await tester.pumpWidget(chip(SafaehSyncState.saved, 'Synced'));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Synced'), findsNothing);
      await tester.pumpWidget(chip(SafaehSyncState.failed, 'Failed'));
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('tap calls back and is exposed as a button', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _host(
          SafaehSyncChip(
            state: SafaehSyncState.offline,
            label: 'Offline',
            onTap: () => taps++,
          ),
          disableAnimations: true,
        ),
      );
      await tester.tap(find.text('Offline'));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.byType(SafaehSyncChip)),
        matchesSemantics(
          label: 'Offline',
          isButton: true,
          hasTapAction: true,
          isLiveRegion: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('colorsBuilder restyles a state', (tester) async {
      await tester.pumpWidget(
        _host(
          SafaehSyncChip(
            state: SafaehSyncState.failed,
            label: 'Failed',
            colorsBuilder: (context, state) => (
              background: const Color(0xFF123456),
              foreground: const Color(0xFFFFFFFF),
            ),
          ),
          disableAnimations: true,
        ),
      );
      final box = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect((box.decoration! as BoxDecoration).color, const Color(0xFF123456));
    });

    testWidgets('is at least 44 pixels tall and renders in RTL', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SafaehSyncChip(
            state: SafaehSyncState.saved,
            label: 'تمت المزامنة',
          ),
          disableAnimations: true,
          dir: TextDirection.rtl,
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(tester.getSize(find.byType(SafaehSyncChip)).height, 44);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('connectivity bar shows a recovered message then collapses', (
    tester,
  ) async {
    Widget bar(SafaehSyncState state) => _host(
      SafaehConnectivityBar(
        state: state,
        label: 'Offline',
        recoveredLabel: 'Back online',
      ),
      disableAnimations: true,
    );
    await tester.pumpWidget(bar(SafaehSyncState.offline));
    expect(find.text('Offline'), findsOneWidget);
    await tester.pumpWidget(bar(SafaehSyncState.saved));
    expect(find.text('Back online'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Back online'), findsNothing);
    expect(find.text('Offline'), findsNothing);
  });
}
