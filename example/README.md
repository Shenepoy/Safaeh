# Safaeh example

Catalog of `package:safaeh` chrome in five Fukaha locales (en, ar, ja, zh,
es) — `example/lib/app.dart`, `catalog.dart`, `gallery.dart`, `pages.dart`.
The gallery sits in `SafaehContentBand`. Wide bands lay section cards in two
or three columns on the same scrolling page. Section titles open the
standalone demo (sheet, page, or camera host). Locale + light/dark toggles.
No `mobile_scanner`, Riverpod, or `easy_localization`. Profile name/email
go through catalog keys; emails stay LTR in Arabic via `catalogIsolateLabel`.

Live: [zyzto.github.io/Safaeh](https://zyzto.github.io/Safaeh/)

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

## What it shows

1. **Adaptive sheet** — phone bottom sheet ↔ tablet dialog
2. **Card picker** — `SafaehOptionPickerBody` / `showSafaehPicker`
3. **Tile picker** — `SafaehTilePickerBody` + header / disabled row
4. **Multi picker** — search + `showSafaehMultiTilePicker`
5. **Status body** — busy and empty `SafaehStatusBody`
6. **Confirm / text input** — `SafaehConfirmSheet` / `SafaehTextInputSheet`
7. **Sheet shell** — shared title, body, and action row
8. **Sheet morph** — nested 320 and 420 previews
9. **Option tiles** — selected / disabled / destructive
10. **Dialog** — `showSafaehDialog` with theme radius and width
11. **Sidenav** — rail and `asDrawer: true` temporary drawer
12. **Floating nav** — `SafaehFloatingNavBar`
13. **Page index** — side rail and overlay + scroll helper
14. **Content band / end aside / aligned chrome** — `safaehBandMetrics`
15. **Morphing app bar** — page-aware title, action, and bottom chrome
16. **Camera host / QR overlay / QR message** — QR chrome sits in the
    camera bottom panel (`SafaehCameraSheetHost`)
17. **Feedback** — shared host, typed surfaces, action messages, and custom
    feedback builders
18. **Language + theme toggles**
