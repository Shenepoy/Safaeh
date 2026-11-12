# Widgetbook adoption plan

Status: implemented locally on 2026-11-12; final validation recorded below.
No remote deployment or package release has been performed.

## Decision

Add an unpublished, web-first `widgetbook/` application beside `example/`.
Use it to inspect individual Safaeh widgets, inputs, and named edge cases. Keep
the existing example gallery for complete interactions and public discovery.

Use the free open-source package locally and on the existing static hosting.
Widgetbook Cloud, paid snapshots, and a Mix migration are outside this rollout.
Validation exposed two library issues addressed with regression tests: anchored
popouts/feedback now honor the existing navigator scope, and long auth-divider
labels wrap at large text sizes. No public API or dependency was added.

## Repository and dependency layout

```text
Safaeh/
  lib/                         existing published library
  example/                     existing complete demos
  widgetbook/
    .gitignore                 local build/cache exclusions
    .pubignore                 contains *; excludes this entire subtree
    pubspec.yaml               name: safaeh_widgetbook; publish_to: none
    pubspec.lock               committed application lockfile
    analysis_options.yaml
    lib/
      main.dart
      catalog.dart             explicit story registration
      preview_host.dart        shared environment and local navigation
      use_cases/               grouped by existing catalog categories
    test/                      preview integration tests
    web/                       web bootstrap
    README.md                  run, build, and authoring instructions
```

- Keep Safaeh's root dependencies, exports, and SDK requirements unchanged.
- Put `widgetbook: ^3.25.0`, Flutter, `material_ui`, and the path dependency on
  Safaeh in the catalog application's regular dependencies. Commit the resolved
  lockfile and review upgrades explicitly. Start with stable 3.x, not 4.x beta.
- Reuse the unpublished `safaeh_example` package through a path dependency for
  its theme, translations, and suitable fixtures. Extract the theme factory from
  `example/lib/app.dart` into a focused helper if needed. Example must never
  depend back on Widgetbook. Do not reuse private gallery layout helpers.
- Construct knob-driven stories directly from Safaeh's public interface. Reuse
  existing demo widgets only when their setup is useful and independent.
- Add `flutter_test` and `flutter_lints` as catalog dev dependencies.
- Register stories manually initially. Do not add annotation, generator, or
  build_runner dependencies until registration volume justifies generation.
- Exclude `widgetbook/**` from root analysis and analyze the catalog separately,
  as CI already does for `example/`.

## Publishing rules

`publish_to: none` protects the catalog from being published as its own package;
it does not by itself exclude its files from Safaeh's archive.

Use a nested `widgetbook/.pubignore` containing `*`. This preserves the root
`.gitignore` behavior. Do not introduce a root `.pubignore` containing only
`/widgetbook/`: a root `.pubignore` replaces the root `.gitignore` publishing
rules and could include existing build output unintentionally.

Before merging the completed integration, run Safaeh's actual
`flutter pub publish --dry-run` and inspect the complete file list. Verify:

- no Widgetbook source, lockfile, cache, or build output is included;
- library, shaders, licenses, README, and declared screenshots remain included;
- root dependency constraints and exports remain unchanged;
- a temporary consumer depending only on Safaeh resolves no Widgetbook packages.

The tooling addition does not require publishing a new Safaeh version. If a
future release includes README changes, follow the repository's normal version
and changelog policy. Existing pub.dev versions remain unchanged.

## Preview environment

One `PreviewHost` module owns the environment so stories do not individually
reimplement theme, locale, MediaQuery, overlays, and route handling.

1. Keep Widgetbook's SDK Material interface separate from the preview's
   `material_ui` widgets. Use qualified imports wherever both are needed.
2. Provide a custom `appBuilder` using `material_ui.MaterialApp` and its
   localization delegates. Use generic `ThemeAddon<material_ui.ThemeData>`,
   rather than Widgetbook's SDK `MaterialThemeAddon`.
3. Put the selected theme, locale, directionality, Safaeh tokens, and simulated
   media settings above a persistent preview-local Navigator. Modal routes must
   inherit the same settings as inline content.
4. Launch route-based stories with `useRootNavigator: false`, or the equivalent
   `SafaehRouteOptions`. A bare nested Navigator does not prevent a root-navigator
   lookup from reaching Widgetbook's outer navigator.
5. Keep feedback overlays inside the preview too. Add feedback/debug hosts only
   where required, and clear active routes and feedback when changing stories.
