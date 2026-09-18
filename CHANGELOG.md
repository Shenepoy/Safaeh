# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

Tags are `vX.Y.Z` and must match `version:` in [`pubspec.yaml`](pubspec.yaml).
See [VERSIONING.md](VERSIONING.md).

## [0.5.0] - 2026-09-18

### Added

- Shared list and status chrome: `SafaehEmptyState`, `SafaehInlineBanner`,
  `SafaehMetaChip`, `SafaehGlyphAvatar`, `SafaehKpiCard`,
  `SafaehBorderedListChrome`, `SafaehSectionHeader`, `SafaehLtrText`,
  `SafaehUserText`, `SafaehAsyncBody` / `SafaehLoadingBody`,
  `SafaehErrorBody`, and `SafaehSemanticStatus`.
- Accent and theme seams: `SafaehAccentStyle`, `SafaehAccentSurfaces`,
  `applySafaehMaterialChrome`, and `scaleSafaehTextTheme`.
- Rail-aware content band: `desktopBreakpoint`, `contentMaxWidthDesktop`,
  `safaehRailAwareBandMetrics`, `SafaehContentBand.railAware`,
  `SafaehContentAlignedPage`, `SafaehContentAlignedAppBar.forContentArea`,
  `SafaehContentAlignedFabLocation.of`.
- Debug shell: `showSafaehDebugMenu`, `SafaehDebugMenuFab`, section/action
  chrome, and `SafaehL10nEditOverlay` behind `SafaehL10nBackend` /
  `SafaehL10nOverrideStore`.
- `SafaehThemeData.sheetBodyInset` / `sheetBodyInsetWide` as the default
  adaptive-sheet `contentPadding` under the title bar.

### Docs

- Added [doc/chrome.md](doc/chrome.md) and
  [doc/debug-menu.md](doc/debug-menu.md), plus catalog demos for the new
  widgets.

## [0.4.2] - 2026-09-18

### Fixed

- Phone sheets keep their body mounted when the IME opens or closes. Swapping
  the home-indicator padding widget remounted text fields, re-ran autofocus,
  and brought the keyboard back so focus could not be dismissed.

## [0.4.1] - 2026-09-17

### Added

- Added `showSafaehActionSheet` / `SafaehAction` for list-row action menus.
- Added `showSafaehInfo` / `SafaehInfoSheet` for informational panels.
- Added `showSafaehTimedConfirm` / `SafaehTimedConfirmSheet` for countdown
  confirms, plus shared `SafaehContentPanel`.
- Tile options accept an optional `trailing` widget; multi-select can show a
  phone cancel control.
- Onboarding trackers can use `SafaehOnboardingTrackerStyle.legacyDots` and an
  optional `contentMaxWidth` for wide chrome.

### Changed

- Custom `showSafaehActionSheet` rows no longer own tap/pop. The sheet wraps
  `tileBuilder` output and pops the action value, matching tile pickers.

### Fixed

- Floating `showSafaeh` / `showSafaehDialog` panels stay centered in the full
  viewport. `railWidthOf` no longer shifts them when a host sidenav is open,
  collapsed, or opened after the sheet.
- Sidenav profile and footer chrome stay stable while the rail width animates.
- Wide auth surfaces size to their content instead of stretching the panel.

## [0.4.0] - 2026-09-15

### Added

- Added `SafaehMorphingAppBar` for page-positioned title crossfades and a
  stable host action slot.
- Added `SafaehMorphingAppBarAction` for page-aware action opacity and input
  handoff, plus `SafaehMorphingAppBarBottom` for clipped bottom chrome that
  reports its visible height.

### Docs

- Added pinned morphing app-bar host integration documentation and an
  interactive multilingual example catalog entry.

## [0.3.2] - 2026-09-15

### Added

- Added `SafaehAnchoredDropdownChip` and `SafaehDropdownOption` for reusable
  anchored menus with trigger-width sizing and host styling hooks.

### Changed

- Anchored dropdown menus now size from the rendered trigger, while still
  allowing longer option labels to expand within the menu limit.

## [0.3.1] - 2026-09-14

### Added

- Added host-controlled onboarding control and skip placement options,
  including bottom-centered language/theme controls and RTL-aware skip
  positions.
- Added public onboarding action-bar controls and preserved the zen preset as
  the default across the public onboarding components.

### Changed

- Made phone sheet dismissal require a size-aware drag distance and removed
  the visible overscroll stretch/glow from sheet bodies.

### Fixed

- Preserved the original scroll-end velocity vector when handing a top-edge
  pull to the phone sheet, avoiding invalid `DragEndDetails` assertions.

