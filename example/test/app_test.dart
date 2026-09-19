import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

import 'package:safaeh_example/app.dart';
import 'package:safaeh_example/catalog.dart';
import 'package:safaeh_example/gallery.dart';
import 'package:safaeh_example/pages.dart';

import 'screenshot_harness.dart';

void _expectLanguageMenuCenteredOnGlobe(WidgetTester tester) {
  final menu = tester.getRect(find.byKey(const ValueKey('language_menu')));
  final globe = tester.getRect(find.byKey(const ValueKey('language_toggle')));
  expect(menu.width, 92);
  expect((menu.center.dx - globe.center.dx).abs(), lessThan(1.5));
}

Future<void> _reveal(WidgetTester tester, String id) async {
  final section = find.byKey(ValueKey('catalog_$id'));
  final gallery = tester.state<CatalogGalleryState>(
    find.byType(CatalogGallery),
  );
  final controller = gallery.controller;
  if (section.evaluate().isEmpty && controller.offset > 0) {
    controller.jumpTo(0);
    await tester.pumpAndSettle();
  }
  for (var i = 0; i < 48 && section.evaluate().isEmpty; i++) {
    final next = (controller.offset + 280).clamp(
      0.0,
      controller.position.maxScrollExtent,
    );
    if (next == controller.offset) break;
    controller.jumpTo(next);
    await tester.pumpAndSettle();
  }
  expect(section, findsOneWidget);
  await tester.ensureVisible(section);
  await tester.pumpAndSettle();
}

void _expectPhoneChromeOutsideBezel(
  WidgetTester tester, {
  required bool showReach,
}) {
  final chrome = find.byKey(const ValueKey('catalog_phone_chrome'));
  final frame = find.byKey(const ValueKey('catalog_phone_frame'));
  final close = find.byKey(const ValueKey('catalog_phone_close'));
  final reach = find.byKey(const ValueKey('catalog_phone_reach'));

  expect(chrome, findsOneWidget);
  expect(close, findsOneWidget);
  expect(find.descendant(of: chrome, matching: close), findsOneWidget);
  expect(find.descendant(of: frame, matching: close), findsNothing);
  expect(
    tester.getRect(close).bottom,
    lessThanOrEqualTo(tester.getRect(frame).top),
  );

  if (showReach) {
    expect(reach, findsOneWidget);
    expect(find.descendant(of: chrome, matching: reach), findsOneWidget);
    expect(find.descendant(of: frame, matching: reach), findsNothing);
    expect(
      tester.getRect(reach).bottom,
      lessThanOrEqualTo(tester.getRect(frame).top),
    );
  } else {
    expect(reach, findsNothing);
  }
}

