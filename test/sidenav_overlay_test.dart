import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
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

class _TooltipLabel extends StatelessWidget {
  const _TooltipLabel(this.data, this.style);

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(data, style: style);
}
