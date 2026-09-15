<!-- markdownlint-disable MD033 MD060 -->

<div dir="rtl" lang="ar">

<p align="center">
  <img src="assets/safaeh-logo.svg" alt="صفائح" width="220" />
</p>

<h1 align="center">صفائح — Safaeh</h1>

<p align="center">
  <span dir="ltr"><code>safaeh</code></span><br/>
  sheets متكيّفة، وchrome للكاميرا / QR، وpage index، وsidenav لـ Flutter —<br/>
  التطبيق المضيف يحتفظ بـ i18n والتوجيه وplugin الكاميرا.
</p>

<p align="center">
  <a href="https://zyzto.github.io/Safaeh/"><img alt="المثال الحي" src="https://img.shields.io/badge/live%20demo-zyzto.github.io%2FSafaeh-8B6914?style=for-the-badge" /></a>
</p>

<p align="center">
  <a href="https://pub.dev/packages/safaeh"><img alt="pub.dev" src="https://img.shields.io/pub/v/safaeh.svg?style=flat-square&label=pub.dev&color=8B6914" /></a>
  <a href="https://github.com/Zyzto/Safaeh"><img alt="repo" src="https://img.shields.io/badge/github-Zyzto%2FSafaeh-C0C0C0?style=flat-square" /></a>
  <img alt="flutter" src="https://img.shields.io/badge/Flutter-%3E%3D3.11-C0C0C0?style=flat-square&logo=flutter&logoColor=white" />
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MPL--2.0-8B6914?style=flat-square" /></a>
</p>

<p align="center">
  <strong><a href="https://zyzto.github.io/Safaeh/">المثال الحي</a></strong>
  — افتح كتالوج المثال في المتصفح<br/>
  <a href="https://zyzto.github.io/Safaeh/"><span dir="ltr">zyzto.github.io/Safaeh</span></a>
</p>

<p align="center">
  <a href="https://zyzto.github.io/Safaeh/">المثال الحي</a> ·
  <a href="#التثبيت">Install</a> ·
  <a href="#ابدأ-في-دقائق">Quick start</a> ·
  <a href="#ودجات">ودجات</a> ·
  <a href="#ماذا-تقدّم">Features</a> ·
  <a href="#ماذا-يبقى-في-التطبيق">Host app</a> ·
  <a href="#المثال">Example</a> ·
  <a href="CHANGELOG.md">Changelog</a> ·
  <a href="VERSIONING.md">Versioning</a> ·
  <a href="doc/host-integration.md">Host integration</a>
  <br/>
  <a href="README.md"><span dir="ltr">English</span></a>
</p>

<p align="center">
  الاسم <span dir="ltr"><strong>safaeh</strong></span> من العربية
  <strong>صفائح</strong>
  (<span dir="ltr"><em>ṣafāʾiḥ</em></span>): sheets / plates —
  جمع <em>صفيحة</em> (<span dir="ltr"><em>ṣafīḥa</em></span>).
</p>

</div>

---

<div dir="rtl" lang="ar">

## لماذا؟

تطبيقات Flutter تجمع bottom sheets وdialogs وrails وoverlays للكاميرا متفرقة. ثم تحتاج:

- نفس الـ route يكون sheet على الهاتف وdialog على الجهاز اللوحي، ويتحوّل عند عبور نقطة العرض
- chrome يحترم <span dir="ltr"><code>MediaQuery.disableAnimationsOf</code></span>
- بلا <span dir="ltr"><code>easy_localization</code></span> أو Riverpod أو <span dir="ltr"><code>go_router</code></span> أو <span dir="ltr"><code>mobile_scanner</code></span> داخل الحزمة

**صفائح** هي طبقة الـ chrome هذه. مستخدمة في حساب.

على <span dir="ltr">pub.dev</span>: <span dir="ltr"><a href="https://pub.dev/packages/safaeh"><code>safaeh</code></a></span> · المستودع: <span dir="ltr"><a href="https://github.com/Zyzto/Safaeh">Zyzto/Safaeh</a></span>.

</div>

---

<div dir="rtl" lang="ar">

## ودجات

</div>

