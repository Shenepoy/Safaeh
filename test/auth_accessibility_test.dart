import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('long Arabic auth divider wraps at large text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const divider = 'أو استخدم البريد الإلكتروني لتسجيل الدخول';
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: SafaehAuthFlow(labels: SafaehAuthLabels(emailDivider: divider)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final label = tester.getRect(find.text(divider));
    expect(label.left, greaterThanOrEqualTo(0));
    expect(label.right, lessThanOrEqualTo(390));
    expect(label.height, greaterThan(32));
  });
}
