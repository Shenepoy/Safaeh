import 'package:safaeh/safaeh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'camera avoidance mirrors across physical sides without consuming the header',
    () {
      for (final right in [false, true]) {
        final camera = Rect.fromLTWH(right ? 750 : 18, 170, 32, 32);
        final layout = SafaehDisplayCutoutLayout(
          size: const Size(800, 400),
          cutouts: [camera],
          padding: right
              ? const EdgeInsets.only(right: 52)
              : const EdgeInsets.only(left: 52),
        );
        expect(layout.insetsForBand(top: 12, bottom: 68), EdgeInsets.zero);
        final content = layout.insetsForBand(top: 80, bottom: 376);
        expect(right ? content.right : content.left, 58);
        final target = Rect.fromLTWH(right ? 728 : 16, 176, 56, 124);
        final safe = layout.avoid(
          target,
          const Rect.fromLTRB(16, 80, 784, 376),
        );
        expect(safe.overlaps(camera.inflate(8)), isFalse);
        expect(safe.top, target.top);
        expect(right ? safe.right : safe.left, right ? 742 : 58);
      }
    },
  );

  test('camera handling preserves a separate navigation bar inset', () {
    final layout = SafaehDisplayCutoutLayout(
      size: const Size(800, 400),
      cutouts: [const Rect.fromLTWH(18, 170, 32, 32)],
      padding: const EdgeInsets.only(left: 52, right: 24, bottom: 16),
    );
    expect(layout.systemPadding, const EdgeInsets.only(right: 24, bottom: 16));
  });
}