<p align="center">
  <a href="https://zyzto.github.io/Safaeh/">
    <img src="screenshots/picker.png" alt="منتقي البطاقات — المثال الحي" width="200" />
    <img src="screenshots/confirm.png" alt="ورقة تأكيد — المثال الحي" width="200" />
    <img src="screenshots/option-tiles.png" alt="صفوف خيارات — المثال الحي" width="200" />
  </a>
</p>

<p align="center">
  <sub>منتقي البطاقات · تأكيد · صفوف خيارات — <a href="https://zyzto.github.io/Safaeh/">جرّبها في المثال الحي</a></sub>
</p>

<p align="center">
  <a href="https://zyzto.github.io/Safaeh/">
    <img src="screenshots/sidenav.png" alt="سكة جانبية — المثال الحي" width="320" />
  </a>
</p>

<div dir="rtl" lang="ar">

مُلتقطة بـ <span dir="ltr"><a href="https://pub.dev/packages/widgets_to_image"><code>widgets_to_image</code></a></span> عبر <span dir="ltr"><code>cd example && flutter test test/widget_images_test.dart</code></span>.

</div>

---

<div dir="rtl" lang="ar">

## ماذا تقدّم؟

| المجال | ماذا تحصل |
|--------|-----------|
| **Sheets** | <span dir="ltr"><code>showSafaeh</code></span> يحوّل sheet الهاتف ↔ dialog الجهاز اللوحي؛ <span dir="ltr"><code>showSafaehPicker</code></span> / <span dir="ltr"><code>SafaehOption</code></span> (بطاقات، <span dir="ltr"><code>enabled</code></span>)؛ <span dir="ltr"><code>showSafaehTilePicker</code></span> / <span dir="ltr"><code>SafaehTileOption</code></span> (صفوف قائمة، بحث)؛ <span dir="ltr"><code>showSafaehMultiTilePicker</code></span> (اختيار متعدد)؛ <span dir="ltr"><code>showSafaehConfirm</code></span>، <span dir="ltr"><code>showSafaehTextInput</code></span>، <span dir="ltr"><code>SafaehStatusBody</code></span>، <span dir="ltr"><code>buildSafaehSheetShell</code></span>، <span dir="ltr"><code>SafaehOptionList</code></span>، <span dir="ltr"><code>SafaehOptionTile</code></span> |
| **Dialog** | <span dir="ltr"><code>showSafaehDialog</code></span> لوحة متمركزة مع <span dir="ltr"><code>railWidthOf</code></span> اختياري |
| **Theme** | <span dir="ltr"><code>SafaehTheme</code></span> / <span dir="ltr"><code>SafaehThemeData</code></span> لنقطة العرض والحركة ونصف القطر وعرض الـ rail وارتفاع الكاميرا المضغوط و<span dir="ltr"><code>contentMaxWidth</code></span>؛ <span dir="ltr"><code>copyWith</code></span> |
| **Motion** | <span dir="ltr"><code>safaehResolvedMotion</code></span> يصفر المدد عندما تُعطَّل الحركات |
| **Nav** | <span dir="ltr"><code>SafaehSidenav</code></span> درج مؤقت (<span dir="ltr"><code>asDrawer: true</code></span>) أو rail قصّ؛ <span dir="ltr"><code>SafaehFloatingNavBar</code></span> (نفس <span dir="ltr"><code>SafaehSidenavDestination</code></span>) |
| **Page index** | <span dir="ltr"><code>SafaehPageIndex</code></span> وoverlay و<span dir="ltr"><code>scrollToPageSection</code></span> و<span dir="ltr"><code>safaehActivePageSectionId</code></span> (معرفات + مفاتيح فقط — بلا <span dir="ltr"><code>.tr()</code></span> أثناء التمرير) |
| **App bar** | <span dir="ltr"><code>SafaehMorphingAppBar</code></span> و<span dir="ltr"><code>SafaehMorphingAppBarAction</code></span> و<span dir="ltr"><code>SafaehMorphingAppBarBottom</code></span> لتحويل العنوان والأفعال وchrome السفلي حسب الصفحة |
| **Content** | <span dir="ltr"><code>safaehBandMetrics</code></span>، <span dir="ltr"><code>SafaehContentBand</code></span>، <span dir="ltr"><code>SafaehEndAsideLayout</code></span>، <span dir="ltr"><code>SafaehContentAlignedAppBar</code></span>، <span dir="ltr"><code>SafaehContentAlignedFabLocation</code></span> |
| **Camera** | <span dir="ltr"><code>showSafaehCameraSheet</code></span> / <span dir="ltr"><code>SafaehCameraSheetHost</code></span> لفة ورق مضغوط ↔ كامل |
| **QR chrome** | <span dir="ltr"><code>SafaehQrScannerOverlay</code></span> (معاينة مضيف اختيارية)، <span dir="ltr"><code>SafaehQrTopBar</code></span>، <span dir="ltr"><code>SafaehQrMessageBody</code></span>، <span dir="ltr"><code>SafaehQrFramePainter</code></span> |
| **RTL** | <span dir="ltr"><code>safaehChevronEnd</code></span>، <span dir="ltr"><code>safaehChevronStart</code></span>، <span dir="ltr"><code>safaehArrowBack</code></span> (رموز LTR؛ Material يعكسها عبر <span dir="ltr"><code>matchTextDirection</code></span>) |

