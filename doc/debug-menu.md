# Debug menu and translation editor

Safaeh ships the chrome. The host decides visibility, supplies copy, and
registers the sections that talk to its own providers.

## Debug shell

```dart
if (showDebugMenu) {
  SafaehDebugMenuFab(
    visible: true,
    tooltip: 'Debug menu',
    onOpen: () => showSafaehDebugMenu(
      context,
      title: 'Debug',
      identity: const SafaehDebugIdentityCard(
        package: 'com.example.app',
        version: '1.2.3',
        chips: ['debug'],
      ),
      statusMessage: 'Staging backend',
      sections: [
        SafaehDebugSection(
          title: 'Payments',
          icon: Icons.payments_outlined,
          children: [
            SafaehDebugActionTile(
              icon: Icons.refresh,
              label: 'Reset quota',
              onTap: resetQuota,
            ),
          ],
        ),
      ],
    ),
    onDragDelta: persistFabDelta,
  );
}
```

- Gate the FAB with `kDebugMode`, a `.debug` package name, or any host flag.
  Safaeh does not check `kDebugMode`.
- FAB position persistence (`initialAlignment` / SharedPreferences) stays
  in the host. Pass `onDragDelta` and store the offset yourself.
- `showSafaehDebugMenu` opens through `showSafaeh`. Hosts that already wrap
  a sheet can mount `SafaehDebugMenuBody` directly.
- Chrome tiles: `SafaehDebugIdentityCard`, `SafaehDebugStatusChip`,
  `SafaehDebugGroupLabel`, `SafaehDebugQuickActionGrid`,
  `SafaehDebugSectionCard`, `SafaehDebugSnapshotCard`,
  `SafaehDebugStatusBanner`, `SafaehDebugActionTile`.

`SafaehDebugL10nSection` builds the four localization actions (enter/exit
edit mode, export, clear, reload) from a `SafaehL10nEditorLabels` bag.

## Translation editor

Three seams:

| Type | Role |
|------|------|
| `SafaehL10nBackend` | Locales, current locale, bundled/override maps, `setOverride`, `clearOverrides`, `applyLive`, `revision` |
| `SafaehL10nPersistence` | `read` / `write` a JSON blob |
| `SafaehL10nOverrideStore` | Flatten, merge, reverse-lookup (`findKeysForText`), export |

`SafaehL10nEditOverlay` long-presses `RenderParagraph`s
(`safaehCollectPlainTextsAt`), shows a banner while edit mode is on, and
opens candidate / search / editor / export sheets via `showSafaeh`.

### easy_localization reference

```dart
class HostL10nBackend implements SafaehL10nBackend {
  HostL10nBackend(this.localeContext, this.store);
  final BuildContext localeContext;
  final SafaehL10nOverrideStore store;

  @override
  List<String> get locales => const ['en', 'ar'];

  @override
  String get currentLocale =>
      EasyLocalization.of(localeContext)?.locale.languageCode ?? 'en';

  @override
  Map<String, String> bundled(String locale) =>
      store.flattenStrings(store.bundledSnapshot(locale));

  @override
  Map<String, String> overrides(String locale) => store.overridesFor(locale);

  @override
  Future<void> setOverride(String locale, String key, String value) async {
    store.set(locale, key, value);
    await store.save();
  }

  @override
  Future<void> clearOverrides() => store.clearAll();

  @override
  Future<void> applyLive() async {
    final locale = EasyLocalization.of(localeContext)!.locale;
    Localization.load(
      locale,
      translations: Translations(store.merged(locale.languageCode)),
    );
  }

  @override
  Listenable get revision => store.revision;
}

class PrefsPersistence implements SafaehL10nPersistence {
  static const key = 'debug_l10n_overrides_v1';

  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> write(String json) async =>
      (await SharedPreferences.getInstance()).setString(key, json);
}
```

The host asset loader still merges overrides onto bundled JSON. Share /
copy of the exported blob is `SafaehL10nEditOverlay.onShare`.
Tests and the example catalog can use `SafaehMemoryL10nPersistence`.