## [0.3.0] - 2026-09-12

### Added
- Added six public onboarding design presets: Meadow, Orbit, Paper, Atelier,
  Zen, and Prism.
- Added `SafaehOnboarding`, its host-owned step/label/action interfaces,
  public tracker, action bar, list primitives, and design catalog metadata.
- Added the vendor-neutral `SafaehAuthFlow` presentation module. It has no
  authentication or network dependency; hosts provide state and callbacks.
- Added an interactive onboarding/auth design catalog to the example app.

### Docs
- Documented public design selection, host persistence, custom controls,
  custom steps, and the generic auth adapter seam.

## [0.2.6] - 2026-09-12

### Fixed
- Phone sheet surfaces now remain flush with the viewport bottom safe-area
  inset while body content stays clear of the home indicator.
- Primary scrollable sheet bodies can hand a downward pull at their top edge
  to the sheet for drag-to-dismiss.

## [0.2.5] - 2026-09-10

### Docs
- Added an interactive feedback example to the multilingual catalog, including
  typed messages, action feedback, custom content, and dismissal.

## [0.2.4] - 2026-09-10

### Added
- Added a shared feedback host, typed feedback surfaces, action messages,
  custom feedback builders, and nav-aware bottom placement.
- Added a small app-facing feedback interface so host apps can keep
  localization and domain actions outside Safaeh while sharing presentation.

## [0.2.3] - 2026-09-10

### Added
- Added bottom-navigation metrics with separate visual and scroll-content
  clearance values.
- Added `SafaehBottomNavScope`, keyboard-aware nav hiding, and
  `SafaehBottomNavAwareFabLocation` for shell-owned floating navigation.
- Added optional bottom-nav clearance to `SafaehPageIndexOverlay`.

## [0.2.2] - 2026-09-09

### Added
- Shared `SafaehFloatingAppearance` options for transparent, translucent,
  iOS-style glass, and Vista/Aero-style glass package-owned floating surfaces.
- Theme, route, widget, and call-level appearance configuration with clipped
  backdrop blur, tint, border, and shadow overrides. Existing defaults remain
  unchanged when no appearance is configured.
- Added `SafaehSidenav(overlay: true)` for start-aligned rails that expand over
  host content and inherit the shared floating-surface appearance.

### Docs
- Added floating-surface and overlay-sidenav usage examples plus
  host-integration precedence notes.

## [0.2.1] - 2026-08-22

Pin Flutter 3.47.1 with FVM so local, IDE, and CI use the same SDK.

### Changed
- Pin Flutter **3.47.1** in `.fvmrc`, `.flutter-version`, and GitHub
  Actions. IDE SDK path is `.fvm/versions/3.47.1`. The FVM cache
  (`.fvm/`) is gitignored.
- Refresh lockfiles (`matcher`, `meta`, `test_api`, `vector_math`,
  `intl`) and exclude platform/`build` trees from the analyzer.

### Added
- Tile pickers accept `searchMatches` so hosts can filter without ASCII
  `toLowerCase()`.
- `SafaehQrMessageBody.closeTooltip` (defaults to
  `MaterialLocalizations.closeButtonTooltip`).
- Sidenav profile `labelBuilder` also wraps the subtitle (email LTR
  isolate).
- Camera handle labels: `handleExpandLabel` / `handleCollapseLabel` /
  `handleDismissLabel`.
- `showSafaeh` / `SafaehRouteOptions` accept `dismissLabel` and
  `closeTooltip`.

### Docs
- README widget images are captured with `widgets_to_image` instead of
  full-catalog screenshots. CI uploads those PNGs and deploys the
  example web build to GitHub Pages only after tests pass.
- Host integration documents Material localization fallbacks, required
  expand/collapse tooltips, physical-left band math, and the RTL icon
  contract.

### Fixed
- RTL chevrons and back arrows no longer double-flip: helpers keep the
  LTR glyph and let Material `matchTextDirection` mirror once.
- Sidenav destinations, floating-nav tabs, and page-index links announce
  `Semantics.selected`. Option tiles and cards announce selected and
  disabled.
- Page-index headers no longer force Latin `letterSpacing`.
- Overlay page-index pill announces expanded state.
- Tablet sheet close is an `IconButton` (tooltip + button semantics).
- Catalog card subtitles are real sentences in all five locales, not
  raw API tokens.
- Raised phone sheets treat an in-body title as chrome so the host
  child still centers.
- Sidenav titles no longer force negative `letterSpacing`.
- Avatar initials fold only Basic Latin; other scripts keep the first
  letter as written.
- Catalog `translateCatalog` asserts on a missing key in debug. Tests
  require non-allowlisted strings to differ from English.

