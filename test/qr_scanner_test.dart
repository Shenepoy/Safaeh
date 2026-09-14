import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('QR overlay shows title, hint, and close', (tester) async {
    final scanLine = AlwaysStoppedAnimation<double>(0.4);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SafaehQrScannerOverlay(
            scanLine: scanLine,
            title: const Text('Scan invite'),
            hint: const Text('Point at a code'),
            expanded: false,
            expandTooltip: 'Expand',
            collapseTooltip: 'Collapse',
            onClose: () {},
            onToggleExpanded: () {},
          ),
        ),
      ),
    );

    expect(find.text('Scan invite'), findsOneWidget);
    expect(find.text('Point at a code'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);
  });

  testWidgets('QR overlay paints a host preview behind the frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehQrScannerOverlay(
            preview: const ColoredBox(
              key: ValueKey('qr_preview'),
              color: Color(0xFF336699),
            ),
            scanLine: const AlwaysStoppedAnimation<double>(0.4),
            title: const Text('Scan'),
            expanded: false,
            onClose: () {},
            onToggleExpanded: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('qr_preview')), findsOneWidget);
  });

  testWidgets('QR message body shows action and close', (tester) async {
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SafaehQrMessageBody(
            onClose: () => closed = true,
            message: const Text('Need camera'),
            action: const Text('Open settings'),
          ),
        ),
      ),
    );

    expect(find.text('Need camera'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close))
          .tooltip,
      'Close',
    );
    await tester.tap(find.byIcon(Icons.close));
    expect(closed, isTrue);
  });

  test('frame painter repaints when scanT or success change', () {
    final a = SafaehQrFramePainter(scanT: 0.2, success: false);
    final b = SafaehQrFramePainter(scanT: 0.8, success: false);
    final c = SafaehQrFramePainter(scanT: 0.2, success: true);
    expect(a.shouldRepaint(b), isTrue);
    expect(a.shouldRepaint(c), isTrue);
    expect(
      a.shouldRepaint(SafaehQrFramePainter(scanT: 0.2, success: false)),
      isFalse,
    );
  });
}
