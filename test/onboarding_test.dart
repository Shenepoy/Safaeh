import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: Scaffold(body: child),
  );
}

List<SafaehOnboardingStep> _steps() => [
  SafaehOnboardingStep(
    id: 'welcome',
    titleBuilder: (_) => const Text('Welcome'),
    subtitleBuilder: (_) => const Text('A short introduction.'),
    bodyBuilder: (_) => const SafaehOnboardingList(
      children: [
        SafaehOnboardingListItem(
          title: Text('Groups'),
          subtitle: Text('Keep shared work together.'),
          leading: Icon(Icons.groups_outlined),
        ),
      ],
    ),
  ),
  SafaehOnboardingStep(
    id: 'finish',
    titleBuilder: (_) => const Text('Ready'),
    bodyBuilder: (_) => const Text('Finish setup.'),
  ),
];

void main() {
  test('catalog exposes six stable public designs', () {
    expect(SafaehOnboardingDesign.values, hasLength(6));
    expect(SafaehOnboardingDesignCatalog.all, hasLength(6));
    expect(
      SafaehOnboardingDesignCatalog.all.map((info) => info.id),
      orderedEquals(['meadow', 'orbit', 'paper', 'atelier', 'zen', 'prism']),
    );
    expect(
      SafaehOnboardingDesignCatalog.tryParse('orbit'),
      SafaehOnboardingDesign.orbit,
    );
    expect(SafaehOnboardingDesignCatalog.tryParse('missing'), isNull);
  });

  testWidgets('catalog previews are independently renderable', (tester) async {
    for (final info in SafaehOnboardingDesignCatalog.all) {
      await tester.pumpWidget(_host(Builder(builder: info.previewBuilder)));
      await tester.pumpAndSettle();
      expect(find.text(info.displayName), findsOneWidget, reason: info.id);
    }
  });

  testWidgets('every design renders the public onboarding shell', (
    tester,
  ) async {
    for (final design in SafaehOnboardingDesign.values) {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 480,
            height: 760,
            child: SafaehOnboarding(
              key: ValueKey(design),
              design: design,
              steps: _steps(),
              actions: SafaehOnboardingHostActions(
                languageControl: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.language),
                ),
                themeControl: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.brightness_6),
                ),
                onComplete: () async => SafaehOnboardingResult.completed,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Welcome'), findsOneWidget, reason: design.name);
      expect(find.bySemanticsLabel('Step 1 of 2'), findsWidgets);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Ready'), findsOneWidget);
    }
  });

  testWidgets(
    'centers host controls while keeping the primary action at the edge',
    (tester) async {
      const languageKey = ValueKey('language-control');
      const themeKey = ValueKey('theme-control');
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 480,
            height: 760,
            child: SafaehOnboarding(
              initialStep: 1,
              controlPlacement: SafaehOnboardingControlPlacement.bottomCenter,
              steps: _steps(),
              actions: SafaehOnboardingHostActions(
                languageControl: IconButton(
                  key: languageKey,
                  onPressed: () {},
                  icon: const Icon(Icons.language),
                ),
                themeControl: IconButton(
                  key: themeKey,
                  onPressed: () {},
                  icon: const Icon(Icons.brightness_6),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final language = tester.getCenter(find.byKey(languageKey));
      final theme = tester.getCenter(find.byKey(themeKey));
      expect((language.dx + theme.dx) / 2, closeTo(240, 1));
      expect(language.dy, greaterThan(400));
      expect(tester.getCenter(find.byType(FilledButton)).dx, greaterThan(300));
    },
  );

  testWidgets('constrains wide-screen onboarding chrome when requested', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _host(
        SafaehOnboarding(
          contentMaxWidth: 640,
          steps: _steps(),
          actions: SafaehOnboardingHostActions(
            onComplete: () async => SafaehOnboardingResult.completed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tracker = tester.getRect(find.byType(LinearProgressIndicator));
    final next = tester.getRect(find.text('Next'));
    expect(tracker.width, lessThan(640));
    expect(tracker.center.dx, closeTo(600, 1));
    expect(next.right, lessThanOrEqualTo(920));
    expect(next.right, greaterThan(500));
  });

  testWidgets('skip defaults to top end and supports every placement', (
    tester,
  ) async {
    Future<void> pumpPlacement(SafaehOnboardingSkipPlacement placement) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 480,
            height: 760,
            child: SafaehOnboarding(
              skipPlacement: placement,
              showSkip: true,
              steps: _steps(),
              actions: SafaehOnboardingHostActions(onSkip: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final skip = find.text('Skip');

    await pumpPlacement(SafaehOnboardingSkipPlacement.topEnd);
    expect(tester.getCenter(skip).dx, greaterThan(300));
    expect(tester.getCenter(skip).dy, lessThan(100));

    await pumpPlacement(SafaehOnboardingSkipPlacement.topStart);
    expect(tester.getCenter(skip).dx, lessThan(180));
    expect(tester.getCenter(skip).dy, lessThan(100));

    await pumpPlacement(SafaehOnboardingSkipPlacement.bottomEnd);
    expect(tester.getCenter(skip).dx, greaterThan(260));
    expect(tester.getCenter(skip).dy, greaterThan(500));

    await pumpPlacement(SafaehOnboardingSkipPlacement.bottomStart);
    expect(tester.getCenter(skip).dx, lessThan(180));
    expect(tester.getCenter(skip).dy, greaterThan(500));
  });

  testWidgets('top skip keeps its full hit target above the page', (
    tester,
  ) async {
    var skipCount = 0;
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 480,
          height: 760,
          child: SafaehOnboarding(
            showSkip: true,
            steps: _steps(),
            actions: SafaehOnboardingHostActions(onSkip: () => skipCount++),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shell = tester.getRect(find.byType(SafaehOnboarding));
    final skip = find.widgetWithText(TextButton, 'Skip');
    final skipRect = tester.getRect(skip);
    expect(skipRect.height, greaterThanOrEqualTo(48));
    expect(skipRect.left, greaterThanOrEqualTo(shell.left));
    expect(skipRect.right, lessThanOrEqualTo(shell.right));
    expect(skipRect.top, greaterThanOrEqualTo(shell.top));

    await tester.tap(skip, warnIfMissed: false);
    expect(skipCount, 1);
  });

  testWidgets('back action is transparent and uses white foreground', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 480,
          height: 760,
          child: SafaehOnboarding(initialStep: 1, steps: _steps()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final back = tester.widget<TextButton>(find.byType(TextButton).first);
    final states = <WidgetState>{};
    expect(back.style?.backgroundColor?.resolve(states), Colors.transparent);
    expect(back.style?.foregroundColor?.resolve(states), Colors.white);
    expect(back.style?.side?.resolve(states), BorderSide.none);
  });

  testWidgets('footer fade reaches the viewport bottom behind the home inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      _host(
        SafaehOnboarding(
          steps: _steps(),
          actions: SafaehOnboardingHostActions(
            onComplete: () async => SafaehOnboardingResult.completed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final footerSurface = find.byKey(
      const ValueKey('safaeh-onboarding-action-bar-surface'),
    );
    expect(tester.getRect(footerSurface).bottom, closeTo(800, 1));
    expect(tester.getRect(find.text('Next')).bottom, lessThan(800 - 34));
  });

  testWidgets('Zen tracker keeps strong contrast in light mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        home: const Scaffold(
          body: SafaehOnboardingTracker(
            currentStep: 0,
            totalSteps: 4,
            design: SafaehOnboardingDesign.zen,
          ),
        ),
      ),
    );

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.backgroundColor, isNotNull);
    expect(progress.backgroundColor!.a, greaterThanOrEqualTo(0.7));
    expect(progress.minHeight, greaterThanOrEqualTo(3));
  });

  testWidgets('legacy dots tracker preserves the compact page indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehOnboardingTracker(
            currentStep: 1,
            totalSteps: 4,
            style: SafaehOnboardingTrackerStyle.legacyDots,
          ),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsNothing);
    final dots = find.byType(AnimatedContainer);
    expect(dots, findsNWidgets(4));
    expect(tester.getRect(dots.at(1)).width, 36);
    expect(tester.getRect(dots.at(1)).height, 8);
    expect(tester.getRect(dots.first).width, 16);
    expect(tester.getRect(dots.first).height, 7);
  });

  testWidgets('host can switch designs without losing the current step', (
    tester,
  ) async {
    var design = SafaehOnboardingDesign.meadow;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 480,
            height: 760,
            child: Column(
              children: [
                Expanded(
                  child: SafaehOnboarding(
                    key: const ValueKey('flow'),
                    design: design,
                    initialStep: 1,
                    steps: _steps(),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => design = SafaehOnboardingDesign.prism),
                  child: const Text('Switch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('auth presentation supports every design', (tester) async {
    for (final design in SafaehOnboardingDesign.values) {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 480,
            height: 760,
            child: SafaehAuthFlow(
              design: design,
              actions: SafaehAuthActions(
                onSubmit: (_) async {},
                onProvider: (_) async {},
                onMagicLink: (_) async {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
    }
  });

  testWidgets('all generic auth states support every design', (tester) async {
    const modes = SafaehAuthMode.values;
    for (final design in SafaehOnboardingDesign.values) {
      for (final mode in modes) {
        await tester.pumpWidget(
          _host(
            SizedBox(
              width: 480,
              height: 760,
              child: SafaehAuthFlow(
                key: ValueKey('$design-$mode'),
                design: design,
                snapshot: SafaehAuthSnapshot(
                  mode: mode,
                  pendingEmail: 'person@example.com',
                ),
                actions: SafaehAuthActions(
                  onSubmit: (_) async {},
                  onProfileSubmit: (_) async {},
                  onProvider: (_) async {},
                  onMagicLink: (_) async {},
                  onPasswordReset: (_) async {},
                  onResend: () async {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SafaehAuthFlow), findsOneWidget, reason: mode.name);
      }
    }
  });

  testWidgets('localized RTL and accessibility settings remain usable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.35),
            disableAnimations: true,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(
                width: 480,
                height: 760,
                child: SafaehOnboarding(
                  steps: _steps(),
                  labels: const SafaehOnboardingLabels(
                    back: 'رجوع',
                    next: 'التالي',
                    complete: 'تم',
                  ),
                  actions: SafaehOnboardingHostActions(
                    onComplete: () async => SafaehOnboardingResult.completed,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('التالي'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 1 of 2'), findsWidgets);
  });
}
