// Widgetbook 3.x settings use SDK Material, independently of the preview.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as sdk;
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';
import 'package:material_ui/material_ui.dart' as m;
import 'package:safaeh_widgetbook/main.dart';

import 'catalog_test.dart' show openStory, stateOf, setting;

void main() {
  for (final variant in ['rail', 'drawer', 'overlay']) {
    testWidgets('sidenav $variant item count keeps selection valid', (
      tester,
    ) async {
      await openStory(tester, 'navigation/sidenav/$variant');
      final state = stateOf(tester);
      SafaehSidenav nav() =>
          tester.widget<SafaehSidenav>(find.byType(SafaehSidenav));
      expect(nav().destinations, hasLength(20));
      nav().onDestinationSelected(19);
      await tester.pumpAndSettle();
      final slider = tester.widget<sdk.Slider>(find.byType(sdk.Slider));
      expect(slider.min, 2);
      expect(slider.max, 50);
      slider.onChanged!(2);
      await tester.pumpAndSettle();
      expect(nav().destinations, hasLength(2));
      expect(nav().selectedIndex, 1);
      expect(tester.takeException(), isNull);
      setting(state, 'knobs', 'Item count', '50');
      await tester.pumpAndSettle();
      expect(nav().destinations, hasLength(50));
      expect(nav().selectedIndex, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('editing text preserves the caret and supports empty values', (
    tester,
  ) async {
    await openStory(tester, 'controls/option-tile/default');
    final title = find.byWidgetPredicate(
      (widget) =>
          widget is sdk.TextFormField && widget.controller?.text == 'Selected',
    );
    await tester.showKeyboard(title);
    tester.testTextInput.updateEditingValue(
      const sdk.TextEditingValue(
        text: 'Edited title',
        selection: sdk.TextSelection.collapsed(offset: 3),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.byWidgetPredicate(
      (widget) =>
          widget is sdk.TextFormField &&
          widget.controller?.text == 'Edited title',
    );
    expect(
      tester.widget<sdk.TextFormField>(field).controller!.selection.baseOffset,
      3,
    );
    await tester.enterText(field, '');
    await tester.pumpAndSettle();
    expect(
      (tester.widget<SafaehOptionTile>(find.byType(SafaehOptionTile)).title
              as SafaehUserText)
          .data,
      '',
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'addon options reach the preview and survive a bookmarked reload',
    (tester) async {
      await openStory(tester, 'controls/option-tile/default');
      final state = stateOf(tester);
      sdk.BuildContext context() =>
          sdk.Navigator.of(tester.element(find.byType(SafaehOptionTile)))
              .context;
      for (final platform in sdk.TargetPlatform.values) {
        setting(state, 'environment', 'Platform', platform.name);
        await tester.pumpAndSettle();
        expect(m.Theme.of(context()).platform, platform);
      }
      for (final surface in SafaehFloatingSurfaceStyle.values) {
        setting(state, 'environment', 'Surface', surface.name);
        await tester.pumpAndSettle();
        expect(SafaehTheme.of(context()).floatingAppearance!.style, surface);
      }
      for (final locale in ['en', 'ar', 'ja', 'zh-CN', 'es']) {
        setting(state, 'locale', 'name', locale);
        await tester.pumpAndSettle();
        expect(sdk.Localizations.localeOf(context()).toLanguageTag(), locale);
        expect(
          sdk.Directionality.of(context()),
          locale == 'ar' ? sdk.TextDirection.rtl : sdk.TextDirection.ltr,
        );
      }
      for (final width in [320, 390, 599, 600, 601, 839, 840, 841, 1280]) {
        setting(state, 'viewport', 'name', '$width px');
        await tester.pumpAndSettle();
        expect(sdk.MediaQuery.sizeOf(context()).width, width);
      }
      setting(state, 'viewport', 'name', 'Phone with safe areas');
      setting(state, 'theme', 'name', 'Dark');
      setting(state, 'text-scale', 'factor', '2.0');
      setting(state, 'environment', 'Reduced motion', 'true');
      setting(state, 'environment', 'Simulated cutout', 'true');
      setting(state, 'environment', 'Keyboard inset', '300');
      setting(state, 'knobs', 'Title', 'Saved {title}: العربية, 50% & +');
      await tester.pumpAndSettle();
      void verify() {
        final media = sdk.MediaQuery.of(context());
        expect(media.size.width, 390);
        expect(
          media.viewPadding,
          const sdk.EdgeInsets.only(top: 44, bottom: 34),
        );
        expect(media.padding.bottom, 0);
        expect(media.viewInsets.bottom, 300);
        expect(media.disableAnimations, isTrue);
        expect(
          media.displayFeatures.single.bounds,
          const sdk.Rect.fromLTWH(16, 8, 32, 32),
        );
        expect(media.textScaler.scale(10), 20);
        expect(m.Theme.of(context()).brightness, sdk.Brightness.dark);
        expect(
          SafaehTheme.of(context()).floatingAppearance!.style,
          SafaehFloatingSurfaceStyle.vista,
        );
        expect(find.text('Saved {title}: العربية, 50% & +'), findsWidgets);
      }

      verify();
      final saved = state.uri.toString();
      await tester.pumpWidget(const sdk.SizedBox.shrink());
      await tester.pumpWidget(SafaehWidgetbook(initialRoute: saved));
      await tester.pumpAndSettle();
      verify();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'environment switches and keyboard slider operate independently',
    (tester) async {
      await openStory(tester, 'layout/keyboard-and-navigation/default');
      await tester.tap(find.text('Addons'));
      await tester.pumpAndSettle();
      Finder control(String label, Type type) => find.descendant(
        of: type == sdk.Switch
            ? find.widgetWithText(sdk.SwitchListTile, label)
            : find.byWidgetPredicate(
                (widget) =>
                    widget is sdk.Semantics && widget.properties.label == label,
              ),
        matching: find.byType(type),
      );
      final reduced = control('Reduced motion', sdk.Switch);
      await tester.ensureVisible(reduced);
      await tester.tap(find.text('Reduced motion'));
      await tester.pumpAndSettle();
      final cutout = control('Simulated cutout', sdk.Switch);
      await tester.ensureVisible(cutout);
      await tester.tap(find.text('Simulated cutout'));
      await tester.pumpAndSettle();
      final keyboard = control('Keyboard inset', sdk.Slider);
      await tester.ensureVisible(keyboard);
      await tester.tapAt(
        tester.getCenter(keyboard) +
            sdk.Offset(tester.getSize(keyboard).width / 4, 0),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(SafaehKeyboardAwareNav));
      final media = sdk.MediaQuery.of(context);
      expect(media.disableAnimations, isTrue);
      expect(media.displayFeatures, hasLength(1));
      expect(media.viewInsets.bottom, greaterThan(0));
      expect(SafaehBottomNavScope.maybeOf(context)!.visible, isFalse);
      expect(
        find.byKey(const sdk.ValueKey('safaeh_nav_keyboard_hidden')),
        findsOneWidget,
      );
      expect(tester.widget<sdk.Switch>(reduced).value, isTrue);
      expect(tester.widget<sdk.Switch>(cutout).value, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('boolean, enum and numeric knob controls update their widgets', (
    tester,
  ) async {
    await openStory(tester, 'controls/option-tile/default');
    // Order in this story: subtitle, selected, enabled, destructive, icon.
    await tester.tap(find.byType(sdk.Switch).at(1));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SafaehOptionTile>(find.byType(SafaehOptionTile)).selected,
      isFalse,
    );
    await openStory(tester, 'display/content-panel/default');
    final slider = find.byType(sdk.Slider);
    await tester.tapAt(
      tester.getCenter(slider) +
          sdk.Offset(tester.getSize(slider).width / 4, 0),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SafaehContentPanel>(find.byType(SafaehContentPanel))
          .padding,
      isNot(const sdk.EdgeInsets.all(14)),
    );
    await openStory(tester, 'feedback/inline-banner/info');
    await tester.tap(find.byType(sdk.DropdownMenu<SafaehBannerTone>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('error').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<SafaehInlineBanner>(find.byType(SafaehInlineBanner)).tone,
      SafaehBannerTone.error,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('visible text knob follows URL changes and locale defaults', (
    tester,
  ) async {
    await openStory(tester, 'controls/option-tile/default');
    final state = stateOf(tester);
    setting(state, 'knobs', 'Title', 'Restored from URL');
    await tester.pumpAndSettle();
    final fields = tester.widgetList<sdk.EditableText>(
      find.byType(sdk.EditableText),
    );
    expect(
      fields.map((field) => field.controller.text),
      contains('Restored from URL'),
    );
    setting(state, 'locale', 'name', 'ar');
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<sdk.EditableText>(find.byType(sdk.EditableText))
          .map((field) => field.controller.text),
      contains('تعبئة التحديد'),
    );
  });
  testWidgets('knob text fields follow the selected story', (tester) async {
    await openStory(tester, 'controls/option-tile/default');
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is sdk.TextFormField &&
            widget.controller?.text == 'Selected',
      ),
      'Edited title',
    );
    await tester.pumpAndSettle();
    expect(find.text('Edited title'), findsWidgets);
    await tester.tap(find.text('Long mixed text'));
    await tester.pumpAndSettle();
    const expected = 'حساب المصروفات المشتركة للعائلة — Shared family expenses';
    final tile = tester.widget<SafaehOptionTile>(find.byType(SafaehOptionTile));
    expect((tile.title as SafaehUserText).data, expected);
    final fields = tester.widgetList<sdk.EditableText>(
      find.byType(sdk.EditableText),
    );
    expect(fields.map((field) => field.controller.text), contains(expected));
    expect(
      fields.map((field) => field.controller.text),
      isNot(contains('Edited title')),
    );
  });

  testWidgets('every environment control has a visible label', (tester) async {
    await openStory(tester, 'controls/option-tile/default');
    await tester.tap(find.text('Addons'));
    await tester.pumpAndSettle();
    for (final label in [
      'Platform',
      'Surface',
      'Reduced motion',
      'Simulated cutout',
      'Keyboard inset',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });
}
