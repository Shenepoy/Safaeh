# Shared UI chrome

Safaeh now ships the list, status, and theme chrome that used to live in
Hisab. The package still owns no copy, routing, or state. Hosts pass
already-localized strings and wrap async types themselves.

## When to pick which widget

| Need | Use |
|------|-----|
| Dedicated empty page / list body (large icon, title first) | `SafaehEmptyState` |
| Compact sheet / band empty or busy chrome | `SafaehStatusBody` |
| Inline form / sheet message with a tone | `SafaehInlineBanner` |
| Icon + label pill on a tile | `SafaehMetaChip` |
| Letter or icon plate on a list row | `SafaehGlyphAvatar` |
| Rail profile plate (primary fill, two-letter initials) | `SafaehSidenavAvatar` |
| Label + value summary tile | `SafaehKpiCard` |
| Tappable outlined list row | `SafaehBorderedListChrome` |
| Floating panel / dialog surface | `SafaehContentPanel` |
| Accent bar + section title | `SafaehSectionHeader` |
| Forced-LTR money / codes | `SafaehLtrText` |
| User-generated copy that should keep its own direction | `SafaehUserText` |
| Loading / error / empty / data switcher | `SafaehAsyncBody` |
| Centered spinner | `SafaehLoadingBody` |
| Scrollable error column with retry / home / extras | `SafaehErrorBody` |

## Accent style

`SafaehAccentStyle` is a `ThemeExtension`. Read it with
`context.safaehSubtleAccents`. When the flag is true,
`SafaehAccentSurfaces.panel` / `sectionBar` / `emphasizedFill` flatten to
the same bordered or outline look as `flatPanel`.

```dart
theme = withSafaehAccentStyle(theme, subtleAccents: true);
```

Radius on those decorations resolves from `SafaehTheme.of(context).radius`
when a context is passed (default 16).

## Material chrome factory

`applySafaehMaterialChrome` applies card, input, chip, snackbar, app-bar,
and divider chrome. The host still owns:

- fonts (`GoogleFonts`, Cairo, system faces)
- seed / FlexColorScheme colors
- host `ThemeExtension`s such as Hisab's `AppThemeExtension`

Call the factory, then `copyWith(extensions:)` for anything app-specific.
`scaleSafaehTextTheme` is the shared text-scale helper.

`SafaehThemeData.listRadius` (default 12) is the fallback corner for
`SafaehBorderedListChrome` when `ThemeData.cardTheme` has no shape.
`desktopBreakpoint` (840) and `contentMaxWidthDesktop` (720) drive
`safaehRailAwareBandMetrics` and `SafaehContentBand(railAware: true)`.

## Async and error adapters

Safaeh has no riverpod. Unwrap the host type into flags:

```dart
value.when(
  data: (data) => SafaehAsyncBody(
    isLoading: false,
    isEmpty: data == null,
    empty: (_) => const SafaehEmptyState(...),
    data: (_) => Content(data),
  ),
  loading: () => const SafaehAsyncBody(
    isLoading: true,
    data: _unused,
  ),
  error: (error, stack) => SafaehErrorBody(
    title: 'Something failed',
    message: error.toString(),
    retryLabel: 'Retry',
    onRetry: onRetry,
  ),
);
```

A `Future` host can set `isLoading: snapshot.connectionState != done`.
Share / report buttons belong in `SafaehErrorBody.extraActions`.

## User text and bidi

`SafaehUserText` isolates UGC with FSI/PDI and picks a base direction from
the first strong directional character (no `intl` dependency).
`safaehIsolateBidi`, `safaehUnwrapBidiIsolates`,
`safaehResolveUserTextDirection`, `safaehResolveUiStartTextAlign`, and
`safaehElideGraphemes` are the display helpers. Database clamp helpers
stay in the host.

## Status colors

`ColorScheme` gains `success` / `onSuccess` / `warning` / `onWarning` /
`danger` / `onDanger` through `SafaehSemanticStatus`.
