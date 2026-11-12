# Safaeh Widgetbook

An unpublished development catalog with 71 stories. Use the existing `example/`
gallery for complete demonstrations and Widgetbook for inspecting components,
states, and layout edges. See [COVERAGE.md](COVERAGE.md) for the inventory.

## Run and verify

Use the repository's pinned Flutter SDK (3.50.0, Dart 3.14.0):

```bash
cd widgetbook
../.fvm/flutter_sdk/bin/flutter pub get --enforce-lockfile
../.fvm/flutter_sdk/bin/flutter run -d chrome
```

If Flutter is already on your PATH, use `flutter` and `dart` directly.

```bash
dart format --output=none --set-exit-if-changed lib test
dart analyze --fatal-infos
flutter test
flutter build web --release --base-href /Safaeh/widgetbook/
```

Serve the last build under `/Safaeh/widgetbook/`, matching its base href. For a
standalone server rooted at `build/web`, build with `--base-href /` instead.
CI uploads `widgetbook-web` for review and includes it in the existing Pages
artifact on `main`. It uses a single deployment for both applications. No live
catalog URL is advertised until the first deployment is verified.

## Preview controls

- Viewport: phone, tablet, desktop, safe areas, and widths around 600/840 px.
- Theme: the same light/dark `material_ui` themes as the example.
- Locale: English, Arabic, Japanese, Chinese, Spanish. Fixture translation
  coverage varies; the auth fixture provides Arabic and English copy.
- Text scale: 1.0–2.0.
- Environment: target platform, floating-surface style, reduced motion,
  simulated keyboard inset, and simulated cutout.
- Knobs: component-specific text, enabled/selected states, enums, and counts.

Surface style applies to floating surfaces (such as sheets and navigation),
not every static component. Inspect keyboard and cutout effects in the Layout
stories. Reduced motion affects widgets that honor the platform accessibility
setting; it does not stop every loading indicator.

The preview's reset button clears local state, open routes, and feedback while
retaining the selected knobs and environment. Switching stories also clears
state. Ordinary knob/addon changes preserve the running story and Navigator.
The adaptive sheet demonstrates live title/body updates while open. Other
route-launch options (for example confirmation duration or picker contents)
take effect the next time the route opens.

Keyboard and cutout controls simulate layout only. Camera and QR content are
mocked, auth callbacks are local, and translation editing stays in memory.
Native input, hardware cutouts, back gestures, and camera permissions still
need device testing. Widgetbook does not replace the library's tests or add
automatic visual regression comparisons.

## Add a story

1. Add a builder in `lib/use_cases/`, using Safaeh's public package imports.
   Reuse independent example fixtures, translations, or `catalog_theme.dart`
   when useful. Never make the example depend back on this application.
2. Register it with `_component` in `lib/catalog.dart`. Keep names stable:
   Widgetbook derives bookmark paths from them. This helper also preserves
   story state when Widgetbook 3.x recreates its URL-keyed builder.
3. Use `StoryPage` for compact widgets or a full-page scaffold for layouts.
   Keep settings in `PreviewHost`; do not duplicate application wrappers.
4. Open sheets/dialogs with `useRootNavigator: false`. Anchored popouts and
   feedback honor the inherited `SafaehNavigatorScope`. Compute anchor rects
   in the selected navigator overlay's coordinates, as `controls.dart` does.
5. Use `context.catalogString` from `text_knob.dart` for text knobs. It keeps
   the visible editor synchronized with URL changes and localized defaults;
   Widgetbook 3.x's built-in string field only initializes its editor once.
   Use deterministic sample data and local callbacks. Keep mutable interaction
   state in a StatefulWidget. Document options that apply only when reopening.
6. Update the coverage table. Every registered story automatically gets a
   bounded render check; add behavioral tests for new integration behavior.

## Dependency and publication boundary

`widgetbook` is a regular dependency of **this application**, because its
`lib/` imports and runs Widgetbook. Test tools are dev dependencies. Safaeh's
root pubspec and public exports do not depend on this application, Widgetbook,
or its example package. Consumers therefore acquire no Widgetbook dependency
or catalog runtime code.

`publish_to: none` prevents publishing this app. The nested `.pubignore` with
`*` additionally excludes the whole directory from Safaeh's archive. Keep it;
`publish_to: none` alone is insufficient. Before release, inspect the root
`flutter pub publish --dry-run` output. Do not replace root gitignore publishing
rules with a partial root pubignore.

There is no Cloud account, subscription, code generation, or paid integration.
Costs are development dependency downloads, catalog maintenance, and the extra
CI test/build job and hosting usage under the repository's existing plan.
