import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:safaeh/safaeh.dart';

import 'catalog.dart';
import 'onboarding_demo.dart';
import 'pages.dart';
import 'phone_frame.dart';

/// Min width of one gallery section card. Column count is
/// `max(1, bandWidth ~/ kCatalogMinColumnWidth)` from the band's incoming
/// width, not the raw window.
const double kCatalogMinColumnWidth = 360;

/// Lets [SafaehContentBand] grow wide enough for two or three section columns.
const double kCatalogBandMaxWidth = 1200;

const double kCatalogColumnGap = 20;
const double kCatalogRowGap = 28;
const EdgeInsets kCatalogGalleryPadding = EdgeInsets.fromLTRB(20, 12, 20, 40);

/// Gallery sections in display order. Items missing here land in the last
/// section so new catalog entries never disappear.
const catalogGroups = <(String, List<String>)>[
  (
    'group_sheets',
    [
      'sheet',
      'picker',
      'tile_picker',
      'multi_picker',
      'confirm',
      'text_input',
      'sheet_shell',
      'sheet_morph',
      'sheet_padding',
      'dialog',
    ],
  ),
  ('group_controls', ['option_tiles', 'anchored_popout', 'swatch']),
  (
    'group_feedback',
    ['feedback', 'status_body', 'empty_state', 'inline_banner', 'async_error'],
  ),
  (
    'group_display',
    [
      'kpi_card',
      'meta_chip',
      'glyph_avatar',
      'bordered_list',
      'section_header',
      'user_text',
      'accent_surfaces',
      'material_chrome',
    ],
  ),
  (
    'group_navigation',
    [
      'sidenav',
      'sidenav_drawer',
      'sidenav_overlay',
      'floating_nav',
      'floating_surface',
      'page_index',
      'page_index_overlay',
    ],
  ),
  (
    'group_layout',
    ['content_band', 'end_aside', 'aligned_chrome', 'morphing_app_bar'],
  ),
  ('group_camera', ['camera', 'qr_overlay', 'qr_message']),
  ('group_onboarding', ['onboarding_designs']),
  ('group_tools', ['debug_menu', 'l10n_editor']),
];

/// Demos that need room span two columns when the band has them.
const catalogWideItems = {
  'sidenav',
  'sidenav_drawer',
  'sidenav_overlay',
  'floating_surface',
  'page_index',
  'onboarding_designs',
};

List<(String, List<CatalogItem>)> catalogSections() {
  final byId = {for (final item in catalogItems) item.id: item};
  final sections = [
    for (final (key, ids) in catalogGroups)
      (key, [for (final id in ids) ?byId.remove(id)]),
  ];
  if (byId.isNotEmpty) sections.last.$2.addAll(byId.values);
  return [
    for (final s in sections)
      if (s.$2.isNotEmpty) s,
  ];
}

int catalogColumnCount(double bandWidth) {
  if (!bandWidth.isFinite || bandWidth <= 0) return 1;
  return math.max(1, bandWidth ~/ kCatalogMinColumnWidth);
}

/// Vertical gallery of catalog cards. Page-index chrome is **not** wired
/// here — [PageIndexRailDemo] / [PageIndexOverlayDemo] keep their own
/// scroll controllers and section keys.
class CatalogGallery extends StatefulWidget {
  const CatalogGallery({super.key, required this.t});

  final String Function(String key) t;

  @override
  State<CatalogGallery> createState() => CatalogGalleryState();
}