## [0.2.0] - 2026-08-22

Phone-sheet reach, RTL chrome helpers, catalog phone frames, and the
first pub.dev publish path. See [VERSIONING.md](VERSIONING.md) for the
milestone exception to the usual MINOR = features rule.

### Added
- **`SafaehPhoneSheetPlacement`** / **`safaehPhoneCenterSheetTop`**: grow
  the phone bottom sheet so the first content center aligns with the
  phone center (still docked). Confirm, text input, and both pickers
  forward it.
- **RTL icons:** `safaehChevronEnd`, `safaehChevronStart`,
  `safaehArrowBack`.
- **`SafaehSidenavAvatar`**: primary circular initials when a profile
  has no `leading`.
- **`labelBuilder`** on `SafaehSidenavDestination` and
  `SafaehSidenavProfile`.
- **`SafaehQrScannerOverlay.preview`**: optional host camera feed or
  mock behind the viewfinder (no plugin in the package).
- **`SafaehRouteOptions`**: shared rail / size / motion / barrier /
  navigator bag on titled `show*` routes and `showSafaehDialog`.
- **`useRootNavigator`** / **`SafaehNavigatorScope`** / **`safaehPop`**:
  pickers and sheet chrome pop the same navigator that opened the route.
- **`SafaehLabelBuilder`** / **`safaehTitleFromLabel`**: same label
  wrapper on sidenav, floating nav, and page index; optional bridge for
  sheet titles.
- **`SafaehPageIndexEntry.labelBuilder`**.
- **`SafaehOptionPickerBody`**: embeddable card-picker list.
- **`showSafaehMultiTilePicker`**: multi-select list; confirm pops
  `List<T>`. Tile pickers take `searchHint` / `searchEmptyLabel`.
- **`SafaehStatusBody`**: empty / busy / action chrome (optional
  determinate `progress`). QR permission stays `SafaehQrMessageBody`.
- **`showSafaeh(dismissValue:)`** / **`dismissReturnsFalse`** on confirm.
- **Text-input knobs:** `keyboardType`, `textInputAction`,
  `inputFormatters`, `autocorrect`, `enableSuggestions`, `onChanged`.
- **`safaehFadeScale`** / **`safaehFade`** / **`safaehCurveFor`**:
  shared enter / exit curves. `show*` take `exitCurve`.
- **Camera knobs:** `motion`, `roll`, `railWidthOf`, `enterCurve`,
  `exitCurve`, `barrierDismissible`, `useRootNavigator`.

### Changed
- **CI / release**: Release workflow publishes to pub.dev via OIDC after
  verify + GitHub Release. READMEs use pub-style install.
- Baz Light is no longer registered as a package font, and
  `assets/fonts/baz-Light.otf` is not shipped (SVG outlines only).
- Selected card-picker and option-tile rows no longer show a check mark.
  Selection is the primary container fill, primary border, and
  `onPrimaryContainer` type.
- Option tiles, card-picker cards, confirm, and text-input chrome use
  `SafaehThemeData.radius`.
- Confirm primary action is a `FilledButton` (same as text-input Done).
- Floating nav defaults to `navMotion` and honors `labelBuilder`.
- QR success wash / frame use `ColorScheme.tertiary`.
- `kSheetContentPadding` aliases `kSafaehSheetPadding` on the sides.

### Fixed
- Directional chevrons and back arrows flip in RTL (`safaehChevronEnd`,
  `safaehChevronStart`, `safaehArrowBack`). The phone bezel status strip
  stays LTR so signal icons do not mirror in Arabic.
- Center phone sheets force the panel to the computed height so the
  modal paper stays flush with the bottom (not a shorter card in a tall
  box).
- Catalog phone chrome no longer stacks a status-bar `SafeArea` under the
  fake 9:41 strip. Narrow previews use a collapsed rail, an overlay page
  index, a drawer panel over a host, and a stacked end-aside.
- `SafaehFloatingNavBar` ignores top `SafeArea` so a bottom bar does not
  grow a gap above itself.
- `SafaehPhoneSheetPlacement.center` stays a bottom-docked sheet. The
  vertical center of the first body block after the handle aligns with
  the vertical center of the phone; the sheet no longer pins its top at
  mid-screen or floats as a centered card.
- Phone sheet bodies no longer apply status-bar `SafeArea` (`buildSafaehSheetShell`,
  `SafaehTilePickerBody`).
