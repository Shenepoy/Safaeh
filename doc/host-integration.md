# Host integration

Safaeh provides shared layout and interaction patterns. Each host supplies its
own colors, typography, copy, routing, state, and camera plugins.

## Choose a widget

| Need | Use | Widgetbook |
|------|-----|------------|
| A modal choice, confirmation, or form | Safaeh's sheet helper or `SafaehSheetTemplate` for a custom layout | Sheets |
| A choice attached to a trigger | Safaeh dropdowns for a single value or independent toggles | Controls → Dropdown |
| A sidebar, phone navigation, or shared toolbar | Safaeh sidenav, floating nav, or app bar | Navigation |
| Links to sections within a page | `SafaehPageIndex` for a visible index or `SafaehPageIndexOverlay` where space is limited. Give each section a stable key and use the page's scroll controller. | Navigation → Page index |
| Short forms in content-sized tabs | `SafaehTabView` with a matching `TabController` and stable child keys. Use a pager when the app needs swipes between full pages. | Layout → Tab forms |
| Onboarding or account screens | `SafaehOnboarding` or `SafaehAuthFlow`, with host-provided state, labels, and callbacks | Onboarding |
| Camera and scanning | `SafaehCameraSheetHost` for the panel and `SafaehQrScannerOverlay` for viewfinder chrome. Keep permissions, preview, and decoding in the host. | Camera |
| Transient messages or inline status | `SafaehFeedbackHost` for toasts, `SafaehInlineBanner` for messages in content, and `SafaehAsyncBody` for loading, error, empty, and data states | Feedback |
| Calendar, color, and cycle controls | `SafaehMonthCalendar`, `SafaehSwatchPicker`, and `SafaehCycleButton`. Supply localized option names through the swatch `labelBuilder`. | Controls |
| Map or itinerary UI | `SafaehSnapSheet` for a non-modal panel, `SafaehTimeline` for ordered stops, and `SafaehSectionChips` for switching sections. Use the snap sheet's controller for the primary body scrollable. | Itinerary |
| Layout and display primitives | `SafaehContentBand`, content-aligned layout, and the [shared chrome widgets](chrome.md) | Layout and Display |
| Debug and translation tools | The [debug menu and translation editor](debug-menu.md), using host-selected access and storage | Developer tools |

Check a narrow and a wide layout plus any relevant breakpoint transition.
For interactive widgets, exercise keyboard and pointer input, RTL, large
text, reduced motion, and the host callback or result. Camera, keyboard,
cutout, and system Back behavior also need device validation.

## Sheet template seam

[Safaeh sheet templates](sheet-templates.md) provide content slots, pinned
footers, reading surfaces, safe read/loading states, and action animations.
The host keeps validation, persistence, action policies, localization, and
logging. Existing sheet helpers are unchanged; template adoption is additive.

## Dropdowns

Use `SafaehAnchoredDropdownChip<T>` for a compact, immediate choice attached to
a trigger, such as sort order or a short list of filter values. Use
`SafaehAnchoredDropdownChip<T>.scrollable` when more choices should stay
anchored. The panel scrolls when the rows exceed `maxHeight` (240 logical
pixels by default), and Safaeh further limits it to the available space. Use
`SafaehAnchoredToggleDropdownChip<T>` for independent checkbox choices. Pass
the checked values as `selectedValues` and update them in `onToggled`. Changes
take effect immediately and the menu stays open for further toggles.

Use `showSafaehTilePicker` when the list needs search or a larger layout. Use
`showSafaehMultiTilePicker` when multiple choices need a separate confirmation
step. For a custom anchored panel with richer content, use `showSafaehAnchored`.

Pass the current value as `selected`, its localized text as `label`, and a
localized label for each `SafaehDropdownOption<T>`. Update the host state in
`onSelected` so the trigger label and highlighted row reflect the new value.
Safaeh handles anchoring, menu spacing, and dismissal. Keep automatic width
sizing for standard chips. Set `expand: true` inside a width-constrained parent
when the trigger should fill the available space. For `iconOnly: true`, keep
the `label` meaningful because it becomes the tooltip.

The dropdown uses the host's Material colors and typography. Use
`labelBuilder` for custom text rendering and the selected-row color options
for app-specific accents. In Widgetbook, open **Controls → Dropdown → Scrollable**,
scroll to a later choice, select it, and reopen the menu to check its highlight.
In **Controls → Dropdown → Toggles**, change two choices without reopening the
menu. Also check outside tap dismissal, keyboard selection, and menu placement
at narrow widths and in RTL.