**Core:** Flutter Material فقط. المعاينة وفك الشفرة والنصوص والتوجيه تبقى في التطبيق المضيف.

</div>

---

<div dir="rtl" lang="ar">

## التثبيت

</div>

```yaml
dependencies:
  safaeh: ^0.4.0
```

<div dir="rtl" lang="ar">

أو:

</div>

```bash
flutter pub add safaeh
```

<div dir="rtl" lang="ar">

تثبيت بوسم Git (انظر <span dir="ltr"><a href="VERSIONING.md">VERSIONING.md</a></span>):

</div>

```yaml
dependencies:
  safaeh:
    git:
      url: https://github.com/Zyzto/Safaeh.git
      ref: v0.4.0
```

```dart
import 'package:safaeh/safaeh.dart';
```

<div dir="rtl" lang="ar">

الإصدار الحالي: **0.4.0**.

</div>

---

<div dir="rtl" lang="ar">

## ابدأ في دقائق

### 1. غلّف التطبيق

</div>

```dart
SafaehTheme(
  data: const SafaehThemeData(
    tabletBreakpoint: 600,
    dialogMaxWidth: 560,
  ),
  child: MaterialApp(
    home: const MyHome(),
  ),
);
```

<div dir="rtl" lang="ar">

مواقع الاستدعاء ما زالت تستطيع تجاوز نقطة العرض والحركة والانتقالات.

### 2. Sheet متكيّف

</div>

```dart
await showSafaeh<void>(
  context: context,
  title: 'Rename',
  titleBuilder: (context, style) => Text('Rename', style: style),
  child: const TextField(),
);
```

<div dir="rtl" lang="ar">

الهاتف: bottom sheet. الجهاز اللوحي+: dialog متمركز. نفس الـ route يتحوّل عندما يتجاوز العرض <span dir="ltr"><code>tabletBreakpoint</code></span>. مرّر <span dir="ltr"><code>phonePlacement: SafaehPhoneSheetPlacement.center</code></span> لرفع ورقة الهاتف حتى يحاذي مركز أول محتوى مركز الشاشة (ما زالت ملامسة للأسفل).

### 3. Option picker

</div>

```dart
final choice = await showSafaehPicker<int>(
  context: context,
  title: 'How to settle',
  selected: 1,
  options: const [
    SafaehOption(
      value: 1,
      label: 'Minimal',
      subtitle: 'Fewest transfers',
      icon: Icons.bolt_outlined,
    ),
  ],
);
```

<div dir="rtl" lang="ar">

عنوان الجسم يُخفى عندما يكون العرض واسعاً (عنوان الرأس فقط).
<span dir="ltr"><code>SafaehOption.enabled</code></span> يخفت البطاقة ويتجاهل النقر.

### 4. Tile picker (صفوف قائمة)