- Page-index active marker uses `BorderDirectional.start` in RTL.
- Sidenav collapse chevron follows `TextDirection`.
- Phone dismiss drag is limited to the sheet handle so lists can scroll.
- Sheet actions and confirm can take keyboard focus.
- `scrollToPageSection` honors `MediaQuery.disableAnimationsOf`.
- `scrollToPageSection` scrolls only the given controller / nearest
  scrollable. It no longer uses `Scrollable.ensureVisible`, which walked
  every ancestor viewport (and dragged the catalog).
- Phone / camera bottom panels slide the full sheet up from below (and down
  on exit). The old default only nudged 56px.
- Camera paper-roll enter/exit matches other bottom panels: fade plus a
  full-height `FractionalTranslation` (same family as `showSafaeh` /
  QR via `showSafaehCameraSheet`). Handle drag is unchanged.
- Sidenav profile without `leading` shows a primary circular avatar with
  initials (`SafaehSidenavAvatar`) instead of an empty `Icon(null)`.
- Card and tile pickers popped the nearest navigator; they now use
  `safaehPop` (root by default).
- `SafaehTextInputSheet` syncs `initialValue` in `didUpdateWidget`.
- `obscureText` forces `maxLines: 1`.
- Sheet action rows wrap with `OverflowBar`.
- Option tiles can take keyboard focus; `bodyLarge` is no longer
  force-unwrapped.
- Text-input `maxLength` shows the character counter again.
- Phone and camera drag handles expose dismiss semantics.
- Page-index overlay no longer double-`setState`s on close.

### Docs
- Host integration lives at `doc/host-integration.md` (pub layout).
- Confirm result (`true` / `false` / `null`) is spelled out in both READMEs.
- Example catalog wraps the vertical gallery in `SafaehContentBand`; section
  titles open the standalone demo (live sheet or pushed page). Camera and
  QR titles both use `showSafaehCameraSheet` so the panel slides up. Wide
  bands spread section cards across columns on the same page. Each card has
  its own phone-frame preview (Edadat bezel). Sheet cards include a reach
  toggle above the bezel that raises the sheet so the first content
  center aligns with the phone center. Camera and QR demos fill the
  panel with a mock
  viewfinder so desktop / web (and this catalog, which has no camera
  plugin) are not a black hole. The sheet-shell card is an export-report
  example (`buildSafaehSheetShell` + format tiles + Cancel/Save).
  Catalog also has multi-picker (search + confirm) and status-body
  cards. [doc/host-integration.md](doc/host-integration.md) covers the
  route bag, `safaehPop`, label builders, and confirm dismiss.

## [0.1.0] - 2026-08-21

First standalone release (extracted from Hisab). Host apps keep i18n,
routing, Riverpod, and camera plugins.

### Added
- **Sheets:** `showSafaeh` (phone sheet ↔ tablet dialog morph),
  `showSafaehPicker` / `SafaehOption` (card picker, `enabled`),
  `showSafaehTilePicker` / `SafaehTileOption` / `SafaehTilePickerBody`
  (list-row picker, optional `header` / `leading` / `enabled`),
  `showSafaehConfirm` / `SafaehConfirmSheet`,
  `showSafaehTextInput` / `SafaehTextInputSheet`,
  `buildSafaehSheetShell`, `SafaehOptionList`, `SafaehOptionTile`,
  `kSheetContentPadding`.
- **Dialog:** `showSafaehDialog` with optional `railWidthOf`.
- **Camera / QR chrome:** `showSafaehCameraSheet`, `SafaehCameraSheetHost`,
  `SafaehQrScannerOverlay`, `SafaehQrTopBar`, `SafaehQrMessageBody`,
  `SafaehQrFramePainter`, `SheetHandleBar`, `SheetHandleDrag`.
- **Nav:** `SafaehSidenav` (rail or `asDrawer: true`),
  `SafaehSidenavDestination`, `SafaehSidenavProfile`,
  `SafaehFloatingNavBar`.
- **Page index:** `SafaehPageIndex`, `SafaehPageIndexOverlay`,
  `scrollToPageSection`, `safaehActivePageSectionId`.
- **Content layout:** `SafaehContentBand`, `safaehBandMetrics`,
  `SafaehEndAsideLayout`, `SafaehContentAlignedAppBar`,
  `SafaehContentAlignedFabLocation`.
- **Tokens:** `SafaehTheme` / `SafaehThemeData` / `copyWith`,
  `safaehResolvedMotion` (zeros when `MediaQuery.disableAnimationsOf`).
- **Branding:** Baz Light vendored at `assets/fonts/baz-Light.otf`.
- **Docs:** bilingual READMEs, [doc/host-integration.md](doc/host-integration.md),
  this changelog, versioning notes, package CI template.

### Notes
- First standalone release. Depend via a git tag (`v0.1.0`).
- License is MPL-2.0.