## Onboarding design seam

Safaeh ships six complete public onboarding directions:

```dart
enum SafaehOnboardingDesign { meadow, orbit, paper, atelier, zen, prism }
```

Select one directly on `SafaehOnboarding`; Zen is the default. Hosts can
persist the selected `design.id` in their own settings, or build a picker from
`SafaehOnboardingDesignCatalog.all`. Safaeh does not persist application
preferences.

The onboarding module owns page navigation, trackers, action bars, responsive
surfaces, motion, semantics, and RTL-safe layout. The host supplies
`SafaehOnboardingStep` builders, localized `SafaehOnboardingLabels`, language
and theme controls, and the completion callback. This keeps the module deep:
one small host interface provides six visual implementations.

`SafaehAuthFlow` is the same kind of presentation adapter for sign-in, sign-up,
profile, password reset, magic link, provider buttons, and pending email. It
accepts neutral snapshots and callbacks only. It never imports an auth SDK,
performs network calls, or decides whether a session is valid.

Language and theme controls are placed in the top bar by default. Set
`controlPlacement` to `SafaehOnboardingControlPlacement.bottomCenter` to put
the host-provided controls together at the bottom center; the Back and Next
actions remain in their normal leading/trailing positions.

For a custom host design, use the public `SafaehOnboardingListItem`,
`SafaehOnboardingTracker`, and `SafaehOnboardingActionBar` primitives while
keeping the same host-owned copy and callbacks. The example catalog previews
all six presets, Arabic/RTL, themes, reduced motion, and auth states.

### Persist a design in the host

Safaeh intentionally does not write preferences. Store the stable ID in the
host and fall back to Zen when a value is missing or was introduced by a
future version:

```dart
final saved = settings.getString('onboarding_design');
final design = SafaehOnboardingDesignCatalog.tryParse(saved ?? '') ??
    SafaehOnboardingDesign.zen;

await settings.setString('onboarding_design', design.id);
```

### Build a design picker

Use the public catalog to populate the choices. `design` is the current value
in the host's state.

```dart
SafaehAnchoredDropdownChip<SafaehOnboardingDesign>(
  icon: Icons.palette_outlined,
  label: SafaehOnboardingDesignCatalog.all
      .firstWhere((info) => info.design == design)
      .displayName,
  selected: design,
  options: [
    for (final info in SafaehOnboardingDesignCatalog.all)
      SafaehDropdownOption(
        value: info.design,
        label: info.displayName,
      ),
  ],
  onSelected: (next) => setState(() => design = next),
)
```

### Localized controls and custom steps

Labels, controls, illustrations, and domain actions remain host-owned. Pass
localized widgets and content builders directly:

```dart
SafaehOnboarding(
  design: design,
  controlPlacement: SafaehOnboardingControlPlacement.bottomCenter,
  labels: SafaehOnboardingLabels(
    back: l10n.back,
    next: l10n.continueLabel,
    complete: l10n.finish,
    stepProgress: (current, total) => l10n.step(current, total),
  ),
  actions: SafaehOnboardingHostActions(
    languageControl: LanguageSwitcher(onChanged: changeLocale),
    themeControl: ThemeSwitcher(onChanged: changeTheme),
    onComplete: saveAndFinish,
  ),
  steps: [
    SafaehOnboardingStep(
      id: 'welcome',
      titleBuilder: (_) => Text(l10n.welcome),
      bodyBuilder: (_) => HostIllustrationStep(),
    ),
  ],
)
```

### Auth is optional

Use `SafaehOnboarding` alone for local or guest onboarding. If the host has an
account flow, `SafaehAuthFlow` accepts a neutral `SafaehAuthSnapshot` and
callbacks such as `onProvider` and `onSubmit`; the host remains responsible
for OAuth, sessions, errors, and routing.

## `railWidthOf`

`showSafaeh` and `showSafaehDialog` still accept

```dart
double Function(BuildContext context)? railWidthOf
```

for API compatibility with older hosts. Floating sheets and dialogs stay
centered in the **full viewport**. A permanent rail, overlay sidenav, or
temporary drawer must not shift the panel, and later rail changes must not
move an already-open sheet.

