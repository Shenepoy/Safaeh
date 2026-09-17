import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  Future<void> setPhone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> setTablet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('showSafaeh is a phone sheet that morphs into a tablet dialog', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              child: const Padding(
                padding: kSheetContentPadding,
                child: Text('sheet-body'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_drag_handle')), findsOneWidget);
    final handle = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const ValueKey('safaeh_drag_handle')),
        matching: find.byType(Container),
      ),
    );
    final handleColor = (handle.decoration! as BoxDecoration).color!;
    expect(handleColor.a, equals(1.0));
    expect(find.byIcon(Icons.close), findsNothing);

    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_drag_handle')), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Rename'), findsOneWidget);
  });

  testWidgets('tile picker header and disabled option stay put', (
    tester,
  ) async {
    await setPhone(tester);
    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              value = await showSafaehTilePicker<String>(
                context: context,
                title: 'Choose account',
                selected: 'cash',
                header: const Text('Custom header'),
                options: const [
                  SafaehTileOption(value: 'cash', label: 'Cash'),
                  SafaehTileOption(
                    value: 'offline',
                    label: 'Offline',
                    enabled: false,
                  ),
                ],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Choose account'), findsWidgets);
    expect(find.text('Custom header'), findsOneWidget);

    await tester.tap(find.text('Offline'));
    await tester.pump();
    expect(value, isNull);
    expect(find.text('Offline'), findsOneWidget);

    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    expect(value, 'cash');
  });

  testWidgets('buildSafaehSheetShell shows in-body title and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildSafaehSheetShell(
            title: const Text('Shell title'),
            body: const Text('Shell body'),
            actions: [
              TextButton(onPressed: () {}, child: const Text('Cancel')),
              FilledButton(onPressed: () {}, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Shell title'), findsOneWidget);
    expect(find.text('Shell body'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('confirm tablet uses close chrome instead of cancel', (
    tester,
  ) async {
    await setTablet(tester);
    bool? result = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showSafaehConfirm(
                context: context,
                title: 'Delete?',
                content: 'Gone forever',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_cancel')), findsNothing);
    expect(find.byKey(const ValueKey('safaeh_confirm')), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('confirm barrierDismissible false keeps the sheet', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehConfirm(
              context: context,
              title: 'Delete?',
              content: 'Gone forever',
              confirmLabel: 'Delete',
              barrierDismissible: false,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_confirm')), findsOneWidget);
  });

  testWidgets('safaehTitleFromLabel wraps a label builder', (tester) async {
    await setTablet(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              titleBuilder: safaehTitleFromLabel(
                'Rename',
                (data, style) => Text('built-$data', style: style),
              ),
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('built-Rename'), findsOneWidget);
  });

  testWidgets('confirm dismissReturnsFalse pops false on tablet close', (
    tester,
  ) async {
    await setTablet(tester);
    bool? result = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showSafaehConfirm(
                context: context,
                title: 'Delete?',
                content: 'Gone forever',
                confirmLabel: 'Delete',
                dismissReturnsFalse: true,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('confirm dismissReturnsFalse pops false on system back', (
    tester,
  ) async {
    await setPhone(tester);
    bool? result = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showSafaehConfirm(
                context: context,
                title: 'Delete?',
                content: 'Gone forever',
                confirmLabel: 'Delete',
                dismissReturnsFalse: true,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('phone drag handle exposes dismiss semantics', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final handle = tester.getSemantics(
      find.byKey(const ValueKey('safaeh_drag_handle')),
    );
    expect(
      handle,
      matchesSemantics(label: 'Dismiss', isButton: true, hasTapAction: true),
    );
    tester.semantics.tap(
      find.semantics.byPredicate((node) => node.id == handle.id),
    );
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsNothing);
  });

  testWidgets('phone drag handle uses host dismissLabel', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              dismissLabel: 'Close sheet',
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('safaeh_drag_handle'))),
      matchesSemantics(
        label: 'Close sheet',
        isButton: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('text input cancel pops null', (tester) async {
    await setPhone(tester);
    Object? value = 'pending';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              value = await showSafaehTextInput(
                context: context,
                title: 'Tag',
                doneLabel: 'Done',
                cancelLabel: 'Cancel',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('safaeh_cancel')));
    await tester.pumpAndSettle();
    expect(value, isNull);
  });

  testWidgets('picker disabled option does not pop', (tester) async {
    await setPhone(tester);
    int? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              value = await showSafaehPicker<int>(
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
                  SafaehOption(
                    value: 2,
                    label: 'Locked',
                    subtitle: 'Unavailable',
                    icon: Icons.lock_outline,
                    enabled: false,
                  ),
                ],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Locked'));
    await tester.pump();
    expect(value, isNull);
    expect(find.text('Locked'), findsOneWidget);
  });

  testWidgets('card picker pops the root navigator', (tester) async {
    await setPhone(tester);
    int? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('inner-home'),
                      Builder(
                        builder: (context) => TextButton(
                          onPressed: () async {
                            value = await showSafaehPicker<int>(
                              context: context,
                              title: 'How to settle',
                              selected: 1,
                              options: const [
                                SafaehOption(
                                  value: 2,
                                  label: 'Pairs',
                                  subtitle: 'Per pair',
                                  icon: Icons.people_outline,
                                ),
                              ],
                            );
                          },
                          child: const Text('open'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pairs'));
    await tester.pumpAndSettle();
    expect(value, 2);
    expect(find.text('inner-home'), findsOneWidget);
    expect(find.text('Pairs'), findsNothing);
  });

  testWidgets('tile picker pops the root navigator', (tester) async {
    await setPhone(tester);
    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('inner-home'),
                      Builder(
                        builder: (context) => TextButton(
                          onPressed: () async {
                            value = await showSafaehTilePicker<String>(
                              context: context,
                              title: 'Choose account',
                              selected: 'cash',
                              options: const [
                                SafaehTileOption(value: 'card', label: 'Card'),
                              ],
                            );
                          },
                          child: const Text('open'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();
    expect(value, 'card');
    expect(find.text('inner-home'), findsOneWidget);
    expect(find.text('Card'), findsNothing);
  });

  testWidgets('sidenav drawer shows labels and has no expand chevron', (
    tester,
  ) async {
    var index = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SafaehSidenav(
                asDrawer: true,
                title: 'Safaeh',
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                destinations: const [
                  SafaehSidenavDestination(
                    label: 'Groups',
                    icon: Icons.group_outlined,
                    selectedIcon: Icons.group,
                  ),
                  SafaehSidenavDestination(
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                  ),
                ],
                profile: SafaehSidenavProfile(
                  label: 'Ada Lovelace',
                  onTap: _noop,
                ),
                footer: const Text('v0.1.0'),
              ),
            );
          },
        ),
      ),
    );

    expect(find.byKey(const ValueKey('safaeh_nav_expand')), findsNothing);
    expect(find.byKey(const ValueKey('safaeh_nav_rail')), findsNothing);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('v0.1.0'), findsOneWidget);
    final groupX = tester.getCenter(find.byIcon(Icons.group)).dx;
    final avatarX = tester
        .getCenter(find.byKey(const ValueKey('safaeh_nav_profile_avatar')))
        .dx;
    expect(groupX, closeTo(avatarX, 0.01));
    final titleLeft = tester.getRect(find.text('Safaeh')).left;
    expect(
      tester.getRect(find.text('Groups')).left,
      closeTo(titleLeft - 4, 0.01),
    );
    expect(tester.getRect(find.text('v0.1.0')).left, closeTo(titleLeft, 0.01));

    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(index, 1);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('phone confirm body ignores status-bar SafeArea', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: const EdgeInsets.only(top: 47)),
            child: child!,
          );
        },
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehConfirm(
              context: context,
              title: 'Delete?',
              content: 'Gone forever',
              confirmLabel: 'Delete',
              cancelLabel: 'Cancel',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final panelTop = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_panel')))
        .dy;
    final titleTop = tester.getTopLeft(find.text('Delete?')).dy;
    expect(titleTop - panelTop, lessThan(60));
  });

  testWidgets('confirm, text, and tile bodies ignore status-bar inset', (
    tester,
  ) async {
    await setPhone(tester);
    const confirmKey = ValueKey('confirm-body');
    const textKey = ValueKey('text-body');
    const tileKey = ValueKey('tile-body');

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: const EdgeInsets.only(top: 47)),
            child: child!,
          );
        },
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                KeyedSubtree(
                  key: confirmKey,
                  child: SafaehConfirmSheet(
                    title: 'Delete?',
                    content: 'Gone forever',
                    confirmLabel: 'Delete',
                    cancelLabel: 'Cancel',
                  ),
                ),
                KeyedSubtree(
                  key: textKey,
                  child: SafaehTextInputSheet(
                    title: 'Tag',
                    doneLabel: 'Done',
                    cancelLabel: 'Cancel',
                  ),
                ),
                KeyedSubtree(
                  key: tileKey,
                  child: SafaehTilePickerBody<String>(
                    title: 'Choose',
                    tabletBreakpoint: 10000,
                    options: [SafaehTileOption(value: 'a', label: 'Alpha')],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    void expectNoStatusBarInset(Key host, Finder title) {
      final hostTop = tester.getTopLeft(find.byKey(host)).dy;
      final titleTop = tester.getTopLeft(title).dy;
      expect(
        titleTop - hostTop,
        lessThan(40),
        reason: '$title must not pick up MediaQuery.padding.top (47)',
      );
    }

    expectNoStatusBarInset(confirmKey, find.text('Delete?'));
    expectNoStatusBarInset(textKey, find.text('Tag'));
    expectNoStatusBarInset(tileKey, find.text('Choose'));
  });

  testWidgets('tile picker can paint its title in the Safaeh phone chrome', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehTilePicker<String>(
              context: context,
              title: 'Choose account',
              showTitleInBody: false,
              options: const [SafaehTileOption(value: 'cash', label: 'Cash')],
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final panelTop = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_panel')))
        .dy;
    final titleTop = tester.getTopLeft(find.text('Choose account')).dy;
    expect(find.text('Choose account'), findsOneWidget);
    expect(titleTop - panelTop, lessThan(32));
  });

  testWidgets('railWidthOf does not shift the tablet dialog off-center', (
    tester,
  ) async {
    await setTablet(tester);
    late double withoutRail;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              railWidthOf: (_) => 80,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final withRail = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_panel')))
        .dx;
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              railWidthOf: (_) => 0,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    withoutRail = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_panel')))
        .dx;
    expect(withRail, closeTo(withoutRail, 1));
    final panel = tester.getRect(find.byKey(const ValueKey('safaeh_panel')));
    expect(panel.center.dx, closeTo(tester.view.physicalSize.width / 2, 1));
  });

  testWidgets('opening a host rail later does not move an open tablet sheet', (
    tester,
  ) async {
    await setTablet(tester);
    final rail = ValueNotifier<double>(0);
    addTearDown(rail.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              railWidthOf: (_) => rail.value,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final before = tester.getRect(find.byKey(const ValueKey('safaeh_panel')));
    rail.value = 240;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getRect(find.byKey(const ValueKey('safaeh_panel'))), before);
  });

  testWidgets(
    'SafaehRouteOptions railWidthOf does not shift the tablet dialog',
    (tester) async {
      await setTablet(tester);
      Future<double> openWithRail(double rail) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSafaeh<void>(
                  context: context,
                  title: 'Rename',
                  route: SafaehRouteOptions(railWidthOf: (_) => rail),
                  child: const Text('sheet-body'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        return tester.getTopLeft(find.byKey(const ValueKey('safaeh_panel'))).dx;
      }

      final withRail = await openWithRail(80);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      final withoutRail = await openWithRail(0);
      expect(withRail, closeTo(withoutRail, 1));
    },
  );

  testWidgets('showSafaehDialog railWidthOf does not shift the panel', (
    tester,
  ) async {
    await setTablet(tester);
    Future<double> openWithRail(double rail) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehDialog<void>(
                context: context,
                railWidthOf: (_) => rail,
                builder: (ctx) => const Material(
                  child: SizedBox(
                    width: 200,
                    height: 120,
                    child: Center(child: Text('dialog-body')),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return tester.getTopLeft(find.text('dialog-body')).dx;
    }

    final withRail = await openWithRail(80);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    final withoutRail = await openWithRail(0);
    expect(withRail, closeTo(withoutRail, 1));
  });

  testWidgets('tabletTopBarAction is shown next to close', (tester) async {
    await setTablet(tester);
    final extraFocus = FocusNode();
    addTearDown(extraFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              tabletTopBarAction: TextButton(
                focusNode: extraFocus,
                onPressed: () {},
                child: const Text('extra-action'),
              ),
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('extra-action'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    final close = tester.widget<InkWell>(
      find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(InkWell),
      ),
    );
    expect(close.canRequestFocus, isTrue);
    extraFocus.requestFocus();
    await tester.pump();
    expect(extraFocus.hasFocus, isTrue);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close))
          .tooltip,
      'Close',
    );
    expect(
      tester.getSemantics(find.byIcon(Icons.close)),
      isSemantics(isButton: true, isEnabled: true),
    );
  });

  testWidgets('barrierDismissible false keeps the sheet on scrim tap', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              barrierDismissible: false,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsOneWidget);
  });

  testWidgets('showSafaeh system back dismisses when allowed', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsNothing);
  });

  testWidgets('barrierDismissible false keeps the sheet on system back', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              barrierDismissible: false,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsOneWidget);
  });

  testWidgets('barrierDismissible false keeps the sheet on handle dismiss', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              barrierDismissible: false,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('safaeh_drag_handle'))),
      matchesSemantics(hasTapAction: false),
    );
    expect(find.text('sheet-body'), findsOneWidget);
  });

  testWidgets('showSafaehDialog fadeScale false still shows the child', (
    tester,
  ) async {
    await setTablet(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehDialog<void>(
              context: context,
              fadeScale: false,
              builder: (ctx) => const Material(
                child: SizedBox(
                  width: 200,
                  height: 120,
                  child: Center(child: Text('dialog-body')),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('dialog-body'), findsOneWidget);
  });

  testWidgets('showSafaehDialog RouteOptions clamp maxWidth and maxHeight', (
    tester,
  ) async {
    await setTablet(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehDialog<void>(
              context: context,
              route: const SafaehRouteOptions(maxWidth: 120, maxHeight: 80),
              builder: (ctx) => const Material(
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: Center(child: Text('dialog-body')),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final box = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('safaeh_dialog_constraints')),
    );
    expect(box.size.width, lessThanOrEqualTo(120));
    expect(box.size.height, lessThanOrEqualTo(80));
  });

  testWidgets('useRootNavigator false pops the nested navigator', (
    tester,
  ) async {
    await setPhone(tester);
    final innerKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            const Text('root-shell'),
            Expanded(
              child: Navigator(
                key: innerKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute<void>(
                    settings: settings,
                    builder: (context) {
                      return Scaffold(
                        body: Column(
                          children: [
                            const Text('inner-home'),
                            Builder(
                              builder: (context) => TextButton(
                                onPressed: () => showSafaeh<void>(
                                  context: context,
                                  title: 'Rename',
                                  useRootNavigator: false,
                                  child: const Text('sheet-body'),
                                ),
                                child: const Text('open'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    expect(innerKey.currentState!.canPop(), isFalse);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsOneWidget);
    expect(find.text('root-shell'), findsOneWidget);
    expect(innerKey.currentState!.canPop(), isTrue);

    innerKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsNothing);
    expect(find.text('inner-home'), findsOneWidget);
    expect(find.text('root-shell'), findsOneWidget);
    expect(innerKey.currentState!.canPop(), isFalse);
  });

  testWidgets('fadeScale override still shows a tablet dialog', (tester) async {
    await setTablet(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              fadeScale: safaehFade,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_drag_handle')), findsNothing);
  });

  testWidgets(
    'railWidthOf in RTL still keeps the tablet dialog viewport-centered',
    (tester) async {
      await setTablet(tester);
      Future<double> openWithRail(double rail) async {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSafaeh<void>(
                  context: context,
                  title: 'Rename',
                  railWidthOf: (_) => rail,
                  child: const Text('sheet-body'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        return tester.getTopLeft(find.byKey(const ValueKey('safaeh_panel'))).dx;
      }

      final withRail = await openWithRail(80);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      final withoutRail = await openWithRail(0);
      expect(withRail, closeTo(withoutRail, 1));
    },
  );

  testWidgets('phone sheet lists scroll; handle drag dismisses', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rows',
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var i = 0; i < 20; i++)
                    SizedBox(height: 48, child: Text('row-$i')),
                ],
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);

    await tester.drag(find.text('row-3'), const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);

    // Reverse partway without reaching the scrollable's start; a downward
    // drag at the start edge is covered by the sheet-dismiss test below.
    await tester.drag(find.text('row-5'), const Offset(0, 48));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('safaeh_drag_handle')),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsNothing);
  });

  testWidgets('phone sheet needs a longer handle pull to dismiss', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rows',
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final panel = find.byKey(const ValueKey('safaeh_panel'));
    final handle = find.byKey(const ValueKey('safaeh_drag_handle'));

    await tester.drag(handle, const Offset(0, 110));
    await tester.pumpAndSettle();
    expect(panel, findsOneWidget);

    await tester.drag(handle, const Offset(0, 220));
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
  });

  testWidgets('phone sheet dismissal distance scales with modal height', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Tall sheet',
              child: const SizedBox(height: 600),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final panel = find.byKey(const ValueKey('safaeh_panel'));
    final handle = find.byKey(const ValueKey('safaeh_drag_handle'));

    await tester.drag(handle, const Offset(0, 180));
    await tester.pumpAndSettle();
    expect(panel, findsOneWidget);

    await tester.drag(handle, const Offset(0, 240));
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
  });

  testWidgets('phone sheet disables the material overscroll indicator', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rows',
              child: SizedBox(
                height: 320,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < 20; i++)
                        SizedBox(height: 48, child: Text('probe-row-$i')),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expect(find.byType(GlowingOverscrollIndicator), findsNothing);
  });

  testWidgets('phone sheet paints through the bottom safe-area inset', (
    tester,
  ) async {
    await setPhone(tester);
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Choose',
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final panel = find.byKey(const ValueKey('safaeh_panel'));
    expect(tester.getBottomLeft(panel).dy, closeTo(800, 1));
  });

  testWidgets(
    'phone sheet dismisses when a scrollable reaches its top and is dragged down',
    (tester) async {
      await setPhone(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaeh<void>(
                context: context,
                title: 'Rows',
                child: SizedBox(
                  height: 320,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0; i < 20; i++)
                          SizedBox(height: 48, child: Text('drag-row-$i')),
                      ],
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final panel = find.byKey(const ValueKey('safaeh_panel'));
      final restingBottom = tester.getBottomLeft(panel).dy;

      await tester.drag(find.text('drag-row-2'), const Offset(0, 48));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);
      expect(tester.getBottomLeft(panel).dy, closeTo(restingBottom, 1));

      await tester.drag(find.text('drag-row-2'), const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);

      // The same gesture pattern users make after reaching the list's start:
      // the content gives the pull to the sheet and the threshold dismisses.
      await tester.drag(find.text('drag-row-2'), const Offset(0, 360));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('safaeh_panel')), findsNothing);
    },
  );

  testWidgets('phone sheet accepts a fast content fling at the top', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rows',
              child: SizedBox(
                height: 320,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < 20; i++)
                        SizedBox(height: 48, child: Text('fling-row-$i')),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);

    await tester.fling(find.text('fling-row-2'), const Offset(0, 220), 1200);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsNothing);
  });

  testWidgets('short picker sheet can be pulled down from its content', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehTilePicker<String>(
              context: context,
              title: 'Language',
              selected: 'en',
              options: const [
                SafaehTileOption(value: 'en', label: 'English'),
                SafaehTileOption(value: 'ar', label: 'Arabic'),
              ],
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);

    await tester.drag(find.text('Arabic'), const Offset(0, 220));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsNothing);
  });

  testWidgets('sheet actions remain keyboard-focusable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildSafaehSheetShell(
            title: const Text('Shell title'),
            body: const Text('Shell body'),
            actions: [
              TextButton(onPressed: () {}, child: const Text('Cancel')),
              FilledButton(onPressed: () {}, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );

    final node = Focus.maybeOf(tester.element(find.text('Save')));
    expect(node, isNotNull);
    expect(node!.canRequestFocus, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehConfirmSheet(
            title: 'Delete?',
            content: 'Gone forever',
            confirmLabel: 'Delete',
            cancelLabel: 'Cancel',
          ),
        ),
      ),
    );
    final ink = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('safaeh_confirm')),
        matching: find.byType(InkWell),
      ),
    );
    expect(ink.canRequestFocus, isTrue);
  });

  testWidgets('phone showSafaeh slides the panel up from below', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              child: const Padding(
                padding: kSheetContentPadding,
                child: Text('sheet-body'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    final startTop = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_panel')))
        .dy;
    expect(startTop, greaterThan(400));

    await tester.pump(const Duration(milliseconds: 80));
    final midTop = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_panel')))
        .dy;
    expect(midTop, lessThan(startTop));

    await tester.pumpAndSettle();
    final endTop = tester
        .getTopLeft(find.byKey(const ValueKey('safaeh_panel')))
        .dy;
    expect(endTop, lessThan(midTop));
    expect(find.text('sheet-body'), findsOneWidget);
  });

  test('center sheet top lines up first-content center to phone center', () {
    const viewport = 800.0;
    const handle = 24.0;
    const first = 48.0;
    final top = safaehPhoneCenterSheetTop(
      viewportHeight: viewport,
      handleHeight: handle,
      firstContentHeight: first,
    );
    expect(top, closeTo(400 - handle - first / 2, 0.01));
    expect(
      safaehPhoneCenterSheetHeight(viewportHeight: viewport, sheetTop: top),
      closeTo(viewport - top, 0.01),
    );
    expect(
      safaehPhoneCenterSheetTop(
        viewportHeight: viewport,
        handleHeight: handle,
        firstContentHeight: 2000,
      ),
      closeTo(kSafaehPhoneCenterMinTopInset, 0.01),
    );
  });

  testWidgets('phone center placement stays docked and grows upward', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              phonePlacement: SafaehPhoneSheetPlacement.center,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_drag_handle')), findsOneWidget);
    final panel = tester.getRect(find.byKey(const ValueKey('safaeh_panel')));
    expect(panel.bottom, closeTo(800, 2));
    expect(panel.height, greaterThan(400));
    final first = tester.getRect(find.text('sheet-body'));
    expect(first.center.dy, closeTo(400, 16));
  });

  testWidgets('phone center placement remasures when the viewport grows', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              phonePlacement: SafaehPhoneSheetPlacement.center,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final short = tester.getRect(find.byKey(const ValueKey('safaeh_panel')));
    expect(short.bottom, closeTo(800, 2));

    tester.view.physicalSize = const Size(400, 1200);
    await tester.pumpAndSettle();
    final tall = tester.getRect(find.byKey(const ValueKey('safaeh_panel')));
    expect(tall.bottom, closeTo(1200, 2));
    expect(tall.height, greaterThan(short.height));
    expect(tester.getRect(find.text('sheet-body')).center.dy, closeTo(600, 16));
  });

  testWidgets('raw showSafaeh paints the title on phone', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('safaeh_panel')),
        matching: find.text('Rename'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('enableDrag without a handle still dismisses on fling', (
    tester,
  ) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<void>(
              context: context,
              title: 'Rename',
              showDragHandle: false,
              child: const Text('sheet-body'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_drag_handle')), findsNothing);
    await tester.fling(
      find.byKey(const ValueKey('safaeh_panel')),
      const Offset(0, 280),
      1400,
    );
    await tester.pumpAndSettle();
    expect(find.text('sheet-body'), findsNothing);
  });

  testWidgets('showSafaeh dismissValue is returned from the barrier', (
    tester,
  ) async {
    await setPhone(tester);
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showSafaeh<String>(
                context: context,
                title: 'Rename',
                dismissValue: 'gone',
                child: const Text('sheet-body'),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    expect(result, 'gone');
  });

  testWidgets('showSafaehDialog uses theme size caps and SafeArea', (
    tester,
  ) async {
    await setTablet(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehDialog<void>(
              context: context,
              builder: (ctx) => const Material(
                child: SizedBox(
                  width: 2000,
                  height: 2000,
                  child: Center(child: Text('dialog-body')),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final box = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('safaeh_dialog_constraints')),
    );
    expect(box.size.width, lessThanOrEqualTo(560));
    expect(box.size.height, lessThanOrEqualTo(800 * 0.85 + 0.5));
    expect(
      find.descendant(
        of: find.byType(SafeArea),
        matching: find.byKey(const ValueKey('safaeh_dialog_constraints')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('showSafaehActionSheet pops the selected value', (tester) async {
    await setPhone(tester);
    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              chosen = await showSafaehActionSheet<String>(
                context: context,
                title: 'Actions',
                actions: const [
                  SafaehAction(value: 'edit', label: 'Edit'),
                  SafaehAction(
                    value: 'delete',
                    label: 'Delete',
                    destructive: true,
                  ),
                ],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(chosen, 'edit');
  });

  testWidgets('showSafaehActionSheet pops from custom tiles without onTap', (
    tester,
  ) async {
    await setPhone(tester);
    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              chosen = await showSafaehActionSheet<String>(
                context: context,
                title: 'Actions',
                actions: const [SafaehAction(value: 'edit', label: 'Edit')],
                tileBuilder: (context, action) =>
                    SizedBox(height: 48, child: Text(action.label)),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GestureDetector, 'Edit'));
    await tester.pumpAndSettle();
    expect(chosen, 'edit');
  });

  testWidgets('showSafaehInfo returns true from the primary action', (
    tester,
  ) async {
    await setPhone(tester);
    bool? accepted;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              accepted = await showSafaehInfo(
                context: context,
                title: 'Permission needed',
                content: 'Open system settings to continue.',
                primaryLabel: 'Open settings',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehContentPanel), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(accepted, isTrue);
  });

  testWidgets('timed confirm enables only after its delay', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaehTimedConfirm(
              context: context,
              title: 'Delete item',
              content: 'Wait before deleting.',
              confirmLabel: 'Delete',
              isDestructive: true,
              seconds: 2,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('safaeh_confirm')))
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('safaeh_confirm')))
          .onPressed,
      isNotNull,
    );
  });
}

void _noop() {}
