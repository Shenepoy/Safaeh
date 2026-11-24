import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('without the extension colors match the ColorScheme getters', (
    tester,
  ) async {
    late SafaehStatusColors colors;
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: Builder(
          builder: (context) {
            colors = SafaehStatusColors.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors.success, scheme.success);
    expect(colors.warning, scheme.warning);
    expect(colors.danger, scheme.danger);
    expect(colors.onSuccess, scheme.onSuccess);
  });

  testWidgets('a registered extension overrides the derived colors', (
    tester,
  ) async {
    late SafaehStatusColors colors;
    const custom = SafaehStatusColors(
      success: Color(0xFFA9E5BB),
      onSuccess: Color(0xFF272727),
      warning: Color(0xFFE8A547),
      onWarning: Color(0xFF272727),
      danger: Color(0xFF5A2A27),
      onDanger: Color(0xFFFFFFFF),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [custom]),
        home: Builder(
          builder: (context) {
            colors = SafaehStatusColors.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors.success, const Color(0xFFA9E5BB));
    expect(colors.danger, const Color(0xFF5A2A27));
  });

  test('lerp blends and copyWith replaces', () {
    const a = SafaehStatusColors(
      success: Color(0xFF000000),
      onSuccess: Color(0xFF000000),
      warning: Color(0xFF000000),
      onWarning: Color(0xFF000000),
      danger: Color(0xFF000000),
      onDanger: Color(0xFF000000),
    );
    final b = a.copyWith(success: const Color(0xFFFFFFFF));
    expect(b.success, const Color(0xFFFFFFFF));
    expect(b.danger, a.danger);
    final mid = a.lerp(b, 0.5);
    expect(mid.success, isNot(a.success));
    expect(a.lerp(null, 0.5), a);
  });
}