Camera / QR paper-roll sheets still use `railWidthOf` to keep the roll
beside a host rail.

Phone sheets ignore `railWidthOf`.

`showSafaeh` paints the title in the phone body by default
(`paintPhoneTitle: true`). Confirm, text input, and pickers pass
`false` because they already title the in-body list. Raised
(`center`) sheets count that title as handle chrome so the first host
child still lines up with the phone center.

When `contentPadding` is omitted, the adaptive host applies
`SafaehThemeData.sheetBodyInset` (phone) or `sheetBodyInsetWide`
(tablet+ dialog) so tile pickers, option lists, and custom children
share one inset under the title bar. Pass
`contentPadding: EdgeInsets.zero` for edge-to-edge bodies (camera, QR).
See [chrome.md](chrome.md) for list/status widgets and
[debug-menu.md](debug-menu.md) for the debug shell.

## Phone sheet placement

`showSafaeh` (and confirm / text / pickers that go through it) accepts

```dart
SafaehPhoneSheetPlacement phonePlacement
```

Default is `bottom`. Pass `SafaehPhoneSheetPlacement.center` to grow the
phone bottom sheet upward so the vertical center of the first body
block after the handle aligns with the vertical center of the phone
(still flush with the bottom). Tablet+ dialogs stay centered either
way. Camera / QR paper-roll sheets stay bottom-docked.

Phone sheets keep their painted surface flush with the viewport's bottom
safe-area inset while keeping body content above the home indicator. The
whole phone sheet surface (handle, title, edges) can be dragged down to
dismiss. Scrollable bodies still hand a downward pull to the sheet when
their scroll position reaches the start edge: a pull shorter than the
size-aware sheet dismiss distance settles back, and a deliberate pull
dismisses when `barrierDismissible` is enabled. This works for tile pickers,
confirmation sheets, text-input sheets, and host bodies that use a primary
scrollable. Descendants can toggle the gesture while the route is open
with `SafaehSheet.of(context).enableDrag`.

### Android glass-sheet performance

The default phone-sheet transition uses a slide without a whole-sheet fade on
native Android. Glass stays enabled; the sheet starts below the viewport and
uses the configured entrance/exit curves and motion duration. Other platforms
keep the fade-and-slide transition, and wide dialogs keep their existing motion.

Profiling on a Samsung SM-S721B isolated the expensive combination: an animated
`Opacity` ancestor around a glass `BackdropFilter`. With identical static sheet
content, removing only the fade reduced median raster time from about 30 ms to
10 ms. These profile-mode measurements excluded the first of four openings;
they describe that device, not a guarantee for every Android GPU.

Hosts supplying `slideUp` directly or through `SafaehRouteOptions` still own that
transition. Prefer the default, or avoid wrapping the entire frosted sheet in
`Opacity`/`FadeTransition` on native Android. Keep the starting translation large
enough to put the whole sheet offscreen so removing the fade does not make a
short sheet appear abruptly. The default translates the viewport-aligned panel
by its full height.

## Confirm result

`showSafaehConfirm` returns `true` if confirmed and `null` if the route
is dismissed (tablet close, barrier tap, drag, or system back). Treat
only `ok == true` as confirmed. There is no Cancel footer button.

Pass `dismissReturnsFalse: true` so a barrier tap, tablet close, or
system back also yields `false` (hosts that only check `ok == true` can
ignore this).

## Route bag

Titled `show*` functions and `showSafaehDialog` accept

```dart
SafaehRouteOptions? route
```

Use one object for shared rail, size, motion, barrier, and navigator
settings. Named arguments still work; they fill in around the bag.
`barrierDismissible`, `useRootNavigator`, and `phonePlacement` take the
bag value when it is non-null. Use `routeSettings` to give adaptive sheets and
dialogs a name or arguments for navigation observers and browser history.

The bag also carries the appearance for package-owned floating shells:

```dart
await showSafaehPicker<int>(
  context: context,
  route: const SafaehRouteOptions(
    floatingAppearance: SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.glass,
      transparency: 44,
    ),
  ),
  options: options,
);
```

The resolution order is direct widget/call value, route value, theme value,
then the existing surface default. Set a `SafaehFloatingAppearance` on
`SafaehThemeData` to cover all package-owned floating chrome. The style
presets are `solid`, `translucent`, `glass`, and `vista`; custom fields replace
only their matching preset values. Transparency changes the fill/tint alpha,
while borders and shadows keep their own contrast. Blur is clipped to the
surface shape. Scrims, camera previews, QR message bodies, caller-owned child
content, wide page-index rails, and host FABs are not treated as floating
surfaces.