6. Preserve the preview Navigator when changing width, theme, or other settings
   that should update a running demo. Knob updates must reach the currently
   displayed route; do not cache the first story child in an initial route.
7. Expose a reset action for stateful stories. Use fixed dates, sample values,
   mock camera content, and local callbacks; avoid real credentials and services.

Viewport settings must affect both actual constraints and `MediaQuery.size`.
Widgetbook's ViewportAddon also uses SDK Material theme types for its platform
override; explicitly apply the selected platform to the `material_ui` preview
theme. Do not assume that SDK theme changes configure `material_ui`.

Start with these controls:

- light/dark theme and the existing floating-surface appearance choices;
- the existing five catalog locales, with English and Arabic acceptance checks;
- phone/tablet/desktop viewports and precise breakpoint-adjacent widths;
- text scaling from 1.0 to 2.0, including 1.3;
- reduced motion;
- widget-specific boolean, enum, string, and numeric knobs.

Add explicit safe-area, keyboard-inset, and cutout scenarios where relevant.
Treat them as simulations. Native keyboard, cutout, back, and gesture behavior
still require device validation.

## Coverage and rollout

Maintain a small coverage table mapping public widgets to stories or to an
existing behavioral test when a helper has no meaningful visual representation.
Stable story paths make bookmarks durable. Group stories using the current
gallery categories, without copying its layout implementation.

| Phase | Coverage | Completion condition |
| --- | --- | --- |
| 1: foundation | Host, settings, publication exclusions, one tile and one modal | Theme, Arabic, viewport, controls, and modal isolation checks pass |
| 2: useful first catalog | Option tiles, meta chip, content panel, inline banner, empty state, KPI card, async/error states, sheet shell, adaptive sheet, confirm | Named edge cases and live knobs work for each |
| 3: remaining visual interface | Pickers, text input, dropdown/popout, calendar/swatch/cycle controls, feedback, nav, page index, aligned layouts, app bar, camera/QR mock chrome, onboarding/auth designs, debug/translation surfaces | Every relevant public widget is accounted for |
| 4: delivery | CI build, combined static artifact, documentation links | Catalog loads at its subpath, including a bookmarked story on reload |

Prioritize long Arabic and mixed-direction user content, disabled/selected/
destructive combinations, empty/loading/error content, and dense layouts.
Onboarding/auth stories should expose the existing six designs and important
host-owned states without introducing authentication services.

Do not test the full Cartesian product of all knobs. Use representative defaults
plus directed edge cases: widths 599/600/601 and 839/840/841 around the existing
breakpoints, narrow phones, large text, RTL, and reduced motion. Add viewport
sizes suited to each story; tiny chrome does not need every desktop variant.

## Validation

Keep existing library and example tests. Widgetbook is a development surface,
not a replacement for behavioral tests or baseline image comparisons.

Add focused integration coverage for the new preview behavior:

- a knob change updates the rendered widget, including one hosted by a route;
- the expected `material_ui` theme, locale, direction, platform, text scale, and
  motion setting reach both inline content and modal content;
- sheets/dialogs/popouts and feedback stay within the preview;
- local dismissal and changing stories leave no stale overlays;
- resizing an open adaptive sheet crosses its breakpoint without losing the
  preview environment;
- representative stories render without framework exceptions or overflow.

Use bounded pumps for continuously animated stories. No blanket golden suite
or large snapshots matrix in this rollout. The existing screenshot generator
writes images; it does not compare them with approved baselines.

Validate the production web artifact in a browser: knobs, addon changes, opening
and dismissing overlays, narrow/wide layouts, subpath assets, and deep-link
reloads. A successful compilation alone is not browser validation.

For device UI validation, discover the exact device using PolyScreen's
`mobile_devices_list`, discover its logical display with `mobile_displays_list`,
and pass that display ID to semantic launch/UI/input/capture tools. Record any
ADB UI fallback. Use native validation for the hardware-dependent cases rather
than promising that a web device frame reproduces them.

## CI and hosting

- Use the repository's pinned Flutter 3.50.0 / Dart 3.14.0 toolchain.
- Add a separate catalog job: pub get, formatting check, analysis with fatal
  infos, focused tests, and a release web build. Keep core/example validation.
- Start with the normal JavaScript web build. WebAssembly is a separate
  optimization requiring its own compatibility check.
- Build PRs and upload the catalog as a review artifact. Add no external service
  secrets or paid Cloud integration.
