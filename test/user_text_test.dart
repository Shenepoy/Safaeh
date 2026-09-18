import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  group('safaehElideGraphemes', () {
    test('leaves short text unchanged', () {
      expect(safaehElideGraphemes('مرحبا', maxGraphemes: 40), 'مرحبا');
    });

    test('does not split emoji ZWJ sequences', () {
      const family = '👨‍👩‍👧‍👦';
      final long = List.filled(5, family).join();
      final elided = safaehElideGraphemes(long, maxGraphemes: 2);
      expect(elided, '$family$family…');
      expect(elided.characters.length, 3);
    });

    test('elides Arabic by grapheme count', () {
      const text = 'عنوان مصروف طويل جدا جدا جدا جدا جدا';
      final elided = safaehElideGraphemes(text, maxGraphemes: 10);
      expect(elided.endsWith('…'), isTrue);
      expect(elided.characters.length, 11);
    });
  });

  group('safaehIsolateBidi', () {
    test('wraps with FSI/PDI', () {
      expect(safaehIsolateBidi('Lunch'), '\u2068Lunch\u2069');
      expect(safaehUnwrapBidiIsolates(safaehIsolateBidi('عشاء')), 'عشاء');
    });
  });

  group('safaehResolveUserTextDirection', () {
    test('detects Arabic as RTL', () {
      expect(
        safaehResolveUserTextDirection('عشاء مع الأصدقاء'),
        TextDirection.rtl,
      );
    });

    test('detects Latin as LTR', () {
      expect(
        safaehResolveUserTextDirection('Dinner with friends'),
        TextDirection.ltr,
      );
    });

    test('inherits for digits-only', () {
      expect(safaehResolveUserTextDirection('12345'), isNull);
    });

    test('inherits for empty', () {
      expect(safaehResolveUserTextDirection('   '), isNull);
    });
  });

  group('safaehResolveUiStartTextAlign', () {
    test('uses right in RTL UI and left in LTR UI', () {
      expect(safaehResolveUiStartTextAlign(TextDirection.rtl), TextAlign.right);
      expect(safaehResolveUiStartTextAlign(TextDirection.ltr), TextAlign.left);
    });
  });

  testWidgets('SafaehUserText uses content direction for Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SafaehUserText('عشاء')),
      ),
    );
    final text = tester.widget<Text>(find.text('عشاء'));
    expect(text.textDirection, TextDirection.rtl);
  });
}
