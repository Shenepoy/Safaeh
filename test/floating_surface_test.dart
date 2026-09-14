import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh/src/floating_surface_renderer.dart';

void main() {
  testWidgets(
    'floating presets resolve fill, blur, edge, and shadow defaults',
    (tester) async {
      const surfaceKey = ValueKey('floating_surface');
      const fallback = Color(0xFF336699);
      final expectedTransparency = <SafaehFloatingSurfaceStyle, double>{
        SafaehFloatingSurfaceStyle.solid: 0,
        SafaehFloatingSurfaceStyle.translucent: 28,
        SafaehFloatingSurfaceStyle.glass: 48,
        SafaehFloatingSurfaceStyle.vista: 35,
      };
      final expectedBlur = <SafaehFloatingSurfaceStyle, double>{
        SafaehFloatingSurfaceStyle.solid: 0,
        SafaehFloatingSurfaceStyle.translucent: 0,
        SafaehFloatingSurfaceStyle.glass: 18,
        SafaehFloatingSurfaceStyle.vista: 32,
      };

      for (final style in SafaehFloatingSurfaceStyle.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.light(
                onSurface: Color(0xFF102030),
              ),
            ),
            home: ColoredBox(
              color: Colors.red,
              child: SafaehFloatingSurface(
                key: surfaceKey,
                appearance: SafaehFloatingAppearance(style: style),
                fallbackColor: fallback,
                child: const SizedBox(width: 160, height: 80),
              ),
            ),
          ),
        );

        final decorated = tester.widget<DecoratedBox>(
          _fillDecoration(find.byKey(surfaceKey)),
        );
        final decoration = decorated.decoration as BoxDecoration;
        expect(
          decoration.color!.a,
          closeTo(1 - expectedTransparency[style]! / 100, 0.01),
        );
        expect(
          find.descendant(
            of: find.byKey(surfaceKey),
            matching: find.byType(BackdropFilter),
          ),
          expectedBlur[style] == 0 ? findsNothing : findsOneWidget,
        );
        if (expectedBlur[style] != 0) {
          final filter = tester.widget<BackdropFilter>(
            find.descendant(
              of: find.byKey(surfaceKey),
              matching: find.byType(BackdropFilter),
            ),
          );
          expect(
            filter.filter!.debugShortDescription,
            'blur(${expectedBlur[style]}, ${expectedBlur[style]}, unspecified)',
          );
        }
        expect(
          _shadowDecoration(find.byKey(surfaceKey)),
          style == SafaehFloatingSurfaceStyle.glass ||
                  style == SafaehFloatingSurfaceStyle.vista
              ? findsOneWidget
              : findsNothing,
        );
        if (style == SafaehFloatingSurfaceStyle.glass ||
            style == SafaehFloatingSurfaceStyle.vista) {
          final border = decoration.border! as Border;
          expect(
            border.top.color.a,
            closeTo(
              style == SafaehFloatingSurfaceStyle.glass ? 0.20 : 0.28,
              0.01,
            ),
          );
          final clip = find.descendant(
            of: find.byKey(surfaceKey),
            matching: find.byType(ClipRRect),
          );
          expect(clip, findsOneWidget);
          expect(
            find.descendant(of: clip, matching: find.byType(BackdropFilter)),
            findsOneWidget,
          );
        }
      }
    },
  );

  testWidgets('glass defaults to the theme surface as its tint', (
    tester,
  ) async {
    const surfaceKey = ValueKey('glass_theme_surface');
    const fallback = Color(0xFF336699);
    const themeSurface = Color(0xFFF8FAFC);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            surface: themeSurface,
            onSurface: Color(0xFF102030),
          ),
        ),
        home: ColoredBox(
          color: Colors.blue,
          child: SafaehFloatingSurface(
            key: surfaceKey,
            appearance: const SafaehFloatingAppearance(
              style: SafaehFloatingSurfaceStyle.glass,
            ),
            fallbackColor: fallback,
            child: const SizedBox(width: 160, height: 80),
          ),
        ),
      ),
    );

    final decorated = tester.widget<DecoratedBox>(
      _fillDecoration(find.byKey(surfaceKey)),
    );
    final color = (decorated.decoration as BoxDecoration).color!;
    expect(color.r, closeTo(themeSurface.r, 0.01));
    expect(color.g, closeTo(themeSurface.g, 0.01));
    expect(color.b, closeTo(themeSurface.b, 0.01));
    expect(color.a, closeTo(0.52, 0.01));
  });

  testWidgets(
    'glass preserves the legacy dark fallback instead of a light tint',
    (tester) async {
      const surfaceKey = ValueKey('glass_dark_theme_surface');
      const fallback = Color(0xFF336699);
      const darkSurface = Color(0xFF101418);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              surface: darkSurface,
              onSurface: Color(0xFFE8EEF2),
            ),
          ),
          home: ColoredBox(
            color: Colors.black,
            child: SafaehFloatingSurface(
              key: surfaceKey,
              appearance: const SafaehFloatingAppearance(
                style: SafaehFloatingSurfaceStyle.glass,
              ),
              fallbackColor: fallback,
              child: const SizedBox(width: 160, height: 80),
            ),
          ),
        ),
      );

      final decorated = tester.widget<DecoratedBox>(
        _fillDecoration(find.byKey(surfaceKey)),
      );
      final color = (decorated.decoration as BoxDecoration).color!;
      // Safaeh v0.2.5 (used by v0.7.23-test) kept the host component's fallback
      // tint in dark mode. Preserve that older dark appearance while allowing
      // light mode to use the theme surface.
      expect(color.r, closeTo(fallback.r, 0.01));
      expect(color.g, closeTo(fallback.g, 0.01));
      expect(color.b, closeTo(fallback.b, 0.01));
      expect(color.a, closeTo(0.52, 0.01));
    },
  );

  testWidgets('zero and full transparency affect only the fill alpha', (
    tester,
  ) async {
    const surfaceKey = ValueKey('transparency_surface');
    final border = Border.all(color: Colors.white, width: 3);
    final shadow = const BoxShadow(color: Color(0xCC000000), blurRadius: 9);
    final shadows = [shadow];

    Future<void> pump(double transparency) {
      return tester.pumpWidget(
        MaterialApp(
          home: ColoredBox(
            color: Colors.red,
            child: SafaehFloatingSurface(
              key: surfaceKey,
              appearance: SafaehFloatingAppearance(
                style: SafaehFloatingSurfaceStyle.glass,
                transparency: transparency,
                blurSigma: 0,
                border: border,
                shadows: shadows,
              ),
              fallbackColor: Colors.blue,
              child: const SizedBox(width: 100, height: 40),
            ),
          ),
        ),
      );
    }

    await pump(0);
    var decorated = tester.widget<DecoratedBox>(
      _fillDecoration(find.byKey(surfaceKey)),
    );
    var decoration = decorated.decoration as BoxDecoration;
    expect(decoration.color!.a, closeTo(1, 0.01));
    expect(decoration.border, same(border));
    final shadowDecoration = tester.widget<DecoratedBox>(
      _shadowDecoration(find.byKey(surfaceKey)),
    );
    expect(
      (shadowDecoration.decoration as BoxDecoration).boxShadow,
      same(shadows),
    );

    await pump(100);
    decorated = tester.widget<DecoratedBox>(
      _fillDecoration(find.byKey(surfaceKey)),
    );
    decoration = decorated.decoration as BoxDecoration;
    expect(decoration.color!.a, closeTo(0, 0.01));
    expect(decoration.border, same(border));
    expect(
      (tester
                  .widget<DecoratedBox>(
                    _shadowDecoration(find.byKey(surfaceKey)),
                  )
                  .decoration
              as BoxDecoration)
          .boxShadow,
      same(shadows),
    );
    expect(
      find.descendant(
        of: find.byKey(surfaceKey),
        matching: find.byType(BackdropFilter),
      ),
      findsNothing,
    );
  });

  testWidgets('custom fields replace only their preset counterparts', (
    tester,
  ) async {
    const surfaceKey = ValueKey('custom_surface');
    final tint = const Color(0xCC123456);
    final border = Border.all(color: Colors.pink, width: 2);
    final shadows = [const BoxShadow(color: Color(0x99000000), blurRadius: 4)];

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehFloatingSurface(
          key: surfaceKey,
          appearance: SafaehFloatingAppearance(
            style: SafaehFloatingSurfaceStyle.glass,
            transparency: 25,
            blurSigma: 3,
            tintColor: tint,
            border: border,
            shadows: shadows,
          ),
          fallbackColor: Colors.blue,
          child: const SizedBox(width: 100, height: 40),
        ),
      ),
    );

    final decorated = tester.widget<DecoratedBox>(
      _fillDecoration(find.byKey(surfaceKey)),
    );
    final decoration = decorated.decoration as BoxDecoration;
    expect(decoration.color!.r, closeTo(tint.r, 0.01));
    expect(decoration.color!.a, closeTo(tint.a * 0.75, 0.01));
    expect(decoration.border, same(border));
    expect(
      (tester
                  .widget<DecoratedBox>(
                    _shadowDecoration(find.byKey(surfaceKey)),
                  )
                  .decoration
              as BoxDecoration)
          .boxShadow,
      same(shadows),
    );
    expect(
      find.descendant(
        of: find.byKey(surfaceKey),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<BackdropFilter>(
            find.descendant(
              of: find.byKey(surfaceKey),
              matching: find.byType(BackdropFilter),
            ),
          )
          .filter!
          .debugShortDescription,
      'blur(3.0, 3.0, unspecified)',
    );
  });

  testWidgets('shaped surfaces preserve non-uniform custom borders', (
    tester,
  ) async {
    const surfaceKey = ValueKey('shaped_border_surface');
    const border = Border(
      top: BorderSide(color: Colors.red, width: 1),
      right: BorderSide(color: Colors.green, width: 2),
      bottom: BorderSide(color: Colors.blue, width: 3),
      left: BorderSide(color: Colors.yellow, width: 4),
    );
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehFloatingSurface(
          key: surfaceKey,
          appearance: const SafaehFloatingAppearance(
            style: SafaehFloatingSurfaceStyle.solid,
            border: border,
            blurSigma: 0,
          ),
          fallbackColor: Colors.blueGrey,
          shape: shape,
          child: const SizedBox(width: 160, height: 80),
        ),
      ),
    );

    final decorated = tester.widget<DecoratedBox>(
      _shapeFillDecoration(find.byKey(surfaceKey)),
    );
    final decoration = decorated.decoration as ShapeDecoration;
    expect(decoration.shape.dimensions, border.dimensions);
    expect(
      decoration.shape
          .getOuterPath(const Rect.fromLTWH(0, 0, 160, 80))
          .getBounds(),
      shape.getOuterPath(const Rect.fromLTWH(0, 0, 160, 80)).getBounds(),
    );
  });

  test('appearance validates values and supports copy/equality', () {
    expect(
      () => SafaehFloatingAppearance(transparency: -1),
      throwsAssertionError,
    );
    expect(
      () => SafaehFloatingAppearance(transparency: 101),
      throwsAssertionError,
    );
    expect(
      () => SafaehFloatingAppearance(transparency: double.nan),
      throwsAssertionError,
    );
    expect(() => SafaehFloatingAppearance(blurSigma: -1), throwsAssertionError);
    expect(
      () => SafaehFloatingAppearance(blurSigma: double.infinity),
      throwsAssertionError,
    );

    final shadows = [const BoxShadow(color: Color(0x66000000), blurRadius: 2)];
    final appearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.vista,
      transparency: 12,
      blurSigma: 4,
      tintColor: Colors.amber,
      border: Border.all(color: Colors.white),
      shadows: shadows,
    );
    final equal = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.vista,
      transparency: 12,
      blurSigma: 4,
      tintColor: Colors.amber,
      border: Border.all(color: Colors.white),
      shadows: [const BoxShadow(color: Color(0x66000000), blurRadius: 2)],
    );
    expect(appearance, equal);
    expect(appearance.hashCode, equal.hashCode);

    final copied = appearance.copyWith(
      style: SafaehFloatingSurfaceStyle.glass,
      transparency: 0,
      blurSigma: 7,
    );
    expect(copied.style, SafaehFloatingSurfaceStyle.glass);
    expect(copied.transparency, 0);
    expect(copied.blurSigma, 7);
    expect(copied.tintColor, Colors.amber);
    expect(copied.shadows, shadows);

    final theme = SafaehThemeData(floatingAppearance: appearance);
    expect(theme.copyWith(floatingAppearance: equal), equals(theme));
    expect(
      SafaehRouteOptions(floatingAppearance: appearance).floatingAppearance,
      same(appearance),
    );
  });

  testWidgets('theme, route, and direct appearance precedence is ordered', (
    tester,
  ) async {
    final themeAppearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.glass,
    );
    final routeAppearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.translucent,
      transparency: 61,
    );
    final directAppearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.vista,
      transparency: 9,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehTheme(
          data: SafaehThemeData(floatingAppearance: themeAppearance),
          child: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  TextButton(
                    key: const ValueKey('open-theme'),
                    onPressed: () => showSafaeh<void>(
                      context: context,
                      child: const SizedBox(width: 120, height: 80),
                    ),
                    child: const Text('theme'),
                  ),
                  TextButton(
                    key: const ValueKey('open-route'),
                    onPressed: () => showSafaeh<void>(
                      context: context,
                      child: const SizedBox(width: 120, height: 80),
                      route: SafaehRouteOptions(
                        floatingAppearance: routeAppearance,
                      ),
                    ),
                    child: const Text('route'),
                  ),
                  TextButton(
                    key: const ValueKey('open-direct'),
                    onPressed: () => showSafaeh<void>(
                      context: context,
                      child: const SizedBox(width: 120, height: 80),
                      route: SafaehRouteOptions(
                        floatingAppearance: routeAppearance,
                      ),
                      floatingAppearance: directAppearance,
                    ),
                    child: const Text('direct'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Future<void> openAndExpect(
      String key,
      SafaehFloatingAppearance expected,
    ) async {
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      final surface = tester.widget<SafaehFloatingSurface>(
        find.byType(SafaehFloatingSurface),
      );
      expect(surface.appearance, same(expected));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    await openAndExpect('open-theme', themeAppearance);
    await openAndExpect('open-route', routeAppearance);
    await openAndExpect('open-direct', directAppearance);
  });

  testWidgets('theme and direct values resolve on the floating nav', (
    tester,
  ) async {
    final themeAppearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.translucent,
    );
    final directAppearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.vista,
    );
    const destinations = [
      SafaehSidenavDestination(
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehTheme(
          data: SafaehThemeData(floatingAppearance: themeAppearance),
          child: const Scaffold(
            body: SafaehFloatingNavBar(
              selectedIndex: 0,
              onDestinationSelected: _noopIndex,
              destinations: destinations,
            ),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<SafaehFloatingSurface>(find.byType(SafaehFloatingSurface))
          .appearance,
      same(themeAppearance),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehTheme(
          data: SafaehThemeData(floatingAppearance: themeAppearance),
          child: Scaffold(
            body: SafaehFloatingNavBar(
              selectedIndex: 0,
              onDestinationSelected: _noopIndex,
              destinations: destinations,
              floatingAppearance: directAppearance,
            ),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<SafaehFloatingSurface>(find.byType(SafaehFloatingSurface))
          .appearance,
      same(directAppearance),
    );
  });

  testWidgets('page index overlay styles both its trigger and popover', (
    tester,
  ) async {
    final key = GlobalKey();
    final appearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.glass,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehPageIndexOverlay(
            title: 'On this page',
            entries: [SafaehPageIndexEntry(id: 'one', label: 'One', key: key)],
            activeId: 'one',
            onSelect: (_) {},
            floatingAppearance: appearance,
          ),
        ),
      ),
    );
    expect(find.byType(SafaehFloatingSurface), findsOneWidget);
    await tester.tap(find.text('On this page'));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehFloatingSurface), findsNWidgets(2));
    expect(find.byType(BackdropFilter), findsNWidgets(2));
  });

  testWidgets('dialog, camera panel, and QR top bar style only their shells', (
    tester,
  ) async {
    final appearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.vista,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            key: const ValueKey('open-dialog'),
            onPressed: () => showSafaehDialog<void>(
              context: context,
              floatingAppearance: appearance,
              builder: (context) => const ColoredBox(
                key: ValueKey('dialog-child'),
                color: Colors.purple,
                child: SizedBox(width: 120, height: 80),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open-dialog')));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehFloatingSurface), findsOneWidget);
    expect(find.byKey(const ValueKey('dialog-child')), findsOneWidget);
    expect(
      tester
          .widget<ColoredBox>(find.byKey(const ValueKey('dialog-child')))
          .color,
      Colors.purple,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehCameraSheetHost(
          floatingAppearance: appearance,
          builder: (context, sheet) => const ColoredBox(
            key: ValueKey('camera-child'),
            color: Colors.orange,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SafaehFloatingSurface), findsOneWidget);
    expect(find.byKey(const ValueKey('camera-child')), findsOneWidget);

    final scanLine = const AlwaysStoppedAnimation<double>(0.4);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehQrScannerOverlay(
            floatingAppearance: appearance,
            preview: const ColoredBox(
              key: ValueKey('qr-child'),
              color: Colors.teal,
            ),
            scanLine: scanLine,
            title: const Text('Scan'),
            expanded: false,
            onClose: _noopCallback,
            onToggleExpanded: _noopCallback,
          ),
        ),
      ),
    );
    expect(find.byType(SafaehFloatingSurface), findsOneWidget);
    expect(find.byKey(const ValueKey('qr-child')), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}

void _noopIndex(int _) {}

void _noopCallback() {}

Finder _fillDecoration(Finder surface) {
  return find.descendant(
    of: surface,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color != null,
    ),
  );
}

Finder _shadowDecoration(Finder surface) {
  return find.descendant(
    of: surface,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          ((widget.decoration as BoxDecoration).boxShadow?.isNotEmpty ?? false),
    ),
  );
}

Finder _shapeFillDecoration(Finder surface) {
  return find.descendant(
    of: surface,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is ShapeDecoration &&
          (widget.decoration as ShapeDecoration).color != null,
    ),
  );
}
