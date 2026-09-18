import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh_example/app.dart';
import 'package:safaeh_example/catalog.dart';
import 'package:safaeh_example/pages.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

String _t(String key) => translateCatalog(key, 'en');

String _imagePath(String name) {
  final testDir = Directory.current.path;
  final root = testDir.endsWith('example')
      ? Directory.current.parent.path
      : testDir;
  return '$root/screenshots/$name.png';
}

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required Size size,
  required Widget child,
}) async {
  final controller = WidgetsToImageController();
  tester.view.physicalSize = Size(size.width * 2, size.height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final theme = catalogTheme(Brightness.light);
  await tester.pumpWidget(
    WidgetsToImage(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SafaehTheme(
          data: const SafaehThemeData(),
          child: ColoredBox(
            color: theme.colorScheme.surface,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: size.width,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final bytes = await controller.capturePng(pixelRatio: 2);
    expect(bytes, isNotNull);
    expect(bytes, isNotEmpty);
    final file = File(_imagePath(name));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!);
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('card picker image', (tester) async {
    await _capture(
      tester,
      name: 'picker',
      size: const Size(390, 280),
      child: CardPickerDemo(t: _t),
    );
  });

  testWidgets('confirm sheet image', (tester) async {
    await _capture(
      tester,
      name: 'confirm',
      size: const Size(390, 240),
      child: ConfirmDemo(t: _t),
    );
  });

  testWidgets('option tiles image', (tester) async {
    await _capture(
      tester,
      name: 'option-tiles',
      size: const Size(390, 300),
      child: OptionTilesDemo(t: _t),
    );
  });

  testWidgets('sidenav rail image', (tester) async {
    await _capture(
      tester,
      name: 'sidenav',
      size: const Size(720, 400),
      child: SizedBox(height: 360, child: SidenavRailDemo(t: _t)),
    );
  });

  testWidgets('empty state image', (tester) async {
    await _capture(
      tester,
      name: 'empty-state',
      size: const Size(390, 420),
      child: EmptyStateDemo(t: _t),
    );
  });

  testWidgets('inline banner image', (tester) async {
    await _capture(
      tester,
      name: 'inline-banner',
      size: const Size(390, 160),
      child: InlineBannerDemo(t: _t),
    );
  });

  testWidgets('kpi card image', (tester) async {
    await _capture(
      tester,
      name: 'kpi-card',
      size: const Size(390, 140),
      child: KpiCardDemo(t: _t),
    );
  });

  testWidgets('async error image', (tester) async {
    await _capture(
      tester,
      name: 'async-error',
      size: const Size(390, 360),
      child: AsyncErrorDemo(t: _t),
    );
  });

  testWidgets('debug menu image', (tester) async {
    await _capture(
      tester,
      name: 'debug-menu',
      size: const Size(390, 200),
      child: SizedBox(height: 160, child: DebugMenuDemo(t: _t)),
    );
  });

  testWidgets('meta chip image', (tester) async {
    await _capture(
      tester,
      name: 'meta-chip',
      size: const Size(390, 80),
      child: MetaChipDemo(t: _t),
    );
  });

  testWidgets('glyph avatar image', (tester) async {
    await _capture(
      tester,
      name: 'glyph-avatar',
      size: const Size(390, 80),
      child: GlyphAvatarDemo(t: _t),
    );
  });

  testWidgets('bordered list image', (tester) async {
    await _capture(
      tester,
      name: 'bordered-list',
      size: const Size(390, 120),
      child: BorderedListDemo(t: _t),
    );
  });

  testWidgets('section header image', (tester) async {
    await _capture(
      tester,
      name: 'section-header',
      size: const Size(390, 80),
      child: SectionHeaderDemo(t: _t),
    );
  });

  testWidgets('user text image', (tester) async {
    await _capture(
      tester,
      name: 'user-text',
      size: const Size(390, 280),
      child: UserTextDemo(t: _t),
    );
  });

  testWidgets('accent surfaces image', (tester) async {
    await _capture(
      tester,
      name: 'accent-surfaces',
      size: const Size(390, 180),
      child: AccentSurfacesDemo(t: _t),
    );
  });

  testWidgets('material chrome image', (tester) async {
    await _capture(
      tester,
      name: 'material-chrome',
      size: const Size(390, 120),
      child: MaterialChromeDemo(t: _t),
    );
  });

  testWidgets('l10n editor image', (tester) async {
    await _capture(
      tester,
      name: 'l10n-editor',
      size: const Size(390, 320),
      child: L10nEditorDemo(t: _t),
    );
  });

  testWidgets('sheet padding image', (tester) async {
    await _capture(
      tester,
      name: 'sheet-padding',
      size: const Size(390, 360),
      child: SizedBox(height: 320, child: SheetPaddingDemo(t: _t)),
    );
  });
}