```dart
final mode = await showSafaehTilePicker<String>(
  context: context,
  title: 'Import mode',
  titleBuilder: (context, style) => Text('Import mode', style: style),
  header: const Text('12 new · 3 updated'),
  selected: 'add',
  options: const [
    SafaehTileOption(
      value: 'add',
      label: 'Add copies',
      subtitle: 'Keeps existing data',
      leading: Icon(Icons.add_circle_outline),
    ),
    SafaehTileOption(
      value: 'replace',
      label: 'Replace',
      enabled: false,
    ),
  ],
);
```

يستخدم <span dir="ltr"><code>SafaehOptionList</code></span> + <span dir="ltr"><code>SafaehOptionTile</code></span>. التطبيقات التي تغلف <span dir="ltr"><code>showSafaeh</code></span> يمكنها وضع <span dir="ltr"><code>SafaehTilePickerBody</code></span> كطفل. نفس خيارات <span dir="ltr"><code>showSafaeh*</code></span> (<span dir="ltr"><code>railWidthOf</code></span>، <span dir="ltr"><code>motion</code></span>، …).

### 5. تأكيد وإدخال نص

التطبيق المضيف يمرّر كل التسميات. الهاتف يعرض إلغاء في صف الإجراءات؛ الجهاز اللوحي يستخدم زر إغلاق الـ sheet. <span dir="ltr"><code>showSafaehConfirm</code></span> يعيد <span dir="ltr"><code>true</code></span> عند التأكيد، و<span dir="ltr"><code>false</code></span> عند إلغاء الهاتف، و<span dir="ltr"><code>null</code></span> عند الإغلاق (زر الإغلاق على الجهاز اللوحي أو الحاجز). اعتبر مؤكداً فقط عندما يكون <span dir="ltr"><code>ok == true</code></span>.

```dart
final ok = await showSafaehConfirm(
  context: context,
  title: 'Delete item',
  content: 'This cannot be undone.',
  confirmLabel: 'Delete',
  cancelLabel: 'Cancel',
  isDestructive: true,
  titleBuilder: (context, style) => Text('Delete item', style: style),
);

final name = await showSafaehTextInput(
  context: context,
  title: 'Tag name',
  doneLabel: 'Done',
  cancelLabel: 'Cancel',
  titleBuilder: (context, style) => Text('Tag name', style: style),
);
```

### 6. Dialog متمركز

```dart
await showSafaehDialog<void>(
  context: context,
  railWidthOf: (context) => 0,
  builder: (context) => const Card(child: Text('Hello')),
);
```

### 7. شريط تنقّل عائم وشريط محتوى

```dart
SafaehFloatingNavBar(
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  destinations: const [
    SafaehSidenavDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
  ],
);

SafaehContentBand(
  aside: const Text('On this page'),
  child: body,
);
```

<div dir="rtl" lang="ar">

<span dir="ltr"><code>SafaehContentBand</code></span> يتمركز من قيود العرض الواردة ويُخفي <span dir="ltr"><code>aside</code></span> عندما يكون العرض ضيقاً. التطبيقات ذات rail شقيق تبقي حساب <span dir="ltr"><code>leftOffset</code></span> / <span dir="ltr"><code>bandWidth</code></span> وتستخدم <span dir="ltr"><code>SafaehEndAsideLayout</code></span>.

مقاييس الشريط للتطبيقات الأخرى (شريط التطبيق، FAB، aside):

```dart
final metrics = safaehBandMetrics(
  contentAreaWidth: constraints.maxWidth,
  maxWidth: 600,
);

SafaehContentAlignedAppBar(
  leftOffset: metrics.leftOffset,
  bandWidth: metrics.bandWidth,
  title: const Text('Title'),
);

SafaehContentAlignedFabLocation.resolve(
  leftOffset: metrics.leftOffset,
  bandWidth: metrics.bandWidth,
  endFree: metrics.endFree,
  textDirection: Directionality.of(context),
);
```

انظر <span dir="ltr"><a href="doc/host-integration.md">doc/host-integration.md</a></span>.

### 8. شريط التطبيق المتحوّل

