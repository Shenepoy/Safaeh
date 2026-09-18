import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

Widget _host({required Widget child, Size size = const Size(400, 800)}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: SafaehTheme(
        data: const SafaehThemeData(),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('SafaehEmptyState shows title and optional action', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        child: SafaehEmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here',
          subtitle: 'Add one',
          actionLabel: 'Create',
          onAction: () => tapped = true,
        ),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add one'), findsOneWidget);
    await tester.tap(find.text('Create'));
    expect(tapped, isTrue);
  });

  testWidgets('SafaehInlineBanner shows message and trailing', (tester) async {
    await tester.pumpWidget(
      _host(
        child: const SafaehInlineBanner(
          message: 'Archived',
          tone: SafaehBannerTone.info,
          trailing: Icon(Icons.close),
        ),
      ),
    );
    expect(find.text('Archived'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('SafaehMetaChip renders label and icon', (tester) async {
    await tester.pumpWidget(
      _host(
        child: const SafaehMetaChip(
          icon: Icons.group_outlined,
          label: 'Family',
        ),
      ),
    );
    expect(find.text('Family'), findsOneWidget);
    expect(find.byIcon(Icons.group_outlined), findsOneWidget);
  });

  testWidgets('SafaehGlyphAvatar shows letter when no icon', (tester) async {
    await tester.pumpWidget(
      _host(child: const SafaehGlyphAvatar(letter: 'Home')),
    );
    expect(find.text('H'), findsOneWidget);
  });

  testWidgets('SafaehGlyphAvatar falls back when letter is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(child: const SafaehGlyphAvatar(letter: '')),
    );
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('SafaehGlyphAvatar shows icon when provided', (tester) async {
    await tester.pumpWidget(
      _host(child: const SafaehGlyphAvatar(icon: Icons.home)),
    );
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('SafaehKpiCard shows label and value', (tester) async {
    await tester.pumpWidget(
      _host(child: const SafaehKpiCard(label: 'Total', value: '12.00')),
    );
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('12.00'), findsOneWidget);
  });

  testWidgets('SafaehBorderedListChrome taps child', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        child: SafaehBorderedListChrome(
          onTap: () => taps++,
          child: const Text('row'),
        ),
      ),
    );
    await tester.tap(find.text('row'));
    expect(taps, 1);
  });

  testWidgets('SafaehSectionHeader shows label and subtitle', (tester) async {
    await tester.pumpWidget(
      _host(
        child: const SafaehSectionHeader(
          label: 'Filters',
          subtitle: 'Optional words',
        ),
      ),
    );
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Optional words'), findsOneWidget);
  });

  testWidgets('SafaehLtrText forces LTR even inside RTL Directionality', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: SafaehLtrText('792.50 ريال')),
        ),
      ),
    );
    final text = tester.widget<Text>(find.text('792.50 ريال'));
    expect(text.textDirection, TextDirection.ltr);
  });

  test('SafaehSemanticStatus maps to ColorScheme slots', () {
    const cs = ColorScheme.light();
    expect(cs.success, cs.primary);
    expect(cs.warning, cs.tertiary);
    expect(cs.danger, cs.error);
  });

  testWidgets('SafaehAsyncBody shows loading then data', (tester) async {
    await tester.pumpWidget(
      _host(
        child: SafaehAsyncBody(
          isLoading: true,
          data: (_) => const Text('ready'),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      _host(
        child: SafaehAsyncBody(
          isLoading: false,
          data: (_) => const Text('ready'),
        ),
      ),
    );
    expect(find.text('ready'), findsOneWidget);
  });

  testWidgets('SafaehErrorBody shows title and retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _host(
        child: SafaehErrorBody(
          title: 'Failed',
          message: 'offline',
          retryLabel: 'Retry',
          onRetry: () => retried = true,
        ),
      ),
    );
    expect(find.text('Failed'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('SafaehContentAlignedPage passes scaffold width', (tester) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    double? width;
    await tester.pumpWidget(
      MaterialApp(
        home: SafaehContentAlignedPage(
          builder: (context, contentAreaWidth) {
            width = contentAreaWidth;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(width, 400);
  });
}
