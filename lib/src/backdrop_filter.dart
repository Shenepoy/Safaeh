import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// A backdrop blur that settles in gently once its route stops moving.
///
/// Animating the filter strength avoids an opacity layer around the backdrop.
/// Foreground content is retained while the blur changes. Static surfaces fade
/// on mount; modal surfaces wait until their entrance has completed so they do
/// not sample a moving backdrop or fight a parent fade's temporary save layer.
class SafaehBackdropFilter extends StatefulWidget {
  const SafaehBackdropFilter({
    super.key,
    required this.sigmaX,
    required this.sigmaY,
    required this.child,
    this.duration = const Duration(milliseconds: 160),
  }) : assert(sigmaX >= 0),
       assert(sigmaY >= 0);

  final double sigmaX;
  final double sigmaY;
  final Widget child;
  final Duration duration;

  @override
  State<SafaehBackdropFilter> createState() => _SafaehBackdropFilterState();
}

class _SafaehBackdropFilterState extends State<SafaehBackdropFilter> {
  Animation<double>? _routeAnimation;
  bool _entered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (identical(animation, _routeAnimation)) return;
    _routeAnimation?.removeStatusListener(_onStatus);
    _routeAnimation = animation;
    _entered =
        animation == null || animation.status == AnimationStatus.completed;
    _routeAnimation?.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (!_entered && status == AnimationStatus.completed) {
      setState(() => _entered = true);
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sigmaX == 0 && widget.sigmaY == 0) return widget.child;
    final reducedMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final content = RepaintBoundary(child: widget.child);
    if (reducedMotion) {
      return BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: widget.sigmaX,
          sigmaY: widget.sigmaY,
        ),
        child: content,
      );
    }
    final ready = _routeAnimation == null || _entered;
    final target = ready ? Offset(widget.sigmaX, widget.sigmaY) : Offset.zero;
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: Offset.zero, end: target),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: content,
      builder: (context, sigma, child) => BackdropFilter(
        enabled: sigma != Offset.zero,
        filter: ui.ImageFilter.blur(sigmaX: sigma.dx, sigmaY: sigma.dy),
        child: child,
      ),
    );
  }
}
