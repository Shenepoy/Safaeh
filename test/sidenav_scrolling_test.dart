import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  for (final drawer in [false, true]) {
    testWidgets(
      'long ${drawer ? 'drawer' : 'rail'} scrolls with a fixed profile',
      (tester) async {
        tester.view.physicalSize = const Size(840, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var selected = 0;
        var collapsed = false;
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.5)),
                child: child!,
              ),
            ),
            home: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                body: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    width: drawer ? 280 : null,
                    child: SafaehSidenav(
                      asDrawer: drawer,
                      title: 'Navigation',
                      collapsed: collapsed,
                      onToggleCompact: () =>
                          setState(() => collapsed = !collapsed),
                      selectedIndex: selected,
                      onDestinationSelected: (value) =>
                          setState(() => selected = value),
                      destinations: [
                        for (var i = 0; i < 20; i++)
                          SafaehSidenavDestination(
                            label: 'Item $i',
                            icon: Icons.folder_outlined,
                            selectedIcon: Icons.folder,
                          ),
                      ],
                      profile: SafaehSidenavProfile(
                        label: 'Profile',
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final profile = find.byKey(const ValueKey('safaeh_nav_profile'));
        final profileTop = tester.getTopLeft(profile).dy;
        final navScroll = find
            .descendant(
              of: find.byType(SafaehSidenav),
              matching: find.byType(Scrollable),
            )
            .first;
        final last = find.byKey(const ValueKey('safaeh_nav_19'));
        await tester.scrollUntilVisible(last, 250, scrollable: navScroll);
        await tester.tap(last);
        await tester.pumpAndSettle();
        expect(selected, 19);
        expect(tester.getTopLeft(profile).dy, profileTop);
        if (!drawer) {
          final offset = tester
              .state<ScrollableState>(navScroll)
              .position
              .pixels;
          await tester.tap(find.byKey(const ValueKey('safaeh_nav_collapse')));
          await tester.pumpAndSettle();
          expect(
            tester.state<ScrollableState>(navScroll).position.pixels,
            offset,
          );
          expect(tester.getTopLeft(profile).dy, profileTop);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