class CatalogGalleryState extends State<CatalogGallery> {
  final controller = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = catalogColumnCount(constraints.maxWidth);
        final inner = constraints.maxWidth - kCatalogGalleryPadding.horizontal;
        final unit = (inner - (columns - 1) * kCatalogColumnGap) / columns;
        double spanWidth(int span) =>
            span * unit + (span - 1) * kCatalogColumnGap;
        final entries = <Widget>[];
        final sections = catalogSections();
        for (var s = 0; s < sections.length; s++) {
          final (titleKey, items) = sections[s];
          entries.add(
            _GroupHeader(
              key: ValueKey('catalog_group_$titleKey'),
              title: t(titleKey),
              count: items.length,
              first: s == 0,
            ),
          );
          for (final row in _packRows(items, columns)) {
            entries.add(
              Padding(
                padding: const EdgeInsets.only(bottom: kCatalogRowGap),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < row.length; i++) ...[
                      if (i > 0) const SizedBox(width: kCatalogColumnGap),
                      SizedBox(
                        width: spanWidth(row[i].$2),
                        child: _section(context, row[i].$1, t),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        }
        return CustomScrollView(
          key: const ValueKey('catalog_gallery'),
          controller: controller,
          slivers: [
            SliverPadding(
              padding: kCatalogGalleryPadding,
              sliver: SliverList(delegate: SliverChildListDelegate(entries)),
            ),
          ],
        );
      },
    );
  }

  Widget _section(
    BuildContext context,
    CatalogItem item,
    String Function(String key) t,
  ) {
    return GallerySection(
      key: ValueKey('catalog_${item.id}'),
      title: t(item.titleKey),
      titleKey: ValueKey('catalog_${item.id}_title'),
      phoneKey: ValueKey('catalog_${item.id}_phone'),
      subtitle: item.subtitleKey == null ? null : t(item.subtitleKey!),
      phoneLabel: t('preview_phone'),
      onOpen: () => openCatalogItem(context, item.id, t),
      onPhonePreview: () => showCatalogPhonePreview(
        context: context,
        t: t,
        showReachToggle: catalogSheetUsesReachToggle(item.id),
        builder: (placement) =>
            catalogPhonePreview(item.id, t, placement: placement),
      ),
      child: galleryPreview(item.id, t),
    );
  }
}

/// Fills rows start-first. A hole left by a wide item is backfilled with the
/// next narrow item in the section; otherwise the row's last item stretches.
List<List<(CatalogItem, int)>> _packRows(List<CatalogItem> items, int columns) {
  int spanOf(CatalogItem item) =>
      catalogWideItems.contains(item.id) ? math.min(2, columns) : 1;
  final pending = [...items];
  final rows = <List<(CatalogItem, int)>>[];
  while (pending.isNotEmpty) {
    final row = <(CatalogItem, int)>[];
    var used = 0;
    while (used < columns) {
      final free = columns - used;
      final index = pending.indexWhere((item) => spanOf(item) <= free);
      if (index < 0) break;
      final item = pending.removeAt(index);
      row.add((item, spanOf(item)));
      used += spanOf(item);
    }
    if (used < columns) {
      final (last, span) = row.removeLast();
      row.add((last, span + columns - used));
    }
    rows.add(row);
  }
  return rows;
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    super.key,
    required this.title,
    required this.count,
    required this.first,
  });

  final String title;
  final int count;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(4, first ? 4 : 16, 4, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                '$count',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: cs.outlineVariant)),
        ],
      ),
    );
  }
}