استخدم <span dir="ltr"><code>SafaehMorphingAppBar</code></span> عندما يبقى
شريط تطبيق واحد مثبتاً أثناء انتقال <span dir="ltr"><code>PageView</code></span>
بين الوجهات. مرّر موضع الصفحة الحالي وعناوين مترجمة من التطبيق المضيف:

```dart
SafaehMorphingAppBar(
  page: pageController.page ?? 0,
  titles: [Text(l10n.home), Text(l10n.statistics), Text(l10n.settings)],
  leading: const SizedBox(width: kToolbarHeight),
  actionsBuilder: (context, page) => Stack(
    alignment: AlignmentDirectional.center,
    children: [
      SafaehMorphingAppBarAction(
        page: page,
        targetPage: 0,
        child: IconButton(
          tooltip: l10n.home,
          onPressed: openHome,
          icon: const Icon(Icons.home_outlined),
        ),
      ),
      SafaehMorphingAppBarAction(
        page: page,
        targetPage: 2,
        child: IconButton(
          tooltip: l10n.settings,
          onPressed: openSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ),
    ],
  ),
  bottom: SafaehMorphingAppBarBottom(
    factor: (2 - (pageController.page ?? 0)).clamp(0.0, 1.0).toDouble(),
    height: 48,
    child: const Center(child: Text('Range controls')),
  ),
);
```

الحزمة تملك التحويل البصري فقط؛ أما النصوص والترجمة والتوجيه فتظل في
التطبيق المضيف. يشرح <span dir="ltr"><a href="doc/host-integration.md">دليل التكامل</a></span>
الحساب الكامل للأفعال والـ bottom chrome، ويوجد مثال تفاعلي في كتالوج
<span dir="ltr"><code>example/</code></span>.

### 9. Chrome الكاميرا / QR

</div>

```dart
await showSafaehCameraSheet<void>(
  context: context,
  builder: (context, sheet) => MyPreview(
    expanded: sheet.expanded,
    onToggle: sheet.toggleExpanded,
    onClose: sheet.dismiss,
  ),
);
```

<div dir="rtl" lang="ar">

ضمّنه في مسار عبر <span dir="ltr"><code>SafaehCameraSheetHost</code></span> (احذف <span dir="ltr"><code>openAnimation</code></span>، مرّر <span dir="ltr"><code>onDismiss</code></span>). ضع <span dir="ltr"><code>SafaehQrScannerOverlay</code></span> / <span dir="ltr"><code>SafaehQrMessageBody</code></span> **داخل** اللوحة السفلية — هي تراكبات ملء، ليست ورقة مستقلة. أبقِ <span dir="ltr"><code>mobile_scanner</code></span> في التطبيق.

</div>

---

<div dir="rtl" lang="ar">

## ماذا يبقى في التطبيق؟

| المجال | يبقى في التطبيق |
|--------|-----------------|
| النصوص | <span dir="ltr"><code>easy_localization</code></span>، <span dir="ltr"><code>UserText</code></span>، <span dir="ltr"><code>titleBuilder</code></span> |
| التوجيه | <span dir="ltr"><code>go_router</code></span>، عرض الـ rail المحجوز عبر <span dir="ltr"><code>railWidthOf</code></span> |
| الكاميرا | <span dir="ltr"><code>mobile_scanner</code></span>، الصلاحيات، قفل الاتجاه عبر <span dir="ltr"><code>SystemChrome</code></span> |
| الحالة | Riverpod / ما يستخدمه التطبيق أصلاً |
| Tiles | <span dir="ltr"><code>UserText</code></span> + ألوان لكنة اختيارية على <span dir="ltr"><code>SafaehOptionTile</code></span> |

</div>

---

<div dir="rtl" lang="ar">

## جرد الـ UI