Adaptive sheet and dialog helpers that expose `useRootNavigator` default to
the root navigator. Set it to `false` to open on a nested navigator. Built-in
dismissal closes the route that owns the sheet or dialog. Use `safaehPop` from
inside the route for host actions. Anchored popouts and the debug menu read
`SafaehNavigatorScope` at the call site. The translation editor reads it from
the navigator supplied to the editor. These helpers default to the root
navigator when there is no scope.

Wrap each independent feedback surface in `SafaehFeedbackHost`. Its feedback
queue and timers belong to that host. Call `dismissSafaehFeedbacks` from within
the host whose messages you want to clear.

## Sidenav

Choose navigation chrome based on the available width and how the destinations
are organized. Use `SafaehThemeData.isWide` and `isDesktop` when the shell
follows the package breakpoints. The host can configure both breakpoints.
Use side navigation on large layouts, including desktops, wide web windows,
tablets, and landscape phones that reach the side-navigation breakpoint.
Use a bottom or floating bar on narrow phone layouts in either orientation.
Use the available width to make the same choice when a web window resizes.
Use `SafaehPageIndex` for links that scroll to sections within one page.

| Need | Use |
|------|-----|
| A few top-level destinations in a narrow phone layout | `SafaehFloatingNavBar` using the same `SafaehSidenavDestination` list and selected index as the rail |
| A temporary, dismissible start-edge panel | `SafaehSidenav(asDrawer: true)` inside `Scaffold.drawer` |
| A rail that reserves page width | `SafaehSidenav` as the first child of a `Row`, with the page in `Expanded` |
| A rail that expands over the page | `SafaehSidenav(overlay: true)` above the page in a `Stack` |
| Contextual destinations that change with the active route | One `SafaehBranchSidenav` with stable item IDs and updated rows |

### Keep navigation fixed during page changes

Mount the permanent rail in the shared app shell, as a sibling of the routed
page area. Keep the same rail mounted at the start edge while the page scrolls
or the route changes. Apply page transitions inside the content area. In the
rail, update the selection and any contextual title or rows in place, keeping
its width, collapse state, and pinned destinations steady. Change the shell
layout when the viewport crosses a breakpoint or the user toggles the rail.
On phones, keep the bottom bar in the shared shell wherever it is visible.

Derive `selectedIndex` or `selectedId` from the active route so Back, deep
links, and resizing all show the correct selection. The same navigation
callback should drive the rail, drawer, and bottom bar. Keep `collapsed` in
the shell and wire `onToggleCompact` with localized expand and collapse
tooltips. Give the rail or drawer bounded height so its destination list can
scroll. Use the profile or footer slot for bottom content that should stay
outside the scrolling list.

For a temporary drawer, let `Scaffold` provide the scrim and dismissal. Close
the drawer from its own `BuildContext` before navigating to the chosen page:

```dart
Scaffold(
  appBar: AppBar(title: Text(pageTitle)),
  drawer: Drawer(
    child: Builder(
      builder: (drawerContext) => SafaehSidenav(
        asDrawer: true,
        title: appTitle,
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          Scaffold.of(drawerContext).closeDrawer();
          selectDestination(index);
        },
      ),
    ),
  ),
  body: page,
);
```

### Branch sidenav

Keep one `SafaehBranchSidenav` mounted within the current shell layout. Build
its title, rows, and selection from the active route and the context it
identifies. Keep the same rail mounted while the context data loads or refreshes.

- At the root, show the app title and the depth-0 root destination. Inside a
  workspace, use the workspace name as `title` and keep the same root row in
  the first position. Pass `animateSelection: false` on that shared row so its
  highlight clears immediately as the branch opens.
- Append enabled workspace sections at depth 1. When a detail page is open,
  insert its depth-2 row directly after its parent section. Use a fallback
  label while loading the detail's title. Leaving the detail removes that row,
  and leaving the workspace removes its section rows and restores the app title.
- Give each logical row a stable `ValueKey` and preserve its identity across
  title, selection, and context updates. The rail animates inserted and removed
  rows and crossfades the title. Pass the active row's key as `selectedId`.
  Routes without their own row can resolve to their parent section. With a
  depth-2 row selected, the rail marks its parent as expanded.
