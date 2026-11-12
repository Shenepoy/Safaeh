import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh_example/app.dart';

const screenshotSize = Size(390, 844);

Future<void> pumpExampleApp(
  WidgetTester tester, {
  String language = 'en',
  ThemeMode themeMode = ThemeMode.light,
  Size size = screenshotSize,
}) async {
  tester.view.physicalSize = Size(size.width * 2, size.height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    SafaehExampleApp(initialLocale: language, initialThemeMode: themeMode),
  );
  await tester.pumpAndSettle();
}