**Sheets:** <span dir="ltr"><code>showSafaeh</code></span>، <span dir="ltr"><code>SafaehRouteOptions</code></span>، <span dir="ltr"><code>showSafaehPicker</code></span>، <span dir="ltr"><code>SafaehOption</code></span>، <span dir="ltr"><code>SafaehOptionPickerBody</code></span>، <span dir="ltr"><code>showSafaehTilePicker</code></span>، <span dir="ltr"><code>showSafaehMultiTilePicker</code></span>، <span dir="ltr"><code>SafaehTileOption</code></span>، <span dir="ltr"><code>SafaehTilePickerBody</code></span>، <span dir="ltr"><code>SafaehTileBuilder</code></span>، <span dir="ltr"><code>showSafaehConfirm</code></span>، <span dir="ltr"><code>SafaehConfirmSheet</code></span>، <span dir="ltr"><code>showSafaehTextInput</code></span>، <span dir="ltr"><code>SafaehTextInputSheet</code></span>، <span dir="ltr"><code>SafaehStatusBody</code></span>، <span dir="ltr"><code>buildSafaehSheetShell</code></span>، <span dir="ltr"><code>SafaehOptionList</code></span>، <span dir="ltr"><code>SafaehOptionTile</code></span>، <span dir="ltr"><code>kSheetContentPadding</code></span>، <span dir="ltr"><code>kSafaehSheetPadding</code></span>، <span dir="ltr"><code>SafaehTitleBuilder</code></span>، <span dir="ltr"><code>SafaehLabelBuilder</code></span>، <span dir="ltr"><code>safaehTitleFromLabel</code></span>، <span dir="ltr"><code>safaehPop</code></span>، <span dir="ltr"><code>SafaehTransition</code></span>، <span dir="ltr"><code>safaehFadeScale</code></span>، <span dir="ltr"><code>safaehFade</code></span>، <span dir="ltr"><code>SafaehPhoneSheetPlacement</code></span>، <span dir="ltr"><code>safaehPhoneCenterSheetTop</code></span>

**Dialog:** <span dir="ltr"><code>showSafaehDialog</code></span>

**Camera:** <span dir="ltr"><code>showSafaehCameraSheet</code></span>، <span dir="ltr"><code>SafaehCameraSheetHost</code></span>، <span dir="ltr"><code>SafaehCameraSheet</code></span>، <span dir="ltr"><code>SheetHandleBar</code></span>، <span dir="ltr"><code>SheetHandleDrag</code></span>

**QR:** <span dir="ltr"><code>SafaehQrScannerOverlay</code></span>، <span dir="ltr"><code>SafaehQrTopBar</code></span>، <span dir="ltr"><code>SafaehQrMessageBody</code></span>، <span dir="ltr"><code>SafaehQrFramePainter</code></span>

**Shell:** <span dir="ltr"><code>SafaehSidenav</code></span>، <span dir="ltr"><code>SafaehSidenavDestination</code></span>، <span dir="ltr"><code>SafaehSidenavProfile</code></span>، <span dir="ltr"><code>SafaehSidenavAvatar</code></span>، <span dir="ltr"><code>SafaehFloatingNavBar</code></span>، <span dir="ltr"><code>SafaehPageIndex</code></span>، <span dir="ltr"><code>SafaehPageIndexOverlay</code></span>، <span dir="ltr"><code>scrollToPageSection</code></span>، <span dir="ltr"><code>safaehActivePageSectionId</code></span>، <span dir="ltr"><code>SafaehMorphingAppBar</code></span>، <span dir="ltr"><code>SafaehMorphingAppBarAction</code></span>، <span dir="ltr"><code>SafaehMorphingAppBarBottom</code></span>، <span dir="ltr"><code>safaehBandMetrics</code></span>، <span dir="ltr"><code>SafaehContentBand</code></span>، <span dir="ltr"><code>SafaehEndAsideLayout</code></span>، <span dir="ltr"><code>SafaehContentAlignedAppBar</code></span>، <span dir="ltr"><code>SafaehContentAlignedFabLocation</code></span>

**Tokens:** <span dir="ltr"><code>SafaehTheme</code></span>، <span dir="ltr"><code>SafaehThemeData</code></span>، <span dir="ltr"><code>SafaehThemeData.copyWith</code></span>، <span dir="ltr"><code>safaehResolvedMotion</code></span>، <span dir="ltr"><code>kSafaehCameraCompactHeightFraction</code></span>

**RTL:** <span dir="ltr"><code>safaehChevronEnd</code></span>، <span dir="ltr"><code>safaehChevronStart</code></span>، <span dir="ltr"><code>safaehArrowBack</code></span>

