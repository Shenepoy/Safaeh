# Sheet templates and host customization

`showSafaeh` owns the adaptive route, drag dismissal, safe area, keyboard inset,
and floating appearance. `SafaehSheetTemplate` owns the content layout inside
that route: a scrolling header/body and an optional pinned feedback/footer.
Existing sheet helpers remain supported; adopting the template is additive.

The host owns business rules, validation, localized copy, data/cache policy,
action execution, navigation, and diagnostics. Safaeh has no Hisab, Riverpod,
localization, billing, or logging dependency.

## Choose slots, not another copied shell

```dart
showSafaeh<void>(
  context: context,
  contentPadding: EdgeInsets.zero, // Template owns its content padding.
  child: SafaehSheetTemplate(
    header: SafaehSheetHeading(
      title: labels.editName,
      leading: const Icon(Icons.edit_outlined),
    ),
    body: SafaehSheetSurface(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: hostForm,
      ),
    ),
    feedback: hostReservedFeedback,
    footer: hostSaveButton,
  ),
);
```

All four slots accept arbitrary widgets. Use a branded header, metrics,
from/to details, validation, or an entirely custom footer without changing the
template. Set `header: null` if the route already paints the title. Leave
`footer` and `feedback` null for a list that applies its selection immediately.
For a `ListView`, use `scrollBody: false` so only that list owns scrolling.
In this mode the header stays above the list. The route supplies bounded height;
an inline, unbounded list must use its usual `shrinkWrap` arrangement.

Do not add another bottom `SafeArea` or keyboard inset inside the template.

## App defaults and individual overrides

Set theme defaults above the app navigator so open sheets also receive updates:

```dart
SafaehTheme(
  data: const SafaehThemeData(
    sheetTemplate: SafaehSheetTemplateStyle(
      padding: EdgeInsets.all(24),
      headerGap: 20,
      footerGap: 8,
      surfaceRadius: 16,
      surfaceColor: Colors.white,
      // Null darkSurfaceColor follows the current dark ColorScheme.
    ),
  ),
  child: MaterialApp(/* ... */),
);
```

`SafaehSheetTemplate.padding` and `SafaehSheetSurface` color/radius/border
arguments override inherited defaults. For several related sheets, use a
scoped `SafaehTheme` with `data.copyWith(sheetTemplate: ...)`. Local themes below
the navigator are captured at opening, like a standard Material dialog;
app-wide themes above the navigator remain live. Dark surfaces have a separate
`darkSurfaceColor` override. Reading surfaces are always opaque; translucent
route skins remain controlled by `SafaehFloatingAppearance`.

Hisab uses thin adapters for its white reading surfaces, localized headings,
error logging, and action policies. The adapters can add app-specific options
without forking the Safaeh implementation.

## Load inside an immediately opened sheet

```dart
SafaehSheetDataLoader<EditorData>(
  key: ValueKey(recordId),
  initialData: cachedData,
  load: (retry) => repository.readEditorData(recordId, refresh: retry),
  labels: SafaehSheetLoadLabels(
    loading: labels.loading,
    error: labels.loadFailed,
    retry: labels.retry,
  ),
  header: SafaehSheetHeading(title: labels.edit),
  onError: (error, stack) => hostLogger.record(error, stack),
  builder: (context, data) => HostEditor(data: data),
);
```

The loader bypasses the read when `initialData` is supplied. Otherwise it reads
once, times out after 20 seconds by default, and exposes Retry. It retains the
successful result across parent rebuilds so an editor's draft is not replaced
by a background refresh. Change its key when opening a different record.
Errors never display raw exception strings by default. Localized loading/error
copy and the retry control reserve stable space, including large text and RTL.
`loadingBuilder` and `errorBuilder` can replace the complete status presentation.

The host should preload reusable read-only data on the relevant page, not all
application data at startup. Fetch destructive effects fresh before enabling
confirmation. Timeout and dismissal ignore late results; they cannot cancel
the underlying future. Keep a read self-contained: do not let an obsolete
request mutate shared selection state. **Never use this loader for mutations.**

## Action presentation and execution stay separate

`SafaehSheetActionButton` accepts `ready`, `cooldown`, `working`, and `failed`
states. The host supplies a normalized `activity` animation: progress for the
center bloom during cooldown, repeating progress for the directional layered
sweep during work. It also supplies `cooldownProgress` for reduced motion.
The button blocks primary and auxiliary input while cooling or working.

Pass all possible `stateLabels` to reserve the tallest localized label. Use
`reserveActionSpace: true` when leading/trailing widgets will appear only after
an error. Those slots are generic: the host may supply help, copy, or log-sharing
controls. Color, foreground, warning color, shape, and border width are
customizable. RTL direction and reduced-motion presentation are automatic.

The button does not execute futures, pop routes, decide whether a retry needs
another confirmation, or decide whether the whole sheet may close. Hisab's
action runner retains those policies, its three-second safety delay, form
validation, error reports, and long-operation escape behavior.

## Preview and verification

Widgetbook → Sheets includes **Sheet template**, **Sheet loading**, and
**Sheet action**. Try footer/spacing overrides, cached and failing reads,
action states, auxiliary slots, Arabic, large text, dark mode, and reduced motion.
`test/sheet_template_test.dart` exercises these public interfaces; Hisab's
existing form/action/loading suites exercise its adapters.

These APIs are available in Safaeh 1.2.5. Consumers can use `safaeh: ^1.2.5`
from pub.dev; local path overrides are only needed when developing the package.
