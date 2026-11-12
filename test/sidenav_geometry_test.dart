import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  for (final direction in TextDirection.values) {
    for (final overlay in [false, true]) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets(
          '${overlay ? 'overlay' : 'rail'} keeps ${direction.name} control geometry at $scale text scale',
          (tester) async {
            tester.view.physicalSize = const Size(840, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            var collapsed = false;
            await tester.pumpWidget(
              MaterialApp(
                builder: (context, child) => Directionality(
                  textDirection: direction,
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!,
                  ),
                ),
                home: StatefulBuilder(
                  builder: (context, setState) {
                    final nav = SafaehSidenav(
                      overlay: overlay,
                      title: 'صفائح',
                      collapsed: collapsed,
                      onToggleCompact: () =>
                          setState(() => collapsed = !collapsed),
                      selectedIndex: 0,
                      onDestinationSelected: (_) {},
                      destinations: const [
                        SafaehSidenavDestination(
                          label: 'المجموعات',
                          icon: Icons.group_outlined,
                          selectedIcon: Icons.group,
                        ),
                        SafaehSidenavDestination(
                          label: 'الإعدادات',
                          icon: Icons.settings_outlined,
                          selectedIcon: Icons.settings,
                        ),
                      ],
                      profile: SafaehSidenavProfile(
                        label: 'مستخدم حساب العائلة',
                        subtitle: 'family@example.com',
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {},
                      ),
                      footer: const Text(
                        'v1.0.0',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                    return Scaffold(
                      body: overlay
                          ? Stack(children: [nav])
                          : Row(
                              children: [
                                nav,
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                    );
                  },
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final controls = [
              find.byKey(const ValueKey('safaeh_nav_0')),
              find.byKey(const ValueKey('safaeh_nav_1')),
              find.byKey(const ValueKey('safaeh_nav_profile')),
            ];
            final icons = [
              find.byIcon(Icons.group),
              find.byIcon(Icons.settings_outlined),
              find.byKey(const ValueKey('safaeh_nav_profile_avatar')),
            ];
            final bounds = controls.map(tester.getRect).toList();
            final centers = icons.map(tester.getCenter).toList();
            void verify() {
              expect(tester.takeException(), isNull);
              for (var i = 0; i < controls.length; i++) {
                final actual = tester.getRect(controls[i]);
                expect(
                  actual.top,
                  closeTo(bounds[i].top, 0.01),
                  reason: 'control $i top',
                );
                expect(
                  actual.height,
                  closeTo(bounds[i].height, 0.01),
                  reason: 'control $i height',
                );
                expect(
                  tester.getCenter(icons[i]).dx,
                  closeTo(centers[i].dx, 0.01),
                  reason: 'control $i icon x',
                );
                expect(
                  tester.getCenter(icons[i]).dy,
                  closeTo(centers[i].dy, 0.01),
                  reason: 'control $i icon y',
                );
              }
            }

            for (final key in ['safaeh_nav_collapse', 'safaeh_nav_expand']) {
              await tester.tap(find.byKey(ValueKey(key)));
              await tester.pump();
              verify();
              for (var frame = 0; frame < 8; frame++) {
                await tester.pump(const Duration(milliseconds: 35));
                verify();
              }
              await tester.pumpAndSettle();
              verify();
            }
          },
        );
      }
    }
  }
}
