import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'content_band.dart';
import 'theme.dart';

/// Wraps [builder] so [SafaehContentAlignedAppBar] can receive the scaffold
/// width from a [LayoutBuilder].
class SafaehContentAlignedPage extends StatelessWidget {
  const SafaehContentAlignedPage({super.key, required this.builder});

  final Widget Function(BuildContext context, double contentAreaWidth) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(context, constraints.maxWidth),
    );
  }
}

/// An app bar that places [title] in a horizontal content band.
///
/// Pass the same [leftOffset] / [bandWidth] used for the body (from
/// [safaehBandMetrics] or the host's own rail math). No i18n or routing.
class SafaehContentAlignedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SafaehContentAlignedAppBar({
    super.key,
    required this.leftOffset,
    required this.bandWidth,
    this.leading,
    this.leadingWidth,
    required this.title,
    this.actions,
    this.centerTitle = true,
  });

  /// Rail-aware factory: compute [leftOffset] / [bandWidth] from the
  /// scaffold content area (typically [LayoutBuilder] max width).
  factory SafaehContentAlignedAppBar.forContentArea(
    BuildContext context, {
    Key? key,
    required double contentAreaWidth,
    Widget? leading,
    double? leadingWidth,
    required Widget title,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    final metrics = safaehRailAwareBandMetrics(context, contentAreaWidth);
    return SafaehContentAlignedAppBar(
      key: key,
      leftOffset: metrics.leftOffset,
      bandWidth: metrics.bandWidth,
      leading: leading,
      leadingWidth: leadingWidth,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  /// Physical left inset of the content band.
  final double leftOffset;

  /// Width of the content band.
  final double bandWidth;

  final Widget? leading;

  /// Minimum horizontal space reserved for [leading] when laying out the title.
  /// Defaults to [kToolbarHeight] when [leading] is non-null.
  final double? leadingWidth;

  final Widget title;
  final List<Widget>? actions;

  /// When true (default), the title is centered in the content band when it
  /// fits between the controls. When false, it is start-aligned (LTR/RTL).
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    final titleStyle =
        (appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge)?.copyWith(
          color: appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
        ) ??
        (theme.textTheme.titleLarge ?? theme.textTheme.bodyLarge!);

    return Material(
      color: appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      elevation: appBarTheme.elevation ?? 0,
      surfaceTintColor: appBarTheme.surfaceTintColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: CustomMultiChildLayout(
            delegate: _ContentAppBarLayout(
              leftOffset: leftOffset,
              bandWidth: bandWidth,
              leadingWidth: leadingWidth ?? kToolbarHeight,
              centerTitle: centerTitle,
              direction: Directionality.of(context),
            ),
            children: [
              if (leading != null)
                LayoutId(id: _AppBarSlot.leading, child: leading!),
              if (actions != null && actions!.isNotEmpty)
                LayoutId(
                  id: _AppBarSlot.actions,
                  child: SingleChildScrollView(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ),
                ),
              LayoutId(
                id: _AppBarSlot.title,
                child: ClipRect(
                  child: DefaultTextStyle(
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: title,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AppBarSlot { leading, actions, title }

class _ContentAppBarLayout extends MultiChildLayoutDelegate {
  _ContentAppBarLayout({
    required this.leftOffset,
    required this.bandWidth,
    required this.leadingWidth,
    required this.centerTitle,
    required this.direction,
  });

  final double leftOffset;
  final double bandWidth;
  final double leadingWidth;
  final bool centerTitle;
  final TextDirection direction;

  @override
  void performLayout(Size size) {
    const gap = 8.0;
    final edge = math.min(12.0, size.width / 2);
    final rtl = direction == TextDirection.rtl;
    var start = 0.0;
    var end = 0.0;

    double layoutControl(_AppBarSlot slot, double maxWidth, bool atLeft) {
      final child = layoutChild(
        slot,
        BoxConstraints(maxWidth: maxWidth, maxHeight: size.height),
      );
      final inset = child.width == 0 ? 0.0 : edge;
      positionChild(
        slot,
        Offset(
          atLeft ? inset : size.width - inset - child.width,
          (size.height - child.height) / 2,
        ),
      );
      return inset + child.width;
    }

    final innerWidth = size.width - 2 * edge;
    if (hasChild(_AppBarSlot.leading)) {
      start = layoutControl(_AppBarSlot.leading, innerWidth, !rtl);
    }
    if (hasChild(_AppBarSlot.actions)) {
      end = layoutControl(
        _AppBarSlot.actions,
        math.min(innerWidth, size.width - edge - start),
        rtl,
      );
    }
    if (hasChild(_AppBarSlot.leading)) start = math.max(start, leadingWidth);

    final bandLeft = leftOffset.clamp(0.0, size.width);
    final bandRight = (leftOffset + bandWidth).clamp(bandLeft, size.width);
    final left = math.max(bandLeft, rtl ? end : start) + gap;
    final right = math.min(bandRight, size.width - (rtl ? start : end)) - gap;
    final title = layoutChild(
      _AppBarSlot.title,
      BoxConstraints(
        maxWidth: math.max(0.0, right - left),
        maxHeight: size.height,
      ),
    );
    final lastX = math.max(left, right - title.width);
    final x = centerTitle
        ? ((bandLeft + bandRight - title.width) / 2).clamp(left, lastX)
        : (rtl ? lastX : left);
    positionChild(
      _AppBarSlot.title,
      Offset(x, (size.height - title.height) / 2),
    );
  }

  @override
  bool shouldRelayout(covariant _ContentAppBarLayout oldDelegate) =>
      oldDelegate.leftOffset != leftOffset ||
      oldDelegate.bandWidth != bandWidth ||
      oldDelegate.leadingWidth != leadingWidth ||
      oldDelegate.centerTitle != centerTitle ||
      oldDelegate.direction != direction;
}

/// Positions the scaffold FAB beside a content band on wide layouts.
///
/// Placement follows [textDirection]: end of the band (right in LTR, left in
/// RTL). Hosts decide when to fall back to [FloatingActionButtonLocation.endFloat]
/// — see [resolve].
class SafaehContentAlignedFabLocation extends FloatingActionButtonLocation {
  const SafaehContentAlignedFabLocation({
    required this.leftOffset,
    required this.bandWidth,
    required this.textDirection,
  });

  final double leftOffset;
  final double bandWidth;
  final TextDirection textDirection;

  /// Gap between the band edge and the FAB.
  static const double margin = 16;

  /// Minimum free width on the end side before aligned placement is used.
  static const double minGutterForAlign = 88;

  /// Returns an aligned location, or [narrowFallback] when [endFree] is tight.
  static FloatingActionButtonLocation resolve({
    required double leftOffset,
    required double bandWidth,
    required double endFree,
    required TextDirection textDirection,
    FloatingActionButtonLocation narrowFallback =
        FloatingActionButtonLocation.endFloat,
  }) {
    if (endFree < minGutterForAlign) return narrowFallback;
    return SafaehContentAlignedFabLocation(
      leftOffset: leftOffset,
      bandWidth: bandWidth,
      textDirection: textDirection,
    );
  }

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final fabSize = geometry.floatingActionButtonSize;
    final scaffoldSize = geometry.scaffoldSize;

    final y = geometry.contentBottom - margin - fabSize.height;

    if (textDirection == TextDirection.rtl) {
      final safeLeft = geometry.minInsets.left;
      var x = leftOffset - margin - fabSize.width;
      final minX = safeLeft + margin;
      if (x < minX) x = minX;
      if (x < 0) x = 0;
      return Offset(x, y);
    }

    final safeRight = geometry.minInsets.right;
    final contentRight = leftOffset + bandWidth;
    var x = contentRight + margin;
    final maxX = scaffoldSize.width - margin - fabSize.width - safeRight;
    if (x > maxX) x = maxX;
    if (x < 0) x = 0;

    return Offset(x, y);
  }

  @override
  bool operator ==(Object other) {
    return other is SafaehContentAlignedFabLocation &&
        other.leftOffset == leftOffset &&
        other.bandWidth == bandWidth &&
        other.textDirection == textDirection;
  }

  @override
  int get hashCode => Object.hash(leftOffset, bandWidth, textDirection);

  @override
  String toString() =>
      'SafaehContentAlignedFabLocation(left: $leftOffset, band: $bandWidth, '
      'dir: $textDirection)';

  /// Resolve a location from the scaffold's content-area width.
  ///
  /// Pass the same [contentAreaWidth] used for
  /// [SafaehContentAlignedAppBar.forContentArea] /
  /// [SafaehContentBand] (typically `LayoutBuilder` max width).
  static FloatingActionButtonLocation of(
    BuildContext context, {
    required double contentAreaWidth,
    FloatingActionButtonLocation narrowFallback =
        FloatingActionButtonLocation.endFloat,
  }) {
    if (!SafaehTheme.of(context).isWide(context)) {
      return narrowFallback;
    }
    final metrics = safaehRailAwareBandMetrics(context, contentAreaWidth);
    return resolve(
      leftOffset: metrics.leftOffset,
      bandWidth: metrics.bandWidth,
      endFree: metrics.endFree,
      textDirection: Directionality.of(context),
      narrowFallback: narrowFallback,
    );
  }
}

/// Follows responsive layout offsets without replaying Scaffold's relocation
/// scale and rotation.
///
/// Distinct from [FloatingActionButtonAnimator.noAnimation] so Scaffold can
/// still run the FAB's genuine initial entrance.
class SafaehLayoutFollowingFabAnimator extends FloatingActionButtonAnimator {
  const SafaehLayoutFollowingFabAnimator();

  @override
  Offset getOffset({
    required Offset begin,
    required Offset end,
    required double progress,
  }) => end;

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) =>
      const AlwaysStoppedAnimation<double>(1);

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) =>
      const AlwaysStoppedAnimation<double>(1);
}
