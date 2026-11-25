# Agent instructions

## Sheets

Read the [sheet integration guide](doc/sheet-templates.md) before adding or
editing a sheet, its examples, or its route behavior. Follow its rules for
title placement, dismissal, spacing, and scrolling on phone and tablet.

## Dropdowns

Use `SafaehAnchoredDropdownChip` for compact single-choice menus attached to
a trigger. Read the [dropdown guide](doc/host-integration.md#dropdowns) before
adding or replacing a dropdown. Use `.scrollable` when the list should stay
anchored in a bounded panel and `SafaehAnchoredToggleDropdownChip` for
independent checkbox choices. Use a picker sheet for search or confirmation.

## Sidenav

Read the [sidenav guide](doc/host-integration.md#sidenav) before adding or editing
an app shell, rail, or drawer. Use `SafaehSidenav` for a flat destination list
and `SafaehBranchSidenav` when destinations expand into contextual sections.
Keep persistent navigation mounted at the screen edge in the shared shell
while pages change. Derive the selected destination from the active route.
Use side navigation on wide layouts, including desktops, wide web windows,
tablets, and landscape phones with enough width. Use bottom or floating
navigation on narrow phone layouts, including narrow landscape windows.

## App bars

Read the [app bar guide](doc/host-integration.md#app-bars) before adding or
changing an app bar. Keep one `SafaehMorphingAppBar` in a paged shell, and use
`SafaehContentAlignedAppBar` for standalone pages with a shared content band.

## Other shared widgets

Read the [widget selection guide](doc/host-integration.md#choose-a-widget) for
onboarding, auth, camera, QR, feedback, tabs, page index, itineraries, and
standalone controls. Use the linked Widgetbook story to check the interaction.
The host supplies its own colors, typography, and localized copy.

## PolyScreen emulator interaction

For emulator/device UI interaction and validation, use `polyscreen-mcp` according
to the inherited `Projects/AGENTS.md` rule:

- Discover the exact device with `mobile_devices_list` and the logical display
  with `mobile_displays_list`; pass that display ID to launch, UI, input, and
  capture operations.
- Prefer semantic PolyScreen UI tools: `mobile_app_launch`,
  `mobile_ui_find`/`mobile_ui_wait`, `mobile_input_tap`, `mobile_input_swipe`,
  `mobile_input_text`, and `mobile_screen_capture`.
- Use raw `adb` for build/install, diagnostics, or unsupported capabilities. If
  ADB performs UI interaction, record the fallback in validation notes.