</div>

---

<div dir="rtl" lang="ar">

## Architecture

</div>

```
┌─────────────────────────────────────────────────────────────┐
│         Host app (i18n, GoRouter, camera, UserText)         │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                      SafaehTheme                             │
│   breakpoint · motion · radius · rail · camera fraction     │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│  showSafaeh / picker / confirm / text / dialog              │
│  SafaehSidenav · floating nav · page index · content band   │
│  camera sheet host · QR overlay chrome                      │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│              Flutter Material (no Riverpod)                 │
└─────────────────────────────────────────────────────────────┘
```

---

<div dir="rtl" lang="ar">

## المثال

<strong><a href="https://zyzto.github.io/Safaeh/">المثال الحي — <span dir="ltr">zyzto.github.io/Safaeh</span></a></strong>

الكتالوج المستضاف هو بناء ويب <span dir="ltr"><code>example/</code></span>. التكامل المستمر ينشره بعد نجاح الاختبارات على <span dir="ltr"><code>main</code></span>.

كتالوج بلا Riverpod في <span dir="ltr"><a href="example/"><code>example/</code></a></span> — نفس تقسيم <span dir="ltr"><a href="https://github.com/Zyzto/Edadat">Edadat</a></span>: <span dir="ltr"><code>catalog.dart</code></span> (نصوص en / ar / ja / zh / es)، <span dir="ltr"><code>app.dart</code></span>، ومعرض عمودي في <span dir="ltr"><code>SafaehContentBand</code></span> لكل API عام. عناوين الأقسام تفتح العرض المستقل، والشاشات العريضة توزّع البطاقات على أعمدة في الصفحة نفسها. تبديل لغة وسمة، بلا <span dir="ltr"><code>mobile_scanner</code></span>.

المثال بأسلوب package (web فقط في المستودع)؛ حلّل بـ:

```bash
cd example && flutter pub get && dart analyze --fatal-infos && flutter test
```

<span dir="ltr"><code>example/test/widget_images_test.dart</code></span> يكتب صور الودجات إلى <span dir="ltr"><a href="screenshots/"><code>screenshots/</code></a></span>.

للتشغيل على جهاز، ولّد platforms الأخرى أولاً (<span dir="ltr"><code>flutter create . --platforms=android,ios</code></span> داخل <span dir="ltr"><code>example/</code></span>). التفاصيل: <span dir="ltr"><a href="example/README.md">example/README.md</a></span>.

اختبارات الحزمة:

</div>

```bash
dart analyze --fatal-infos && flutter test
```

---

<div dir="rtl" lang="ar">

## Branding

كلمة الشعار بخط <span dir="ltr"><strong><a href="https://www.1001fonts.com/baz-font.html">Baz</a></strong></span> (Baz Light) — نفس الـ typeface العربي في <span dir="ltr"><a href="https://github.com/Zyzto/Edadat">Edadat</a></span> و<span dir="ltr"><a href="https://github.com/Zyzto/Siglat">Siglat</a></span>. ملف الـ SVG يضم <strong>صــفائح</strong> كـ outlines (تطويل بعد <em>ص</em>) حتى يظهر على GitHub دون تحميل الخط. Baz ليس خطاً مسجَّلاً للحزمة، وملف الـ OTF غير مُرفق.

</div>

---

<div dir="rtl" lang="ar">

## Versioning

انظر <span dir="ltr"><a href="VERSIONING.md">VERSIONING.md</a></span> و<span dir="ltr"><a href="CHANGELOG.md">CHANGELOG.md</a></span>. الوسوم بصيغة <span dir="ltr"><code>vX.Y.Z</code></span> ويجب أن تطابق <span dir="ltr"><code>pubspec.yaml</code></span>.

</div>

---

<div dir="rtl" lang="ar">

## الرخصة

<span dir="ltr"><a href="LICENSE">MPL-2.0</a></span> — weak copyleft، الاستخدام التجاري مسموح. ملفات الحزمة المعدّلة تبقى تحت MPL؛ تطبيقك يمكن أن يبقى closed-source.

</div>