class GallerySection extends StatelessWidget {
  const GallerySection({
    super.key,
    required this.title,
    required this.child,
    required this.onOpen,
    required this.onPhonePreview,
    required this.phoneLabel,
    this.subtitle,
    this.titleKey,
    this.phoneKey,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onOpen;
  final VoidCallback onPhonePreview;
  final String phoneLabel;
  final Key? titleKey;
  final Key? phoneKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    key: titleKey,
                    button: true,
                    label: title,
                    excludeSemantics: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onOpen,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Icon(
                                safaehChevronEnd(context),
                                color: cs.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: IconButton(
                    key: phoneKey,
                    tooltip: phoneLabel,
                    onPressed: onPhonePreview,
                    icon: Icon(
                      Icons.smartphone_outlined,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget galleryPreview(String id, String Function(String key) t) {
  switch (id) {
    case 'sheet':
      return AdaptiveSheetDemo(t: t);
    case 'picker':
      return CardPickerDemo(t: t);
    case 'tile_picker':
      return SizedBox(height: 320, child: TilePickerDemo(t: t));
    case 'multi_picker':
      return SizedBox(height: 360, child: MultiTilePickerDemo(t: t));
    case 'status_body':
      return StatusBodyDemo(t: t);
    case 'feedback':
      return SizedBox(height: 300, child: FeedbackDemo(t: t));
    case 'empty_state':
      return EmptyStateDemo(t: t);
    case 'inline_banner':
      return InlineBannerDemo(t: t);
    case 'meta_chip':
      return MetaChipDemo(t: t);
    case 'glyph_avatar':
      return GlyphAvatarDemo(t: t);
    case 'kpi_card':
      return KpiCardDemo(t: t);
    case 'bordered_list':
      return BorderedListDemo(t: t);
    case 'section_header':
      return SectionHeaderDemo(t: t);
    case 'async_error':
      return AsyncErrorDemo(t: t);
    case 'user_text':
      return UserTextDemo(t: t);
    case 'accent_surfaces':
      return AccentSurfacesDemo(t: t);
    case 'material_chrome':
      return MaterialChromeDemo(t: t);
    case 'debug_menu':
      return SizedBox(height: 160, child: DebugMenuDemo(t: t));
    case 'l10n_editor':
      return L10nEditorDemo(t: t);
    case 'sheet_padding':
      return SizedBox(height: 320, child: SheetPaddingDemo(t: t));
    case 'confirm':
      return ConfirmDemo(t: t);
    case 'text_input':
      return TextInputDemo(t: t);
    case 'sheet_shell':
      return SheetShellDemo(t: t);
    case 'sheet_morph':
      return SheetMorphDemo(t: t);
    case 'option_tiles':
      return OptionTilesDemo(t: t);
    case 'anchored_popout':
      return AnchoredPopoutDemo(t: t);
    case 'swatch':
      return SwatchPickerDemo(t: t);
    case 'dialog':
      return DialogDemo(t: t);
    case 'sidenav':
      return SizedBox(height: 360, child: SidenavRailDemo(t: t));
    case 'sidenav_drawer':
      return SizedBox(height: 360, child: SidenavDrawerDemo(t: t));
    case 'sidenav_overlay':
      return SizedBox(height: 360, child: SidenavOverlayDemo(t: t));
    case 'floating_nav':
      return SizedBox(height: 240, child: FloatingNavDemo(t: t));
    case 'floating_surface':
      return SizedBox(height: 360, child: FloatingSurfaceStylesDemo());
    case 'page_index':
      return SizedBox(height: 280, child: PageIndexRailDemo(t: t));
    case 'page_index_overlay':
      return SizedBox(height: 320, child: PageIndexOverlayDemo(t: t));
    case 'content_band':
      return SizedBox(height: 160, child: ContentBandDemo(t: t));
    case 'end_aside':
      return SizedBox(height: 140, child: EndAsideDemo(t: t));
    case 'aligned_chrome':
      return SizedBox(height: 220, child: AlignedChromeDemo(t: t));
    case 'morphing_app_bar':
      return SizedBox(height: 340, child: MorphingAppBarDemo(t: t));
    case 'camera':
      return SizedBox(
        height: 300,
        child: _galleryConstrainedMedia(child: CameraDemo(t: t)),
      );
    case 'qr_overlay':
      return SizedBox(
        height: 360,
        child: _galleryConstrainedMedia(child: QrOverlayDemo(t: t)),
      );
    case 'qr_message':
      return SizedBox(
        height: 280,
        child: _galleryConstrainedMedia(child: QrMessageDemo(t: t)),
      );
    case 'onboarding_designs':
      return SizedBox(height: 520, child: OnboardingDesignDemo(t: t));
    default:
      return const SizedBox.shrink();
  }
}

/// Camera/QR hosts size the paper-roll from [MediaQuery.size]. Gallery cards
/// are 280–360px tall, so copy incoming constraints into MediaQuery. Do not
/// wrap the phone-bezel path — that frame sizes content to 390×816.
Widget _galleryConstrainedMedia({required Widget child}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final mq = MediaQuery.of(context);
      final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
          ? constraints.maxWidth
          : mq.size.width;
      final height = constraints.maxHeight.isFinite && constraints.maxHeight > 0
          ? constraints.maxHeight
          : mq.size.height;
      return MediaQuery(
        data: mq.copyWith(size: Size(width, height)),
        child: child,
      );
    },
  );
}

Future<void> _popCatalogPhonePreview(BuildContext context) async {
  final nav = Navigator.of(context, rootNavigator: true);
  if (nav.canPop()) nav.pop();
}

/// In-bezel camera/QR close pops the phone dialog. Gallery cards keep the
/// default no-op [CameraDemo.onDismiss] so they stay inert.
Widget _phonePreviewCamera({
  required Widget Function(Future<void> Function() onDismiss) builder,
}) {
  return SizedBox.expand(
    child: Builder(
      builder: (context) => builder(() => _popCatalogPhonePreview(context)),
    ),
  );
}

bool catalogSheetUsesReachToggle(String id) {
  return const {
    'sheet',
    'picker',
    'tile_picker',
    'multi_picker',
    'confirm',
    'text_input',
    'sheet_shell',
    'sheet_morph',
  }.contains(id);
}

/// Phone-bezel preview: bottom sheets stay docked, dialogs stay centered,
/// and mobile-full chrome fills the frame.
Widget catalogPhonePreview(
  String id,
  String Function(String key) t, {
  SafaehPhoneSheetPlacement placement = SafaehPhoneSheetPlacement.bottom,
}) {
  final raised = placement == SafaehPhoneSheetPlacement.center;

  Widget modal(Widget sheet) {
    return CatalogPhoneModalStage(child: sheet);
  }

  switch (id) {
    case 'sheet':
    case 'sheet_morph':
      return modal(AdaptiveSheetDemo(t: t, raised: raised));
    case 'picker':
      return modal(
        PhoneSheetFrame(
          title: t('settle'),
          raised: raised,
          showTitle: false,
          child: CardPickerDemo(t: t),
        ),
      );
    case 'tile_picker':
      return modal(
        PhoneSheetFrame(
          title: t('choose_account'),
          raised: raised,
          showTitle: false,
          child: TilePickerDemo(t: t),
        ),
      );
    case 'multi_picker':
      return modal(
        PhoneSheetFrame(
          title: t('choose_account'),
          raised: raised,
          showTitle: false,
          child: MultiTilePickerDemo(t: t),
        ),
      );
    case 'status_body':
      return Padding(
        padding: const EdgeInsets.all(16),
        child: StatusBodyDemo(t: t),
      );
    case 'feedback':
      return Padding(
        padding: const EdgeInsets.all(16),
        child: FeedbackDemo(t: t),
      );
    case 'confirm':
      return modal(
        PhoneSheetFrame(
          title: t('delete_item'),
          raised: raised,
          showTitle: false,
          child: ConfirmDemo(t: t),
        ),
      );
    case 'text_input':
      return modal(
        PhoneSheetFrame(
          title: t('tag_name'),
          raised: raised,
          showTitle: false,
          child: TextInputDemo(t: t),
        ),
      );
    case 'sheet_shell':
      return modal(
        PhoneSheetFrame(
          title: t('export_report'),
          raised: raised,
          showTitle: false,
          child: SheetShellDemo(t: t, interactive: true),
        ),
      );
    case 'dialog':
      return DialogDemo(t: t, fill: true);
    case 'option_tiles':
      return Padding(
        padding: const EdgeInsets.all(16),
        child: OptionTilesDemo(t: t),
      );
    case 'anchored_popout':
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AnchoredPopoutDemo(t: t),
      );
    case 'swatch':
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SwatchPickerDemo(t: t),
      );
    case 'sidenav':
      return SizedBox.expand(child: SidenavRailDemo(t: t));
    case 'sidenav_drawer':
      return SizedBox.expand(child: SidenavDrawerDemo(t: t));
    case 'sidenav_overlay':
      return SizedBox.expand(child: SidenavOverlayDemo(t: t));
    case 'floating_nav':
      return SizedBox.expand(child: FloatingNavDemo(t: t));
    case 'floating_surface':
      return SizedBox.expand(child: FloatingSurfaceStylesDemo());
    case 'page_index':
      return SizedBox.expand(child: PageIndexRailDemo(t: t));
    case 'page_index_overlay':
      return SizedBox.expand(child: PageIndexOverlayDemo(t: t));
    case 'content_band':
      return SizedBox.expand(child: ContentBandDemo(t: t));
    case 'end_aside':
      return SizedBox.expand(child: EndAsideDemo(t: t));
    case 'aligned_chrome':
      return SizedBox.expand(child: AlignedChromeDemo(t: t));
    case 'camera':
      return _phonePreviewCamera(
        builder: (onDismiss) => CameraDemo(t: t, onDismiss: onDismiss),
      );
    case 'qr_overlay':
      return _phonePreviewCamera(
        builder: (onDismiss) => QrOverlayDemo(t: t, onDismiss: onDismiss),
      );
    case 'qr_message':
      return _phonePreviewCamera(
        builder: (onDismiss) => QrMessageDemo(t: t, onDismiss: onDismiss),
      );
    default:
      return galleryPreview(id, t);
  }
}