Future<void> _openTitle(WidgetTester tester, String id) async {
  await _reveal(tester, id);
  final title = find.byKey(ValueKey('catalog_${id}_title'));
  await tester.ensureVisible(title);
  await tester.pumpAndSettle();
  await tester.tap(title);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('catalog lists every public chrome entry', (tester) async {
    await pumpExampleApp(tester);

    expect(find.text('Safaeh'), findsWidgets);
    expect(
      find.ancestor(
        of: find.byType(CatalogGallery),
        matching: find.byType(SafaehContentBand),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CatalogHome),
        matching: find.byType(SafaehPageIndexOverlay),
      ),
      findsNothing,
    );
    for (final item in catalogItems) {
      await _reveal(tester, item.id);
      expect(find.text(translateCatalog(item.titleKey, 'en')), findsWidgets);
    }
  });

  testWidgets('morphing app bar demo follows the page view', (tester) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'morphing_app_bar');
    final demo = find.byKey(const ValueKey('morphing_app_bar_demo'));
    final appBar = find.descendant(
      of: demo,
      matching: find.byType(SafaehMorphingAppBar),
    );
    expect(demo, findsOneWidget);
    expect(appBar, findsOneWidget);
    expect(
      find.descendant(of: appBar, matching: find.text('Home')),
      findsOneWidget,
    );

    await tester.drag(
      find.byKey(const ValueKey('morphing_app_bar_page_view')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: appBar, matching: find.text('Weight')),
      findsOneWidget,
    );
  });

  testWidgets(
    'floating appearance fixture renders every preset over contrast',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FloatingSurfaceStylesDemo()),
      );

      expect(find.byType(SafaehFloatingNavBar), findsNWidgets(4));
      for (final style in SafaehFloatingSurfaceStyle.values) {
        expect(
          find.byKey(ValueKey('floating_style_${style.name}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('floating_style_nav_${style.name}')),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('language menu lists five Fukaha locales and applies one', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('language_toggle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('language_menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_ar')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_en')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_ja')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_zh')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_es')), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    _expectLanguageMenuCenteredOnGlobe(tester);

    await tester.tap(find.byKey(const ValueKey('language_option_ar')));
    await tester.pumpAndSettle();
    expect(find.text('صفائح'), findsWidgets);
    expect(find.text('ورقة متكيفة'), findsOneWidget);
    expect(find.text('Adaptive sheet'), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('صفائح').first)),
      TextDirection.rtl,
    );

    await tester.tap(find.byKey(const ValueKey('language_toggle')));
    await tester.pumpAndSettle();
    _expectLanguageMenuCenteredOnGlobe(tester);
    await tester.tap(find.byKey(const ValueKey('language_option_ja')));
    await tester.pumpAndSettle();
    expect(find.text('アダプティブシート'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Safaeh').first)),
      TextDirection.ltr,
    );
  });

  testWidgets('sheet, picker, confirm, and dialog are visible inline', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);

    await _reveal(tester, 'picker');
    expect(find.text('How to settle'), findsOneWidget);
    expect(find.text('Minimal'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);

    await _reveal(tester, 'confirm');
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_confirm')), findsOneWidget);

    await _reveal(tester, 'text_input');
    expect(find.byKey(const ValueKey('safaeh_text_done')), findsOneWidget);

    await _reveal(tester, 'dialog');
    expect(find.text('Centered dialog'), findsWidgets);
  });

  testWidgets('tile picker shows header and skips a disabled row', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'tile_picker');
    final tileCard = find.byKey(const ValueKey('catalog_tile_picker'));
    expect(find.text('Choose account'), findsWidgets);
    expect(find.text('Custom header above the list'), findsOneWidget);
    expect(
      find.descendant(of: tileCard, matching: find.text('Offline')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: tileCard, matching: find.text('Offline')),
    );
    await tester.pump();
    expect(
      find.descendant(of: tileCard, matching: find.text('Offline')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: tileCard, matching: find.text('Card')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: tileCard, matching: find.text('Offline')),
      findsOneWidget,
    );
  });

  testWidgets('multi picker searches and status body shows busy', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'multi_picker');
    expect(find.byKey(const ValueKey('safaeh_tile_search')), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_multi_done')), findsOneWidget);
    expect(find.text('Cash'), findsWidgets);

    await _reveal(tester, 'status_body');
    expect(find.text('Loading'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('feedback demo uses the shared host and action contract', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'feedback');
    final section = find.byKey(const ValueKey('catalog_feedback'));
    expect(
      find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('feedback_success_button')),
      ),
      findsOneWidget,
    );
    expect(find.byType(SafaehFeedbackHost), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('feedback_success_button')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The shared surface confirms a completed action.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('feedback_dismiss_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('feedback_action_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo', skipOffstage: false));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('feedback_action_status')),
      findsOneWidget,
    );
    expect(find.text('Action undone'), findsOneWidget);
  });

  testWidgets('sheet shell, option tiles, and morph stay on the gallery', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'sheet_shell');
    expect(find.text('Shared title, body, and action row.'), findsOneWidget);
    expect(find.text('Export report'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await _reveal(tester, 'option_tiles');
    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.text('Destructive'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);

    await _reveal(tester, 'sheet_morph');
    expect(find.text('320'), findsOneWidget);
    expect(find.text('420'), findsOneWidget);
    expect(find.text('Phone sheet ↔ tablet dialog'), findsWidgets);
  });

  testWidgets('sidenav rail, drawer, and floating nav', (tester) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'sidenav');
    expect(
      find.text('Tap the menu to show destination labels.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('safaeh_nav_rail')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_sidenav')),
        matching: find.byKey(const ValueKey('safaeh_nav_profile_avatar')),
      ),
      findsOneWidget,
    );
    expect(find.text('AL'), findsWidgets);
    expect(tester.takeException(), isNull);

    await _reveal(tester, 'sidenav_drawer');
    final drawerSection = find.byKey(const ValueKey('catalog_sidenav_drawer'));
    expect(
      find.descendant(
        of: drawerSection,
        matching: find.byKey(const ValueKey('safaeh_nav_expand')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: drawerSection, matching: find.text('Groups')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: drawerSection,
        matching: find.byKey(const ValueKey('safaeh_nav_profile_avatar')),
      ),
      findsOneWidget,
    );

    await _reveal(tester, 'sidenav_overlay');
    expect(find.byKey(const ValueKey('safaeh_nav_overlay')), findsOneWidget);
    expect(find.text('This is the selected destination.'), findsWidgets);

    await _reveal(tester, 'floating_nav');
    expect(find.text('This is the selected destination.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('safaeh_fab_nav_1')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_floating_nav')),
        matching: find.text('Settings'),
      ),
      findsWidgets,
    );
  });

  testWidgets('page index rail and overlay', (tester) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'page_index');
    expect(find.text('Alpha'), findsWidgets);
    expect(find.text('On this page'), findsWidgets);

    await _reveal(tester, 'page_index_overlay');
    expect(find.text('On this page'), findsWidgets);
    expect(find.text('Beta'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_page_index_overlay')),
        matching: find.byType(SafaehPageIndexOverlay),
      ),
      findsOneWidget,
    );
  });

  testWidgets('inline page index does not scroll the catalog', (tester) async {
    await pumpExampleApp(tester, size: const Size(800, 844));

    await _reveal(tester, 'page_index');
    final gallery = tester.state<CatalogGalleryState>(
      find.byType(CatalogGallery),
    );
    final catalogOffset = gallery.controller.offset;
    final innerScrollable = find.descendant(
      of: find.byKey(const ValueKey('page_index_demo_list')),
      matching: find.byType(Scrollable),
    );
    expect(innerScrollable, findsOneWidget);
    final inner = tester.state<ScrollableState>(innerScrollable);
    final innerBefore = inner.position.pixels;

    await tester.tap(
      find.descendant(
        of: find.byType(SafaehPageIndex),
        matching: find.text('Gamma'),
      ),
    );
    await tester.pumpAndSettle();

    expect(gallery.controller.offset, catalogOffset);
    expect(inner.position.pixels, greaterThan(innerBefore));
    expect(find.byType(CatalogGallery), findsOneWidget);
  });

  testWidgets('content band, aside, and aligned chrome pages', (tester) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'content_band');
    expect(find.textContaining('SafaehContentBand'), findsOneWidget);

    await _reveal(tester, 'end_aside');
    expect(find.textContaining('SafaehEndAsideLayout'), findsOneWidget);

    await _reveal(tester, 'aligned_chrome');
    expect(find.text('Aligned title'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('camera host and QR chrome pages', (tester) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'camera');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_camera')),
        matching: find.byKey(const ValueKey('catalog_mock_camera')),
      ),
      findsOneWidget,
    );
    expect(find.text('Demo camera'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_camera')),
        matching: find.byKey(const ValueKey('safaeh_camera_panel')),
      ),
      findsOneWidget,
    );

    await _reveal(tester, 'qr_overlay');
    expect(find.text('Scan invite'), findsOneWidget);
    expect(find.text('Point at a code'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_qr_overlay')),
        matching: find.byKey(const ValueKey('catalog_mock_camera')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_qr_overlay')),
        matching: find.byKey(const ValueKey('safaeh_camera_panel')),
      ),
      findsOneWidget,
    );

    await _reveal(tester, 'qr_message');
    expect(find.text('Need camera permission'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_qr_message')),
        matching: find.byKey(const ValueKey('safaeh_camera_panel')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('theme toggle switches Material brightness', (tester) async {
    await pumpExampleApp(tester);

    expect(
      Theme.of(tester.element(find.text('Safaeh').first)).brightness,
      Brightness.light,
    );
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsNothing);

    await tester.tap(find.byKey(const ValueKey('theme_toggle')));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Safaeh').first)).brightness,
      Brightness.dark,
    );
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_outlined), findsNothing);
  });

  testWidgets('floating appearance toggle cycles surface styles', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    final home = find.byType(CatalogHome);
    SafaehFloatingSurfaceStyle appearance() =>
        SafaehTheme.of(tester.element(home)).floatingAppearance!.style;

    expect(
      find.byKey(const ValueKey('floating_appearance_toggle')),
      findsOneWidget,
    );
    expect(appearance(), SafaehFloatingSurfaceStyle.solid);

    for (final style in [
      SafaehFloatingSurfaceStyle.translucent,
      SafaehFloatingSurfaceStyle.glass,
      SafaehFloatingSurfaceStyle.vista,
      SafaehFloatingSurfaceStyle.solid,
    ]) {
      await tester.tap(
        find.byKey(const ValueKey('floating_appearance_toggle')),
      );
      await tester.pumpAndSettle();
      expect(appearance(), style);
    }
  });

  testWidgets('toggles stay tappable over page-index overlay chrome', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'page_index_overlay');
    expect(find.text('On this page'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('language_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language_option_ar')));
    await tester.pumpAndSettle();
    expect(find.text('صفائح'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('theme_toggle')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('صفائح').first)).brightness,
      Brightness.dark,
    );
  });

  testWidgets('chrome catalog pages open without throwing', (tester) async {
    await pumpExampleApp(tester);

    const ids = [
      'empty_state',
      'inline_banner',
      'meta_chip',
      'glyph_avatar',
      'kpi_card',
      'bordered_list',
      'section_header',
      'async_error',
      'user_text',
      'accent_surfaces',
      'material_chrome',
      'debug_menu',
      'l10n_editor',
      'sheet_padding',
    ];
    for (final id in ids) {
      await _openTitle(tester, id);
      expect(tester.takeException(), isNull, reason: id);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget, reason: id);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogGallery), findsOneWidget, reason: id);
    }
  });

  testWidgets('section titles open the standalone demo', (tester) async {
    await pumpExampleApp(tester);

    await _openTitle(tester, 'option_tiles');
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.text('Selected'), findsWidgets);
    expect(find.text('Destructive'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGallery), findsOneWidget);
    expect(find.byKey(const ValueKey('catalog_gallery')), findsOneWidget);

    await _openTitle(tester, 'sheet_shell');
    expect(find.text('Export report'), findsWidgets);
    expect(find.text('Shared title, body, and action row.'), findsWidgets);
    await tester.tap(find.text('PDF').last);
    await tester.pumpAndSettle();
    expect(find.text('Exporting as PDF'), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGallery), findsOneWidget);

    await _openTitle(tester, 'confirm');
    expect(find.text('This cannot be undone.'), findsWidgets);
    expect(find.byKey(const ValueKey('safaeh_confirm')), findsWidgets);
    expect(find.byKey(const ValueKey('safaeh_cancel')), findsNothing);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGallery), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);

    await _openTitle(tester, 'camera');
    expect(find.text('Demo camera'), findsWidgets);
    expect(find.byKey(const ValueKey('safaeh_camera_panel')), findsWidgets);
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGallery), findsOneWidget);
    expect(find.text('Demo camera'), findsWidgets);

    await _openTitle(tester, 'qr_overlay');
    expect(find.text('Scan invite'), findsWidgets);
    expect(find.byKey(const ValueKey('safaeh_camera_panel')), findsWidgets);
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGallery), findsOneWidget);
    expect(find.text('Scan invite'), findsOneWidget);
  });

  test('catalogColumnCount uses band width', () {
    expect(catalogColumnCount(390), 1);
    expect(catalogColumnCount(719), 1);
    expect(catalogColumnCount(720), 2);
    expect(catalogColumnCount(1080), 3);
  });

  testWidgets('wide band lays catalog sections in two start-first columns', (
    tester,
  ) async {
    await pumpExampleApp(tester, size: const Size(800, 844));

    expect(catalogColumnCount(800), 2);
    final sheet = tester.getTopLeft(
      find.byKey(const ValueKey('catalog_sheet')),
    );
    final picker = tester.getTopLeft(
      find.byKey(const ValueKey('catalog_picker')),
    );
    expect(picker.dy, closeTo(sheet.dy, 2));
    expect(picker.dx, greaterThan(sheet.dx));
  });

  testWidgets('RTL wide band fills columns from the start edge', (
    tester,
  ) async {
    await pumpExampleApp(tester, language: 'ar', size: const Size(800, 844));

    final sheet = tester.getTopLeft(
      find.byKey(const ValueKey('catalog_sheet')),
    );
    final picker = tester.getTopLeft(
      find.byKey(const ValueKey('catalog_picker')),
    );
    expect(picker.dy, closeTo(sheet.dy, 2));
    expect(picker.dx, lessThan(sheet.dx));
  });

  testWidgets('phone frame docks sheets and fills full-screen chrome', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.tap(find.byKey(const ValueKey('catalog_sheet_phone')));
    await tester.pumpAndSettle();
    var frame = tester.getRect(
      find.byKey(const ValueKey('catalog_phone_frame')),
    );
    final panel = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byKey(const ValueKey('safaeh_panel')),
      ),
    );
    expect(panel.bottom, closeTo(frame.bottom - 8, 16));
    expect(panel.top, greaterThan(frame.top + 80));
    _expectPhoneChromeOutsideBezel(tester, showReach: true);
    await tester.tap(find.byKey(const ValueKey('catalog_phone_close')));
    await tester.pumpAndSettle();

    await _reveal(tester, 'dialog');
    await tester.tap(find.byKey(const ValueKey('catalog_dialog_phone')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_reach')), findsNothing);
    _expectPhoneChromeOutsideBezel(tester, showReach: false);
    frame = tester.getRect(find.byKey(const ValueKey('catalog_phone_frame')));
    final card = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byType(Card),
      ),
    );
    expect(card.center.dy, closeTo(frame.center.dy, 120));
    await tester.tap(find.byKey(const ValueKey('catalog_phone_close')));
    await tester.pumpAndSettle();

    await _reveal(tester, 'camera');
    await tester.tap(find.byKey(const ValueKey('catalog_camera_phone')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_reach')), findsNothing);
    _expectPhoneChromeOutsideBezel(tester, showReach: false);
    frame = tester.getRect(find.byKey(const ValueKey('catalog_phone_frame')));
    final camera = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byKey(const ValueKey('safaeh_camera_panel')),
      ),
    );
    expect(camera.height, greaterThan(frame.height * 0.5));
    await tester.tap(find.byKey(const ValueKey('catalog_phone_close')));
    await tester.pumpAndSettle();

    await _reveal(tester, 'option_tiles');
    await tester.tap(find.byKey(const ValueKey('catalog_option_tiles_phone')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_reach')), findsNothing);
    _expectPhoneChromeOutsideBezel(tester, showReach: false);
  });

  testWidgets('phone chrome uses mobile sidenav, index, band, and aside', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    Future<Rect> openPhone(String id) async {
      await _reveal(tester, id);
      await tester.tap(find.byKey(ValueKey('catalog_${id}_phone')));
      await tester.pumpAndSettle();
      _expectPhoneChromeOutsideBezel(tester, showReach: false);
      return tester.getRect(find.byKey(const ValueKey('catalog_phone_frame')));
    }

    Future<void> closePhone() async {
      await tester.tap(find.byKey(const ValueKey('catalog_phone_close')));
      await tester.pumpAndSettle();
    }

    var frame = await openPhone('sidenav');
    final rail = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byKey(const ValueKey('safaeh_nav_rail')),
      ),
    );
    expect(rail.width, closeTo(72, 8));
    expect(rail.top, closeTo(frame.top + 28, 8));
    await closePhone();

    await openPhone('sidenav_drawer');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.text('Groups'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byKey(const ValueKey('safaeh_nav_expand')),
      ),
      findsNothing,
    );
    await closePhone();

    frame = await openPhone('floating_nav');
    final bar = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byType(SafaehFloatingNavBar),
      ),
    );
    expect(bar.bottom, closeTo(frame.bottom - 8, 24));
    await closePhone();

    await openPhone('page_index');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byType(SafaehPageIndexOverlay),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byType(SafaehPageIndex),
      ),
      findsNothing,
    );
    await closePhone();

    await openPhone('page_index_overlay');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byType(SafaehPageIndexOverlay),
      ),
      findsOneWidget,
    );
    await closePhone();

    await openPhone('content_band');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.textContaining('SafaehContentBand'),
      ),
      findsOneWidget,
    );
    await closePhone();

    await openPhone('end_aside');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.textContaining('SafaehEndAsideLayout'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.text('Aside'),
      ),
      findsOneWidget,
    );
    await closePhone();
  });

  testWidgets('phone frame reach toggle extends the sheet upward', (
    tester,
  ) async {
    await pumpExampleApp(tester, size: const Size(900, 844));

    await tester.ensureVisible(find.byKey(const ValueKey('catalog_sheet')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('catalog_sheet_phone')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_frame')), findsOneWidget);
    _expectPhoneChromeOutsideBezel(tester, showReach: true);

    final frame = tester.getRect(
      find.byKey(const ValueKey('catalog_phone_frame')),
    );
    final panel = find.descendant(
      of: find.byKey(const ValueKey('catalog_phone_frame')),
      matching: find.byKey(const ValueKey('safaeh_panel')),
    );
    final before = tester.getRect(panel);
    expect(before.bottom, closeTo(frame.bottom - 8, 16));
    await tester.tap(find.byKey(const ValueKey('catalog_phone_reach')));
    await tester.pumpAndSettle();
    final after = tester.getRect(panel);
    expect(after.bottom, closeTo(before.bottom, 2));
    expect(after.bottom, closeTo(frame.bottom - 8, 16));
    expect(after.height, greaterThan(before.height + 40));
    expect(after.top, lessThan(before.top - 40));
    final stage = tester.getRect(find.byType(CatalogPhoneModalStage));
    final first = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.text('Name'),
      ),
    );
    expect(first.center.dy, closeTo(stage.center.dy, 16));
  });

  testWidgets('catalog locales share the same keys', (tester) async {
    final en = catalogTranslations['en']!.keys.toSet();
    for (final code in ['ar', 'ja', 'zh', 'es']) {
      expect(catalogTranslations[code]!.keys.toSet(), en, reason: code);
    }
  });

  test('catalog locales translate values', () {
    final en = catalogTranslations['en']!;
    for (final code in ['ar', 'ja', 'zh', 'es']) {
      final map = catalogTranslations[code]!;
      final leftover = en.keys
          .where(
            (key) =>
                !catalogSharedLiterals.contains(key) && map[key] == en[key],
          )
          .toList();
      expect(leftover, isEmpty, reason: '$code still English: $leftover');
    }
  });

  testWidgets('Arabic back arrow and status bar stay readable', (tester) async {
    await pumpExampleApp(tester, language: 'ar');

    expect(
      Directionality.of(tester.element(find.byType(CatalogGallery))),
      TextDirection.rtl,
    );
    expect(find.byIcon(Icons.chevron_right), findsWidgets);

    await _openTitle(tester, 'option_tiles');
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await _reveal(tester, 'sheet');
    await tester.tap(find.byKey(const ValueKey('catalog_sheet_phone')));
    await tester.pumpAndSettle();
    final time = tester.getRect(find.text('9:41'));
    final wifi = tester.getRect(find.byIcon(Icons.wifi));
    expect(time.left, lessThan(wifi.left));
  });

  testWidgets('RTL phone chrome puts close at start and reach at end', (
    tester,
  ) async {
    await pumpExampleApp(tester, language: 'ar', size: const Size(900, 844));

    await tester.ensureVisible(find.byKey(const ValueKey('catalog_sheet')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('catalog_sheet_phone')));
    await tester.pumpAndSettle();
    expect(
      Directionality.of(
        tester.element(find.byKey(const ValueKey('catalog_phone_chrome'))),
      ),
      TextDirection.rtl,
    );
    _expectPhoneChromeOutsideBezel(tester, showReach: true);
    final close = tester.getRect(
      find.byKey(const ValueKey('catalog_phone_close')),
    );
    final reach = tester.getRect(
      find.byKey(const ValueKey('catalog_phone_reach')),
    );
    expect(close.left, greaterThan(reach.left));
  });

  testWidgets('desktop catalog shows mock camera under camera and QR', (
    tester,
  ) async {
    await pumpExampleApp(tester, size: const Size(900, 844));

    await _reveal(tester, 'camera');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_camera')),
        matching: find.byKey(const ValueKey('catalog_mock_camera')),
      ),
      findsOneWidget,
    );
    expect(find.text('Demo camera'), findsWidgets);

    await _reveal(tester, 'qr_overlay');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_qr_overlay')),
        matching: find.byKey(const ValueKey('catalog_mock_camera')),
      ),
      findsOneWidget,
    );
    expect(find.text('Demo camera'), findsWidgets);
    expect(find.byType(CatalogGallery), findsOneWidget);
  });

  testWidgets('phone frame dismisses on close X and outside tap', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.tap(find.byKey(const ValueKey('catalog_sheet_phone')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_frame')), findsOneWidget);
    _expectPhoneChromeOutsideBezel(tester, showReach: true);

    await tester.tap(find.byKey(const ValueKey('catalog_phone_close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_frame')), findsNothing);
    expect(find.byType(CatalogGallery), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('catalog_sheet_phone')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(12, 820));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_frame')), findsNothing);
    expect(find.byType(CatalogGallery), findsOneWidget);
  });

  testWidgets('floating nav sits on the bottom of the banded demo', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'floating_nav');
    final section = find.byKey(const ValueKey('catalog_floating_nav'));
    final bar = find.descendant(
      of: section,
      matching: find.byType(SafaehFloatingNavBar),
    );
    expect(bar, findsOneWidget);
    final sectionBox = tester.getRect(section);
    final barBox = tester.getRect(bar);
    expect(barBox.bottom, closeTo(sectionBox.bottom, 24));
  });

  testWidgets('floating surface demo shows the background behind each style', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'floating_surface');
    final section = find.byKey(const ValueKey('catalog_floating_surface'));
    expect(
      find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('floating_style_theme')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('floating_style_nav_theme')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('floating_style_backdrop_0')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('floating_style_backdrop_4')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: section,
        matching: find.byType(ExcludeFocusTraversal),
      ),
      findsNWidgets(5),
    );
  });

  testWidgets('gallery camera and QR panels fit their cards', (tester) async {
    await pumpExampleApp(tester);

    for (final id in ['camera', 'qr_overlay', 'qr_message']) {
      await _reveal(tester, id);
      final section = find.byKey(ValueKey('catalog_$id'));
      final panel = find.descendant(
        of: section,
        matching: find.byKey(const ValueKey('safaeh_camera_panel')),
      );
      expect(panel, findsOneWidget);
      final sectionBox = tester.getRect(section);
      final panelBox = tester.getRect(panel);
      expect(panelBox.height, lessThanOrEqualTo(sectionBox.height));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('aligned chrome back only pops a pushed page', (tester) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'aligned_chrome');
    expect(find.byKey(const ValueKey('aligned_chrome_back')), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('catalog_aligned_chrome_phone')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_frame')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byKey(const ValueKey('aligned_chrome_back')),
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey('catalog_phone_close')));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGallery), findsOneWidget);

    await _openTitle(tester, 'aligned_chrome');
    expect(find.byKey(const ValueKey('aligned_chrome_back')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('aligned_chrome_back')));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGallery), findsOneWidget);
  });

  testWidgets('phone camera close dismisses the bezel', (tester) async {
    await pumpExampleApp(tester);

    await _reveal(tester, 'camera');
    await tester.tap(find.byKey(const ValueKey('catalog_camera_phone')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_frame')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('catalog_phone_frame')),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog_phone_frame')), findsNothing);
    expect(find.byType(CatalogGallery), findsOneWidget);
  });
}
