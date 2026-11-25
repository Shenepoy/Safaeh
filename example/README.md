# Safaeh example

The [example gallery](https://shenepoy.github.io/Safaeh/) shows Safaeh
integration patterns in English, Arabic, Japanese, Chinese, and Spanish.
Search by component or filter by section. Select a card title to open its
standalone demo or use the phone icon to run it inside a simulated phone.
Routes and feedback opened inside that preview stay within its viewport.
The standalone demos have shareable URLs, such as the
[morphing app bar](https://shenepoy.github.io/Safaeh/#/demo/morphing_app_bar).
A link to a modal demo opens a page with an **Open demo** button.

The [Widgetbook catalog](https://shenepoy.github.io/Safaeh/widgetbook/) includes
additional components, variants, and configurable preview settings.

`web/` is in-tree for GitHub Pages. A green [CI](../.github/workflows/ci.yml)
run on `main` builds `example/` (`flutter build web --release --base-href /Safaeh/`)
and deploys that site. **Run workflow** on CI republishes the same path.
Other platforms are not generated, so `flutter run` on a device needs
`flutter create .` first.

## Analyze

```bash
cd example
flutter pub get
dart analyze --fatal-infos
```

## Tests and widget images

```bash
cd example
flutter test
```

`test/widget_images_test.dart` captures picker, confirm, option tiles, and
sidenav with [`widgets_to_image`](https://pub.dev/packages/widgets_to_image)
into [`../screenshots/`](../screenshots/). CI runs that test and uploads the
PNGs as the `widget-images` artifact.

## Web

```bash
cd example
flutter pub get
flutter build web --release --base-href /Safaeh/
```

## Run on a device (optional)

```bash
cd example
flutter create . --project-name safaeh_example --platforms=android,ios
flutter pub get
flutter run
```

## Browse order

1. Sheets and dialogs
2. Controls
3. Navigation
4. Layout
5. Feedback and status
6. Display
7. Onboarding
8. Camera and QR
9. Developer tools

Sheets open with the adaptive sheet and dialog, followed by confirmation,
text input, pickers, and sheet construction examples. Controls opens with
the three dropdown variants in one demo. The gallery preserves the same
order on narrow and wide layouts.