- Keep Settings and Account in `pinnedItems`. Use `leading` and `subtitle` for
  an account avatar and secondary label. A pinned route selects only its row.
  An optional `footer` stays below the pinned rows and hides in compact mode.
- Close any temporary drawer before routing. A tap on the active route can
  close the drawer without pushing a duplicate. Return to the root through
  the shell router. Push contextual and account routes when Back should return
  to the prior page.

### Responsive branch shell

The reference layout uses the bottom bar on narrow top-level routes, a temporary
drawer in the middle width band, and a permanent clipping rail at desktop
widths. A landscape phone that reaches the middle band uses the drawer. Use
`asDrawer: true` inside `Scaffold.drawer` for the tablet presentation, with
the same title, rows, selection, and callbacks as the rail. Restore focus to
the menu button after dismissal and let an active modal own focus. Preserve
the current content and its scroll position across shell width changes.

The reference breakpoints are 600 logical pixels for the drawer and 840 for
the permanent rail. At smaller desktop widths, start with the icon-only rail
and allow a temporary expansion. At the expanded workspace breakpoint, use
the user's saved collapse preference. A reference threshold is 1440 logical
pixels multiplied by the text scale clamped to 1–1.5. Keep the temporary
expansion independent of the saved preference. Use the same compact and
expanded widths for the rendered rail and any layout metrics that need its
reserved width. The drawer and phone bar reserve no horizontal space.

### Overlay sidenav

Use `SafaehSidenav(overlay: true)` when the rail should expand over the host
without pushing or resizing the host content. Mount it above the content in a
`Stack`; the package aligns and animates the rail at the start edge:

```dart
Stack(
  fit: StackFit.expand,
  children: [
    const PageBody(),
    SafaehSidenav(
      overlay: true,
      collapsed: collapsed,
      onToggleCompact: () => setState(() => collapsed = !collapsed),
      floatingAppearance: const SafaehFloatingAppearance(
        style: SafaehFloatingSurfaceStyle.vista,
      ),
      title: 'Safaeh',
      selectedIndex: index,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
    ),
  ],
);
```

The direct `floatingAppearance` wins over
`SafaehThemeData.floatingAppearance`. The overlay does not add a scrim; add
one in the host when expanded behavior needs modal focus or outside-tap
dismissal. `asDrawer` and `overlay` are mutually exclusive.

Only reserve page width for a rail that participates in the layout. When a
`Row` already gives the page its remaining width, keep `reservedStartWidth`
at zero. Floating sheets and dialogs stay centered in the full viewport.

### Verify the shell

In Widgetbook, open **Navigation → Sidenav** for Rail, Drawer, and Overlay,
or **Navigation → Branch sidenav** for contextual rows. Change destinations
and resize across the shell's breakpoints. Rotate a phone and resize a web
window to check that navigation follows the available width. Check that Back
and deep links update the highlighted destination, that the drawer closes on
selection, and that an overlay expands without moving the page. In RTL, check that the rail
and drawer open from the start edge. With large text or a short viewport,
check that the destination list scrolls and pinned rows remain reachable.
At a fixed viewport width, navigate and press Back. Verify that the permanent
rail stays mounted in the same position throughout both page transitions.
For the branch rail, enter a workspace, open a detail, and go Back twice.
Check that the parent stays in place, only the current route is selected, the
title follows the context, and the pinned rows keep their vertical positions.

## App bars

Use `SafaehMorphingAppBar` for top-level destinations that share a pager and
`SafaehContentAlignedAppBar` for detail or standalone pages that align to a
content band. Keep one visible bar for the current page. The host supplies its
own theme, localized titles, actions, and navigation callbacks.

### Pinned morphing app bar

Use `SafaehMorphingAppBar` when a shell keeps one app bar pinned while a
`PageView` moves between destinations. Build the bar in the shared shell and
let the page transition happen underneath it. Listen to the `PageController`
in the bar and read `page` only when exactly one scroll position is attached.
Use the selected destination while the controller attaches or the shell changes
layout. Keep `titles` in the same order as the pages and reserve equal leading
and trailing widths when the title needs a stable center.

For a fixed-height toolbar, attach the following widget to `Scaffold.appBar`.

