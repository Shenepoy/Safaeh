# Sheet templates and host customization

`showSafaeh` owns the adaptive route, drag dismissal, safe area, keyboard inset,
and floating appearance. `SafaehSheetTemplate` owns the content layout inside
that route: a scrolling header/body and an optional pinned feedback/footer.
Existing sheet helpers remain supported; adopting the template is additive.

Share these layout and interaction patterns across apps. Each host supplies
its own colors, typography, localized copy, and business logic.

## Choose the sheet entry point

Use `showSafaehConfirm` or `showSafaehTimedConfirm` for confirmation,
`showSafaehTextInput` for simple text entry, `showSafaehInfo` for information,
`showSafaehPicker` or `showSafaehTilePicker` for single selection,
`showSafaehMultiTilePicker` for multiple selection, and `showSafaehActionSheet`
for a menu of actions. For a custom form or flow, use `showSafaeh` with
`SafaehSheetTemplate` when you need its layout slots.

## Place the title and actions

- Pass the sheet title to `showSafaeh` as `title` or `titleBuilder`. It appears
  below the drag handle and above the body on phone, and in the fixed top bar
  on tablet and desktop. Leave `SafaehSheetTemplate.header` unset in this case.
- Use the template's `header` for a custom in-content heading. If it serves as
  the sheet title on every width, omit the route's `title` and `titleBuilder`.
  The wide top bar still contains Safaeh's Close button. For an intentionally
  different phone heading with the route title on wide screens, use
  `paintPhoneTitle: false` and render the content heading only on phone.
- Keep generic Close buttons out of the content and footer. Safaeh provides one
  at the trailing edge of the wide top bar and uses the drag handle on phone.
  Use `tabletTopBarAction` for a separate wide-only action and reserve the footer
  for actions the flow needs, such as Save or Apply.

## Use one layer of content padding

- For a plain `showSafaeh` child, keep the route's default body inset
  (`sheetBodyInset` on phone and `sheetBodyInsetWide` on wide screens).
- With `SafaehSheetTemplate` or `SafaehSheetDataLoader`, pass
  `contentPadding: EdgeInsets.zero` to `showSafaeh`. Set the content inset and
  slot gaps with `SafaehSheetTemplateStyle`, or override `padding` for a single
  template. Use inner padding for content inside a surface, such as form fields.
- Let the route manage outer margins, safe areas, and keyboard insets. The phone
  panel docks flush with the bottom and the wide dialog centers in the viewport.
  Keep the route defaults for a standard sheet. The open sheet keeps its body
  state when it switches between phone and wide presentation.

```dart
showSafaeh<void>(
  context: context,
  title: labels.editName,
  contentPadding: EdgeInsets.zero, // Template owns its content padding.
  child: SafaehSheetTemplate(
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

## Preserve scrolling and dismissal

- Let the template scroll its header and body together while feedback and footer
  stay pinned. When the body already scrolls (for example, a `ListView`), set
  `scrollBody: false` and let the body own scrolling. The template header then
  stays above the list. The route supplies bounded height. An inline unbounded
  list needs its usual `shrinkWrap` arrangement. If a pinned footer leaves too
  little room for the body at a short height or large text size, move the
  actions into the scrollable content for that layout.
- Leave `footer` and `feedback` unset for immediate selection. Use `safaehPop`
  with a context inside the route to return an explicit action or selection
  result to the caller. For a picker with Apply, keep the draft selection in
  state the open sheet can observe. Apply returns the current draft.
- With the defaults, the scrim and system Back dismiss the route, and a phone
  sheet also dismisses on a deliberate downward drag. Its primary scrollable
  hands off the pull at the top. Set `enableDrag: false` to disable the drag
  gesture, or change `SafaehSheet.of(context).enableDrag` while open.
- `barrierDismissible: false` blocks scrim, system Back, drag dismissal, and the
  phone handle's accessibility dismiss action. The wide Close button remains an
  explicit dismissal path. Account for it if the flow needs to prevent dismissal.

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

An app-level wrapper can supply localized headings, logging, and action
policies while reusing the same route and content layout.

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

The host's action handler runs futures, validates forms, reports errors, and
decides when to pop the route or ask for confirmation before a retry.

## Preview and verification

Open a changed modal at phone and wide widths. Check that the title appears
once in its intended location, the default phone sheet has a handle, and wide
mode has exactly one trailing Close button. With a long body, verify that the
body scrolls and any pinned actions stay reachable. Check that the body inset
is applied once. For forms, open the keyboard and verify that the focused field
and primary action remain reachable. Exercise the dismissal paths the flow
uses and verify their return values. For a picker with Apply, change the
selection after opening and verify that Apply returns the new choice.
Resize while a draft is open and verify that the input and selection survive.

Widgetbook → Sheets includes **Sheet template**, **Sheet loading**, and
**Sheet action**. Try footer/spacing overrides, cached and failing reads,
action states, auxiliary slots, Arabic, large text, dark mode, and reduced motion.
`test/sheet_template_test.dart` exercises the public template interfaces.

These APIs are available in Safaeh 1.2.5. Consumers can use `safaeh: ^1.2.5`
from pub.dev; local path overrides are only needed when developing the package.
