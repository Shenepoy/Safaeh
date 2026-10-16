import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh/src/floating_surface_renderer.dart';

void main() {
  testWidgets(
    'interior camera stays inside the surface and clear of every button',
    (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const camera = Rect.fromLTWH(18, 172, 32, 32);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafaehSidenav(
              overlay: true,
              collapsed: true,
              compactWidth: 64,
              onToggleCompact: _noop,
              title: 'Janan',
              selectedIndex: 2,
              onDestinationSelected: _noopIndex,
              cutouts: const [SafaehSidenavCutout(bounds: camera)],
              destinations: const [
                SafaehSidenavDestination(
                  label: 'Measurements',
                  icon: Icons.monitor_heart_outlined,
                  selectedIcon: Icons.monitor_heart,
                ),
                SafaehSidenavDestination(
                  label: 'Statistics',
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights,
                ),
                SafaehSidenavDestination(
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        final target = tester.getRect(find.byKey(ValueKey('safaeh_nav_$i')));
        expect(
          target.overlaps(camera.inflate(8)),
          isFalse,
          reason: 'button $i must clear the real camera',
        );
      }
      for (var i = 0; i < 3; i++) {
        final target = tester.getRect(find.byKey(ValueKey('safaeh_nav_$i')));
        expect(target.width, greaterThanOrEqualTo(48));
        expect(target.height, greaterThanOrEqualTo(48));
      }
      expect(
        tester.getSize(find.byKey(const ValueKey('safaeh_nav_rail'))).width,
        64,
      );
    },
  );

  testWidgets(
    'deep side notch curves the panel and moves only colliding rows',
    (tester) async {
      const camera = Rect.fromLTWH(0, 170, 112, 84);
      await _pumpCameraRail(
        tester,
        cutouts: const [SafaehSidenavCutout(bounds: camera)],
      );
      final rail = find.byKey(const ValueKey('safaeh_nav_rail'));
      expect(tester.getSize(rail).width, 120);
      final surface = tester.widget<SafaehFloatingSurface>(
        find.byType(SafaehFloatingSurface),
      );
      final outline = surface.shape!.getOuterPath(
        const Rect.fromLTWH(0, 0, 120, 400),
      );
      expect(outline.contains(const Offset(116, 200)), isTrue);
      expect(outline.contains(const Offset(100, 80)), isFalse);
      expect(
        tester.getCenter(find.byKey(const ValueKey('safaeh_nav_0'))).dx,
        32,
      );
      for (var i = 0; i < 3; i++) {
        expect(
          tester
              .getRect(find.byKey(ValueKey('safaeh_nav_$i')))
              .overlaps(camera.inflate(8)),
          isFalse,
        );
      }
    },
  );

  testWidgets('native empty geometry overrides stale Flutter cutouts', (
    tester,
  ) async {
    await _pumpCameraRail(
      tester,
      cutouts: const [],
      fallbackCamera: const Rect.fromLTWH(0, 170, 112, 84),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('safaeh_nav_rail'))).width,
      64,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('safaeh_nav_2'))).dy,
      lessThan(200),
    );
  });

  testWidgets(
    'RTL camera keeps the rail against the right edge and buttons clear',
    (tester) async {
      const camera = Rect.fromLTWH(750, 172, 32, 32);
      await _pumpCameraRail(
        tester,
        cutouts: const [SafaehSidenavCutout(bounds: camera)],
        rtl: true,
      );
      expect(
        tester.getBottomRight(find.byKey(const ValueKey('safaeh_nav_rail'))).dx,
        800,
      );
      for (var i = 0; i < 3; i++) {
        final target = tester.getRect(find.byKey(ValueKey('safaeh_nav_$i')));
        expect(target.overlaps(camera.inflate(8)), isFalse);
        expect(target.center.dx, 768);
      }
    },
  );

  testWidgets(
    'short landscape can scroll the last button above a tall camera',
    (tester) async {
      var selected = -1;
      await _pumpCameraRail(
        tester,
        height: 300,
        cutouts: const [
          SafaehSidenavCutout(bounds: Rect.fromLTWH(0, 90, 84, 180)),
        ],
        onSelected: (index) => selected = index,
      );
      final settings = find.byKey(const ValueKey('safaeh_nav_2'));
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      scroll.position.jumpTo(tester.getRect(settings).top - 16);
      await tester.pumpAndSettle();
      expect(tester.getRect(settings).top, closeTo(16, 0.01));
      await tester.tap(settings);
      expect(selected, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('overlay sidenav preserves host space and uses its surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const hostKey = ValueKey('overlay_nav_host');
    const navKey = ValueKey('overlay_nav');
    final appearance = SafaehFloatingAppearance(
      style: SafaehFloatingSurfaceStyle.glass,
    );
    var collapsed = true;

    await tester.pumpWidget(
      MaterialApp(
        home: SafaehTheme(
          data: SafaehThemeData(floatingAppearance: appearance),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  const SizedBox.expand(
                    key: hostKey,
                    child: ColoredBox(color: Colors.blue),
                  ),
                  SafaehSidenav(
                    overlay: true,
                    collapsed: collapsed,
                    railKey: navKey,
                    onToggleCompact: () =>
                        setState(() => collapsed = !collapsed),
                    title: 'Safaeh',
                    selectedIndex: 0,
                    onDestinationSelected: (_) {},
                    destinations: const [
                      SafaehSidenavDestination(
                        label: 'Groups',
                        icon: Icons.group_outlined,
                        selectedIcon: Icons.group,
                      ),
                    ],
                    profile: SafaehSidenavProfile(
                      label: 'Ada Lovelace',
                      subtitle: 'ada@example.com',
                      onTap: _noop,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(tester.getSize(find.byKey(hostKey)).width, 800);
    expect(tester.getSize(find.byKey(navKey)).width, 72);
    final collapsedDestinationHeight = tester
        .getSize(find.byKey(const ValueKey('safaeh_nav_0')))
        .height;
    final collapsedProfileHeight = tester
        .getSize(find.byKey(const ValueKey('safaeh_nav_profile')))
        .height;

    await tester.tap(find.byKey(const ValueKey('safaeh_nav_expand')));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(hostKey)).width, 800);
    expect(tester.getSize(find.byKey(navKey)).width, 240);
    expect(
      tester.getSize(find.byKey(const ValueKey('safaeh_nav_0'))).height,
      closeTo(collapsedDestinationHeight, 0.01),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('safaeh_nav_profile'))).height,
      closeTo(collapsedProfileHeight, 0.01),
    );
    expect(find.text('Groups'), findsOneWidget);
  });
  testWidgets('sidenav profile keeps its vertical position while resizing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var collapsed = true;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Row(
                children: [
                  SafaehSidenav(
                    collapsed: collapsed,
                    onToggleCompact: () =>
                        setState(() => collapsed = !collapsed),
                    title: 'Hisab',
                    selectedIndex: 0,
                    onDestinationSelected: (_) {},
                    destinations: const [
                      SafaehSidenavDestination(
                        label: 'Groups',
                        icon: Icons.group_outlined,
                        selectedIcon: Icons.group,
                      ),
                    ],
                    profile: const SafaehSidenavProfile(
                      label: 'Sign In',
                      subtitle: 'Sign In',
                      onTap: _noop,
                    ),
                    footer: const Text('v0.7.25'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    final avatar = find.byKey(const ValueKey('safaeh_nav_profile_avatar'));
    final collapsedY = tester.getCenter(avatar).dy;

    await tester.tap(find.byKey(const ValueKey('safaeh_nav_expand')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getCenter(avatar).dy, closeTo(collapsedY, 0.01));
    await tester.pumpAndSettle();
    expect(tester.getCenter(avatar).dy, closeTo(collapsedY, 0.01));

    await tester.tap(find.byKey(const ValueKey('safaeh_nav_collapse')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getCenter(avatar).dy, closeTo(collapsedY, 0.01));
    await tester.pumpAndSettle();
    expect(tester.getCenter(avatar).dy, closeTo(collapsedY, 0.01));
  });

  testWidgets(
    'sidenav keeps a compact custom profile avatar anchored while resizing',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var collapsed = true;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Row(
                  children: [
                    SafaehSidenav(
                      collapsed: collapsed,
                      onToggleCompact: () =>
                          setState(() => collapsed = !collapsed),
                      title: 'Hisab',
                      selectedIndex: 0,
                      onDestinationSelected: (_) {},
                      destinations: const [
                        SafaehSidenavDestination(
                          label: 'Groups',
                          icon: Icons.group_outlined,
                          selectedIcon: Icons.group,
                        ),
                      ],
                      profile: const SafaehSidenavProfile(
                        label: 'Sign In',
                        subtitle: 'Sign In',
                        leading: SizedBox.square(
                          key: ValueKey('compact_profile_avatar'),
                          dimension: 24,
                          child: ColoredBox(color: Colors.grey),
                        ),
                        onTap: _noop,
                      ),
                      footer: const Text('v0.7.25'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      final avatar = find.byKey(const ValueKey('compact_profile_avatar'));
      final collapsedCenter = tester.getCenter(avatar);

      await tester.tap(find.byKey(const ValueKey('safaeh_nav_expand')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getCenter(avatar).dx, closeTo(collapsedCenter.dx, 0.01));
      expect(tester.getCenter(avatar).dy, closeTo(collapsedCenter.dy, 0.01));
      await tester.pumpAndSettle();
      expect(tester.getCenter(avatar).dx, closeTo(collapsedCenter.dx, 0.01));
      expect(tester.getCenter(avatar).dy, closeTo(collapsedCenter.dy, 0.01));

      await tester.tap(find.byKey(const ValueKey('safaeh_nav_collapse')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getCenter(avatar).dx, closeTo(collapsedCenter.dx, 0.01));
      expect(tester.getCenter(avatar).dy, closeTo(collapsedCenter.dy, 0.01));
      await tester.pumpAndSettle();
      expect(tester.getCenter(avatar).dx, closeTo(collapsedCenter.dx, 0.01));
      expect(tester.getCenter(avatar).dy, closeTo(collapsedCenter.dy, 0.01));
    },
  );

  testWidgets('collapsed profile uses the same plain tooltip as destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SafaehSidenav(
          collapsed: true,
          onToggleCompact: _noop,
          title: 'Hisab',
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            SafaehSidenavDestination(
              label: 'Settings',
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              tileKey: ValueKey('tooltip_destination'),
            ),
          ],
          profile: SafaehSidenavProfile(
            tileKey: const ValueKey('tooltip_profile'),
            label: 'Sign In',
            subtitle: 'Sign In',
            labelBuilder: (data, style) => _TooltipLabel(data, style),
            onTap: _noop,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final profileTooltip = tester.widget<Tooltip>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('tooltip_profile')),
            matching: find.byType(Tooltip),
          )
          .first,
    );
    final destinationTooltip = tester.widget<Tooltip>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('tooltip_destination')),
            matching: find.byType(Tooltip),
          )
          .first,
    );

    expect(profileTooltip.message, 'Sign In');
    expect(destinationTooltip.message, 'Settings');
    expect(profileTooltip.richMessage, isNull);
    expect(destinationTooltip.richMessage, isNull);
  });
}

void _noop() {}

void _noopIndex(int _) {}

class _TooltipLabel extends StatelessWidget {
  const _TooltipLabel(this.data, this.style);

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(data, style: style);
}

Future<void> _pumpCameraRail(
  WidgetTester tester, {
  required List<SafaehSidenavCutout> cutouts,
  Rect? fallbackCamera,
  bool rtl = false,
  double height = 400,
  ValueChanged<int>? onSelected,
}) async {
  tester.view.physicalSize = Size(800, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(800, height),
            displayFeatures: [
              if (fallbackCamera != null)
                ui.DisplayFeature(
                  bounds: fallbackCamera,
                  type: ui.DisplayFeatureType.cutout,
                  state: ui.DisplayFeatureState.unknown,
                ),
            ],
          ),
          child: Scaffold(
            body: SafaehSidenav(
              title: 'Janan',
              overlay: true,
              collapsed: true,
              compactWidth: 64,
              onToggleCompact: _noop,
              selectedIndex: 2,
              onDestinationSelected: onSelected ?? _noopIndex,
              cutouts: cutouts,
              destinations: const [
                SafaehSidenavDestination(
                  label: 'Measurements',
                  icon: Icons.monitor_heart_outlined,
                  selectedIcon: Icons.monitor_heart,
                ),
                SafaehSidenavDestination(
                  label: 'Statistics',
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights,
                ),
                SafaehSidenavDestination(
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