```dart
PreferredSize(
  preferredSize: const Size.fromHeight(kToolbarHeight),
  child: ListenableBuilder(
    listenable: pageController,
    builder: (context, _) {
      final fallback = selectedIndex.toDouble();
      final page = pageController.positions.length == 1
          ? (pageController.page ?? fallback)
          : fallback;
      return SafaehMorphingAppBar(
        page: page,
        leading: const SizedBox(width: kToolbarHeight),
        titles: [Text(l10n.home), Text(l10n.settings)],
        actionsBuilder: (context, page) => SafaehMorphingAppBarAction(
          page: page,
          targetPage: 1,
          child: IconButton(
            tooltip: l10n.search,
            onPressed: openSearch,
            icon: const Icon(Icons.search),
          ),
        ),
      );
    },
  ),
);
```

`SafaehMorphingAppBarAction` fades actions by page position. Below the
interaction threshold, the action leaves pointer input, keyboard focus, and
the semantics tree. Stack page-specific actions in the stable trailing slot.

Use `SafaehMorphingAppBarBottom` when a bottom row should shrink with the page
position. Let the owning scaffold rebuild with the changing preferred height,
as in the Widgetbook demo. A fixed-height `PreferredSize` wrapper cannot report
the shrinking bottom row.

### Content-aligned app bar

Give the bar and body the same content-band metrics. Use
`SafaehContentAlignedAppBar.forContentArea` with the scaffold's available
width, or pass the same `leftOffset` and `bandWidth` as the body when the host
already computes them. The bar measures its leading and trailing controls,
then fits the title between them. Long titles ellipsize by default. Prefer
short actions or an overflow menu when space is tight.

Use Back on a phone detail route, the menu button when the shell provides a
temporary drawer, and an empty leading slot when the permanent rail already
covers navigation. Keep Back available for standalone flows that need it.

### Verify the app bar

In Widgetbook, open **Navigation → App bar → Morphing**. Swipe between pages,
use Tab while an action fades, and resize across a shell breakpoint. Check
that the bar stays fixed, the title and actions follow the active page, and
faded actions leave keyboard traversal. For a content-aligned bar, verify
that a long title clears wide actions in LTR and RTL and at large text sizes.

## `titleBuilder` / `labelBuilder`

Every titled sheet accepts `SafaehTitleBuilder`:

```dart
typedef SafaehTitleBuilder =
    Widget Function(BuildContext context, TextStyle? style);
```

Sidenav, floating nav, and page index use `SafaehLabelBuilder`:

```dart
typedef SafaehLabelBuilder = Widget Function(String data, TextStyle? style);
```

`safaehTitleFromLabel(data, labelBuilder)` lets a host reuse its label wrapper
for sheet titles. Pass already-localized text. Phone pickers render the title
in the body. The wide route shows it in the header only. When you wrap the
route yourself, pass the same builder to `showSafaeh*` and to the picker,
confirm, or text-input body.

`labelBuilder` also wraps sidenav profile **subtitles**. Use that to
isolate emails and similar tokens in LTR (`Directionality.ltr`) so an
RTL profile row does not reverse `ada@example.com`.

## Material localizations

Safaeh has no bundled copy. A few chrome strings come from
`MaterialLocalizations` of the current locale:

| Chrome | Fallback |
|--------|----------|
| Sheet handle / barrier | `modalBarrierDismissLabel` (override with `dismissLabel`) |
| Tablet sheet close | `closeButtonTooltip` (override with `closeTooltip`) |
| Camera handle | expand / collapse / dismiss labels, else Material dismiss |
| QR top-bar close | `closeButtonTooltip` |
| QR message close | `closeButtonTooltip` (override with `closeTooltip`) |
| Confirm / text-input dismiss | barrier, drag, tablet close — no Cancel footer |

Wire `MaterialApp.localizationsDelegates` (and `supportedLocales`) for
every locale the host ships. Missing delegates leave those controls in
English.

Icon-only chrome the host must label:

- Sidenav compact toggle: `expandTooltip` / `collapseTooltip`
- QR expand: `expandTooltip` / `collapseTooltip`
- Camera paper-roll handle: `handleExpandLabel` / `handleCollapseLabel` /
  `handleDismissLabel`
- Phone sheet handle / tablet X: `dismissLabel` / `closeTooltip` on
  `showSafaeh` or `SafaehRouteOptions`

Selected sidenav, floating-nav, page-index, and option tiles announce
`Semantics.selected`. Disabled option tiles / cards announce
`enabled: false`.

