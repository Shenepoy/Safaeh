import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

enum SafaehSheetActionState { ready, cooldown, working, failed }

/// Animated action presentation. The host owns timing, execution and retries.
///
/// [activity] is a normalized animation: determinate during cooldown, repeating
/// during work. Active states block the primary action and auxiliary slots.
/// Supply all [stateLabels] and reserveActionSpace to keep geometry stable.
/// Leading/trailing slots can be log controls, help, or any host-owned widget.
class SafaehSheetActionButton extends StatelessWidget {
  const SafaehSheetActionButton({
    super.key,
    required this.label,
    required this.activity,
    required this.onPressed,
    this.state = SafaehSheetActionState.ready,
    this.cooldownProgress = 0,
    this.color,
    this.foregroundColor,
    this.warningColor,
    this.stateLabels = const [],
    this.leading,
    this.trailing,
    this.reserveActionSpace = false,
    this.announcement,
    this.shape = const StadiumBorder(),
    this.borderWidth = 2,
    this.buttonKey,
    this.activityKey,
    this.glowKey,
  }) : assert(borderWidth >= 0);

  final String label;
  final Animation<double> activity;
  final VoidCallback? onPressed;
  final SafaehSheetActionState state;
  final double cooldownProgress;
  final Color? color, foregroundColor, warningColor;
  final List<String> stateLabels;
  final Widget? leading, trailing;
  final bool reserveActionSpace;
  final String? announcement;
  final OutlinedBorder shape;
  final double borderWidth;
  final Key? buttonKey, activityKey, glowKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cooling = state == SafaehSheetActionState.cooldown;
    final working = state == SafaehSheetActionState.working;
    final failed = state == SafaehSheetActionState.failed;
    final accent = color ?? theme.colorScheme.primary;
    final foreground = foregroundColor ?? theme.colorScheme.onPrimary;
    final active = cooling || working;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final warning =
        warningColor ??
        (theme.brightness == Brightness.dark
            ? Colors.amber.shade300
            : Colors.amber.shade700);
    final tint = accent;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: failed ? 1 : 0),
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 1100),
      builder: (context, value, child) {
        final glow = failed && !reducedMotion ? math.sin(value * math.pi) : 0.0;
        return DecoratedBox(
          // Keep this identity stable so error/recovery transitions animate
          // the existing button instead of mounting a fresh subtree.
          key: glowKey,
          decoration: ShapeDecoration(
            shape: shape,
            shadows: [
              if (glow > 0)
                BoxShadow(
                  color: warning.withValues(alpha: 0.36 * glow),
                  blurRadius: 12 + 12 * glow,
                  spreadRadius: 2 * glow,
                ),
            ],
          ),
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: activity,
        builder: (context, child) => Stack(
          children: [
            if (active)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipPath(
                    clipper: ShapeBorderClipper(shape: shape),
                    child: ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: CustomPaint(
                        key: activityKey,
                        painter: _ActivityPainter(
                          progress: reducedMotion
                              ? (working
                                    ? 0.55
                                    : cooldownProgress.clamp(0.0, 1.0))
                              : activity.value,
                          working: working,
                          rtl: Directionality.of(context) == TextDirection.rtl,
                          color: tint,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            child!,
            for (final slot in [(true, leading), (false, trailing)])
              PositionedDirectional(
                start: slot.$1 ? 8 : null,
                end: slot.$1 ? null : 8,
                top: 0,
                bottom: 0,
                width: 48,
                child: IgnorePointer(
                  ignoring: slot.$2 == null || active,
                  child: ExcludeFocus(
                    excluding: slot.$2 == null || active,
                    child: ExcludeSemantics(
                      excluding: slot.$2 == null || active,
                      child: AnimatedOpacity(
                        opacity: slot.$2 == null ? 0 : 1,
                        duration: reducedMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 140),
                        child: Center(child: slot.$2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: buttonKey,
            style: FilledButton.styleFrom(
              backgroundColor: failed ? Colors.amber.shade200 : accent,
              foregroundColor: failed ? Colors.black87 : foreground,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: theme.colorScheme.onSurface,
              minimumSize: const Size(0, 48),
              shape: shape,
              side: BorderSide(
                width: borderWidth,
                color: failed
                    ? warning
                    : active
                    ? tint.withValues(alpha: 0.75)
                    : Colors.transparent,
              ),
              animationDuration: reducedMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 360),
            ),
            onPressed: active ? null : onPressed,
            child: Semantics(
              liveRegion: true,
              excludeSemantics: cooling,
              label: announcement,
              child: Row(
                // Reserve the error icon slot so labels stay centered in every state.
                children: [
                  SizedBox(
                    width:
                        reserveActionSpace ||
                            leading != null ||
                            trailing != null
                        ? 48
                        : 8,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Measure all labels once per layout, including localized
                        // large text, so changing state cannot resize the button.
                        var height = 0.0;
                        for (final candidate in {...stateLabels, label}) {
                          final painter = TextPainter(
                            text: TextSpan(
                              text: candidate,
                              style: DefaultTextStyle.of(context).style,
                            ),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout(maxWidth: constraints.maxWidth);
                          height = math.max(height, painter.height);
                          painter.dispose();
                        }
                        return SizedBox(
                          height: height,
                          child: AnimatedSwitcher(
                            duration: reducedMotion
                                ? Duration.zero
                                : const Duration(milliseconds: 360),
                            switchInCurve: const Interval(
                              0.35,
                              1,
                              curve: Curves.easeOutCubic,
                            ),
                            switchOutCurve: const Interval(
                              0.6,
                              1,
                              curve: Curves.easeOut,
                            ),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween(
                                      begin: const Offset(0, 0.12),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child: Text(
                              label,
                              key: ValueKey(label),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width:
                        reserveActionSpace ||
                            leading != null ||
                            trailing != null
                        ? 48
                        : 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityPainter extends CustomPainter {
  const _ActivityPainter({
    required this.progress,
    required this.working,
    required this.rtl,
    required this.color,
  });
  final double progress;
  final bool working, rtl;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    if (working) {
      // A persistent wash and staggered passes keep the button occupied.
      // Each layer enters/leaves at zero opacity, hiding its cycle boundary
      // behind the other layers instead of resetting the whole fill.
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = color.withValues(alpha: 0.07),
      );
      for (final layer in [(0.0, 0.14), (0.35, 0.11), (0.7, 0.08)]) {
        final phase = (p + layer.$1) % 1.0;
        final width = size.width * phase;
        canvas.drawRect(
          Rect.fromLTWH(rtl ? size.width - width : 0, 0, width, size.height),
          Paint()
            ..color = color.withValues(
              alpha: layer.$2 * math.sin(math.pi * phase),
            ),
        );
      }
    } else {
      for (final layer in [(0.8, 0.10), (1.3, 0.14)]) {
        final width = size.width * math.pow(p, layer.$1);
        canvas.drawRect(
          Rect.fromCenter(
            center: size.center(Offset.zero),
            width: width,
            height: size.height,
          ),
          Paint()..color = color.withValues(alpha: layer.$2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ActivityPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      working != oldDelegate.working ||
      rtl != oldDelegate.rtl ||
      color != oldDelegate.color;
}