- Extend the existing GitHub Pages artifact: keep the example at `/Safaeh/` and
  copy the catalog build into `/Safaeh/widgetbook/`. Derive the repository name
  in CI rather than hard-coding the base href.
- Use one Pages upload/deploy job for the combined directory. Independent Pages
  deployments could replace each other's content.
- Preserve hash-based story navigation for static hosting. Check a copied story
  URL on a fresh load, not just navigation from the catalog home.
- Add README links only once the actual hosted URL has been verified. Existing
  README/deployment URLs and repository metadata use differing owners; verify
  the real Pages deployment instead of assuming an owner.

Local run instructions should use `cd widgetbook`, `flutter pub get`, and
`flutter run -d chrome`, with the repository's FVM SDK where required. Document
the new-story recipe, fixture reuse, local navigator rule, and reset behavior.

## Sanity-check evidence and limits

Checks performed on 2026-11-12 outside the working tree:

- Widgetbook 3.25.0 resolves with Safaeh's current source and `material_ui` 1.11.0
  on Flutter 3.50.0 / Dart 3.14.0 without dependency overrides.
- A Flutter widget test renders a Safaeh option tile with a generic
  `ThemeAddon<material_ui.ThemeData>` and confirms dark theme inheritance.
- Two more tests open an adaptive modal at 390 and 800 logical pixels and
  confirm its local Navigator, viewport width, dark `material_ui` theme, Arabic
  locale, and RTL direction. All three tests pass.
- A minimal catalog compiles successfully with `flutter build web --release
  --base-href /Safaeh/widgetbook/`. This checks the JavaScript release build;
  the accompanying Wasm dry run also passes, but Wasm runtime behavior and
  browser interaction have not been validated.
- A separate publishing probe confirms a nested `.pubignore` containing `*`
  excludes catalog files while root `.gitignore` still excludes build output.
  The intentionally minimal probe reports metadata warnings; this is exclusion
  evidence, not a successful dry run of the real Safaeh release.

Implementation checks on 2026-11-12:

- Registered 71 stories across 48 components; the coverage inventory is in
  `widgetbook/COVERAGE.md` in the repository checkout.
- All 90 catalog tests pass: every story renders, live knobs and open-modal
  updates work, modal environment persists across a 390→840 px resize, reset
  clears routes, and feedback stays local and is cleared on story changes.
- All 267 root tests and 68 example tests pass. Analysis passes for all three
  packages. Existing example tests emit non-fatal hit-test warnings.
- Release JavaScript web build succeeds with `/Safaeh/widgetbook/` as base href.
- The release build was served locally at that subpath and exercised in the
  in-app browser: editable knobs, dark theme, live open-sheet copy, a
  390→840 px resize while open, Arabic/RTL while open, reset dismissal, and
  a fresh bookmarked-story reload. No browser warnings or errors were captured.
- Actual root publishing dry run excludes the entire Widgetbook directory and
  retains the library, shaders, license, README, and screenshots. It exits with
  one warning about the uncommitted working tree; no publish was attempted.
- A temporary consumer depending only on Safaeh resolves 24 packages, with no
  Widgetbook or example package. Root pubspec and lockfile match the task's
  starting contents; exports are unchanged.
- Follow-up settings audit added labelled, fully clickable Environment controls
  and fixed stale
  text-knob editors after URL/default changes. Seven settings tests exercise
  actual control interaction, every addon option, and bookmarked restoration.
- The shared theme was extracted without changing its implementation and is
  re-exported from `example/lib/app.dart` for existing callers.

Native hardware/input validation and the first real Pages deployment remain
outside this local web-first acceptance. CI is configured for the combined
artifact; remote hosting has not yet been verified.

The probe also emits an existing warning about multiple shader `return`
statements on Windows. Keep this rollout web-first; native Windows support
needs separate shader validation.

## Reference material

- [Widgetbook stable package](https://pub.dev/packages/widgetbook)
- [Separate catalog app setup](https://docs.widgetbook.io/quick-start)
- [Custom preview root](https://docs.widgetbook.io/configure/root-widget)
- [Generic theme addon](https://docs.widgetbook.io/addons/theme-addon)
- [Viewport behavior](https://docs.widgetbook.io/addons/viewport-addon)
- [Pub archive and ignore rules](https://dart.dev/tools/pub/publishing#what-files-are-published)
- [Dart dependency rules](https://dart.dev/tools/pub/dependencies#dev-dependencies)