## RTL icons

`safaehChevronEnd`, `safaehChevronStart`, and `safaehArrowBack` always
return the LTR glyph (`chevron_right`, `chevron_left`, `arrow_back`).
Those `IconData`s set `matchTextDirection: true`, so Material mirrors
them once in RTL. Do **not** swap to the opposite icon in RTL or the
arrow flips twice.

## Tile search

Default tile-picker filter is ASCII `toLowerCase()` on label and
subtitle. Pass `searchMatches` on `SafaehTilePickerBody` /
`showSafaehTilePicker` / `showSafaehMultiTilePicker` for locale-aware
or token-aware matching. The callback receives the raw query string.

## Accent hooks on tiles

`SafaehOptionTile` defaults to `ColorScheme` fills. Hosts that want a brand
accent pass:

- `selectedFill`
- `selectedBorder`

An app-level tile wrapper can pass both colors and render directional text
with `SafaehUserText`.

## Band metrics vs host rail math

`safaehBandMetrics` centers a capped column inside the **incoming** width
(optional physical-left `reservedStartWidth`).

`leftOffset` is always from the **physical left** of that incoming box,
including in RTL. `SafaehEndAsideLayout` takes `isRtl` separately and
places the aside on the end. Do **not** pass a start inset as
`leftOffset` or the band shifts the wrong way in Arabic.

`reservedStartWidth` is the same physical-left reserve (a rail still
included in the incoming width). If the rail is a start-edge sibling
and constraints already exclude it, leave this at 0.

`SafaehContentBand` uses that helper. Feed the same
`(leftOffset, bandWidth, endFree)` into:

- `SafaehEndAsideLayout`
- `SafaehContentAlignedAppBar`
- `SafaehContentAlignedFabLocation` (or `.resolve` when `endFree` is tight)

Rail-aware hosts should use `safaehRailAwareBandMetrics`,
`SafaehContentBand(railAware: true)`,
`SafaehContentAlignedAppBar.forContentArea`, and
`SafaehContentAlignedFabLocation.of`. Those center the band in the **full
viewport** while a sibling shell rail eats width (RTL-aware), using
`desktopBreakpoint` / `contentMaxWidthDesktop`. Plain
`safaehBandMetrics` stays the simpler tablet band.

## Keys the host owns

Pass stable keys into `SafaehSidenav` (`railKey`, `expandKey`, `collapseKey`,
destination `tileKey`) when host tests rely on them. Package defaults use
the `safaeh_nav_*` prefix.

## What stays in the host

| Concern | Host |
|---------|------|
| Copy | `easy_localization`, `SafaehUserText`, every label argument |
| Routing | `go_router`; floating sheets ignore reserved rail width |
| Camera | `mobile_scanner`, permissions, `SystemChrome` |
| State | Riverpod / whatever the app already uses |
| Sheet content | Scrolling lists, forms, and action callbacks supplied to the route |

## Still host-owned

- Avatar initials fold only Basic Latin (`toUpperCase` on `codeUnit < 0x80`).
  CJK / Arabic letters stay as written. Pass `SafaehSidenavAvatar.initials`
  or a custom `leading` for Turkish İ / ı.
- The catalog example asserts in debug if a key is missing, then falls
  back to English. The package itself has no copy and will not.
- Fonts stay with the host / system. Safaeh does not register a UI face.

## Thin wrappers

Prefer a host function that maps app types onto package types, then calls
`showSafaeh` or mounts `SafaehTilePickerBody` as the child of the host route.
Do not fork panel layout back into the app.

Action menus, info panels, and timed confirms live on `showSafaehActionSheet`,
`showSafaehInfo`, and `showSafaehTimedConfirm`. Host `tileBuilder` rows are
visual only — tap/pop stay on the sheet. Multi-select + search live on
`showSafaehMultiTilePicker` / `SafaehTilePickerBody` (`searchHint`,
`searchEmptyLabel`, `searchMatches`, `confirmLabel`, optional `cancelLabel`).
Empty / busy / error chrome for light sheets is `SafaehStatusBody` (optional
determinate `progress`). Camera permission copy stays on
`SafaehQrMessageBody`. Camera sheets take `railWidthOf`, `motion`,
`enterCurve` / `exitCurve`, and `barrierDismissible`; they stay a paper-roll,
not a morphing `showSafaeh` dialog.
