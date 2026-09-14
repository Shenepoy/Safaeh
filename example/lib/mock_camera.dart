import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Still “live” viewfinder for hosts without a camera plugin.
class CatalogMockCameraFeed extends StatelessWidget {
  const CatalogMockCameraFeed({
    super.key,
    required this.label,
    this.showLabel = true,
    this.labelPadding = const EdgeInsetsDirectional.only(start: 12, top: 12),
  });

  final String label;
  final bool showLabel;
  final EdgeInsetsGeometry labelPadding;

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    return Semantics(
      label: label,
      image: true,
      child: Stack(
        key: const ValueKey('catalog_mock_camera'),
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0E1214)),
          const IgnorePointer(
            child: CustomPaint(
              painter: _MockViewfinderPainter(),
              child: SizedBox.expand(),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 1.05,
                colors: [Color(0x00000000), Color(0x73000000)],
              ),
            ),
          ),
          if (showLabel)
            Positioned.directional(
              textDirection: dir,
              start: 0,
              top: 0,
              child: Padding(
                padding: labelPadding,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xB3000000),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x66FFFFFF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 10, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xF2FFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MockViewfinderPainter extends CustomPainter {
  const _MockViewfinderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24302A), Color(0xFF12161A), Color(0xFF1C222C)],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.26),
      size.shortestSide * 0.24,
      Paint()..color = const Color(0x40C4A574),
    );
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.38),
      size.shortestSide * 0.1,
      Paint()..color = const Color(0x28FFFFFF),
    );

    final horizon = size.height * 0.6;
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, size.width, size.height - horizon),
      Paint()..color = const Color(0xFF161A1C),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, horizon - 28, size.width * 0.28, 28),
      Paint()..color = const Color(0xFF2A3036),
    );

    final grain = Paint()..color = const Color(0x26FFFFFF);
    const step = 8.0;
    for (var y = 4.0; y < size.height; y += step) {
      for (var x = 4.0; x < size.width; x += step) {
        final n = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
        final frac = n - n.floorToDouble();
        if (frac > 0.64) {
          canvas.drawCircle(Offset(x + frac, y), 0.65, grain);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
