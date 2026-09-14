import 'package:flutter/material.dart';
import 'package:safaeh/safaeh.dart';

/// Edadat-style device chrome (`edadat/example/lib/app.dart` `_PhoneFrame`):
/// 390×844 bezel, 8px outline, 28px status strip. Content MediaQuery is
/// 390×816 with no extra padding so in-app SafeArea does not double-inset.
class CatalogPhoneFrame extends StatelessWidget {
  const CatalogPhoneFrame({super.key, required this.child});

  static const size = Size(390, 844);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('catalog_phone_frame'),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline, width: 8),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            ColoredBox(
              color: scheme.surface,
              child: SizedBox(
                height: 28,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ExcludeSemantics(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Text(
                            '9:41',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.signal_cellular_alt,
                            size: 14,
                            color: scheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.wifi, size: 14, color: scheme.onSurface),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.battery_full,
                            size: 14,
                            color: scheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(size.width, size.height - 28),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                ),
                child: ColoredBox(color: scheme.surface, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered bezel over the catalog. Scrim tap, chrome close, and system
/// back all return to the gallery. Sheet-like items also get a reach
/// toggle in the chrome row above the bezel.
Future<void> showCatalogPhonePreview({
  required BuildContext context,
  required Widget Function(SafaehPhoneSheetPlacement placement) builder,
  required String Function(String key) t,
  bool showReachToggle = false,
}) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return _CatalogPhonePreviewDialog(
        closeLabel: t('close'),
        showReachToggle: showReachToggle,
        t: t,
        builder: builder,
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _CatalogPhonePreviewDialog extends StatefulWidget {
  const _CatalogPhonePreviewDialog({
    required this.builder,
    required this.closeLabel,
    required this.t,
    required this.showReachToggle,
  });

  final Widget Function(SafaehPhoneSheetPlacement placement) builder;
  final String closeLabel;
  final String Function(String key) t;
  final bool showReachToggle;

  @override
  State<_CatalogPhonePreviewDialog> createState() =>
      _CatalogPhonePreviewDialogState();
}

class _CatalogPhonePreviewDialogState
    extends State<_CatalogPhonePreviewDialog> {
  var _placement = SafaehPhoneSheetPlacement.bottom;

  void _pop(BuildContext context) {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expanded = _placement == SafaehPhoneSheetPlacement.center;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            key: const ValueKey('catalog_phone_scrim'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _pop(context),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      key: const ValueKey('catalog_phone_chrome'),
                      width: CatalogPhoneFrame.size.width,
                      child: Row(
                        children: [
                          _CatalogPhoneChromeButton(
                            buttonKey: const ValueKey('catalog_phone_close'),
                            label: widget.closeLabel,
                            icon: Icons.close,
                            iconColor: scheme.onSurface,
                            onPressed: () => _pop(context),
                          ),
                          const Spacer(),
                          if (widget.showReachToggle)
                            _CatalogPhoneChromeButton(
                              buttonKey: const ValueKey('catalog_phone_reach'),
                              label: expanded
                                  ? widget.t('sheet_placement_bottom')
                                  : widget.t('sheet_placement_center'),
                              icon: expanded
                                  ? Icons.vertical_align_center
                                  : Icons.vertical_align_bottom,
                              iconColor: expanded
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              onPressed: () {
                                setState(() {
                                  _placement = expanded
                                      ? SafaehPhoneSheetPlacement.bottom
                                      : SafaehPhoneSheetPlacement.center;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    CatalogPhoneFrame(child: widget.builder(_placement)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CatalogPhoneChromeButton extends StatelessWidget {
  const _CatalogPhoneChromeButton({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Material(
        color: scheme.surfaceContainerHighest,
        elevation: 3,
        shadowColor: scheme.shadow.withValues(alpha: 0.32),
        shape: CircleBorder(side: BorderSide(color: scheme.outline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: buttonKey,
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Semantics(
            button: true,
            label: label,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 22, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
