import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  test('sidenav initials fold Latin only', () {
    expect(safaehSidenavInitials('Ada Lovelace'), 'AL');
    expect(safaehSidenavInitials('ada'), 'A');
    expect(safaehSidenavInitials('山田 太郎'), '山太');
    expect(safaehSidenavInitials('نورة'), 'ن');
  });

  testWidgets('picker shows padding and options', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehPicker<int>(
                context: context,
                title: 'How to settle',
                selected: 1,
                footer: 'Footer copy',
                options: const [
                  SafaehOption(
                    value: 1,
                    label: 'Minimal',
                    subtitle: 'Fewest transfers',
                    icon: Icons.bolt_outlined,
                    badge: 'Live',
                  ),
                  SafaehOption(
                    value: 2,
                    label: 'Pairs',
                    subtitle: 'Per pair',
                    icon: Icons.people_outline,
                  ),
                ],
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);
    expect(find.text('How to settle'), findsWidgets);
    expect(find.text('Minimal'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Footer copy'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);

    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    // Header title only — in-body title must hide when crossing 600.
    expect(find.text('How to settle'), findsOneWidget);
  });

  testWidgets('expanding a collapsed rail does not overflow tiles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
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
                    title: 'Hisab',
                    collapsed: collapsed,
                    onToggleCompact: () =>
                        setState(() => collapsed = !collapsed),
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
                      trailing: const Icon(Icons.chevron_right, size: 22),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('safaeh_nav_expand')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('sidenav leading marks keep their column when the rail expands', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
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
                    title: 'Hisab',
                    collapsed: collapsed,
                    onToggleCompact: () =>
                        setState(() => collapsed = !collapsed),
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
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    final collapsedIconX = tester.getCenter(find.byIcon(Icons.group)).dx;
    final collapsedAvatarX = tester
        .getCenter(find.byKey(const ValueKey('safaeh_nav_profile_avatar')))
        .dx;

    await tester.tap(find.byKey(const ValueKey('safaeh_nav_expand')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tester.getCenter(find.byIcon(Icons.group)).dx,
      closeTo(collapsedIconX, 0.01),
    );
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('safaeh_nav_profile_avatar')))
          .dx,
      closeTo(collapsedAvatarX, 0.01),
    );

    await tester.pumpAndSettle();

    expect(
      tester.getCenter(find.byIcon(Icons.group)).dx,
      closeTo(collapsedIconX, 0.01),
    );
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('safaeh_nav_profile_avatar')))
          .dx,
      closeTo(collapsedAvatarX, 0.01),
    );

    await tester.tap(find.byKey(const ValueKey('safaeh_nav_collapse')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.getCenter(find.byIcon(Icons.group)).dx,
      closeTo(collapsedIconX, 0.01),
    );
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('safaeh_nav_profile_avatar')))
          .dx,
      closeTo(collapsedAvatarX, 0.01),
    );
  });

  testWidgets('confirm sheet phone cancel pops false and confirm pops true', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool? first;
    bool? second;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () async {
                  first = await showSafaehConfirm(
                    context: context,
                    title: 'Delete?',
                    content: 'Gone forever',
                    confirmLabel: 'Delete',
                    cancelLabel: 'Cancel',
                    isDestructive: true,
                  );
                },
                child: const Text('open-cancel'),
              ),
              TextButton(
                onPressed: () async {
                  second = await showSafaehConfirm(
                    context: context,
                    title: 'Delete?',
                    content: 'Gone forever',
                    confirmLabel: 'Delete',
                    cancelLabel: 'Cancel',
                  );
                },
                child: const Text('open-confirm'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('safaeh_cancel')));
    await tester.pumpAndSettle();
    expect(first, isFalse);

    await tester.tap(find.text('open-confirm'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('safaeh_confirm')));
    await tester.pumpAndSettle();
    expect(second, isTrue);
  });

  testWidgets('text input returns trimmed value', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              value = await showSafaehTextInput(
                context: context,
                title: 'Tag',
                doneLabel: 'Done',
                initialValue: '  hello  ',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('safaeh_text_done')));
    await tester.pumpAndSettle();
    expect(value, 'hello');
  });

  testWidgets('text input sheet follows initialValue updates', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehTextInputSheet(
            key: ValueKey('sheet'),
            title: 'Tag',
            doneLabel: 'Done',
            initialValue: 'alpha',
          ),
        ),
      ),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'alpha',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehTextInputSheet(
            key: ValueKey('sheet'),
            title: 'Tag',
            doneLabel: 'Done',
            initialValue: 'beta',
          ),
        ),
      ),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'beta',
    );
  });

  testWidgets('obscure text input forces a single line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehTextInputSheet(
            title: 'Pin',
            doneLabel: 'Done',
            obscureText: true,
            maxLines: 3,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
    expect(field.maxLines, 1);
    expect(field.keyboardType, isNot(TextInputType.multiline));
  });

  testWidgets('text input forwards keyboardType and action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehTextInputSheet(
            title: 'Amount',
            doneLabel: 'Done',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.number);
    expect(field.textInputAction, TextInputAction.done);
  });

  testWidgets('text input shows the maxLength counter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehTextInputSheet(
            title: 'Note',
            doneLabel: 'Done',
            maxLength: 8,
          ),
        ),
      ),
    );
    expect(find.text('0/8'), findsOneWidget);
  });

  testWidgets('text input onChanged reports edits', (tester) async {
    var last = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehTextInputSheet(
            title: 'Note',
            doneLabel: 'Done',
            onChanged: (value) => last = value,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'hi');
    expect(last, 'hi');
  });

  testWidgets('text input IME done submits the trimmed value', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              value = await showSafaehTextInput(
                context: context,
                title: 'Tag',
                doneLabel: 'Done',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  hello  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(value, 'hello');
  });

  testWidgets('option tile selected and disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SafaehOptionTile(
                title: const Text('Selected'),
                selected: true,
                onTap: () => taps++,
              ),
              SafaehOptionTile(
                title: const Text('Disabled'),
                enabled: false,
                onTap: () => taps++,
              ),
            ],
          ),
        ),
      ),
    );

    final selected = tester.widget<Material>(
      find
          .ancestor(of: find.text('Selected'), matching: find.byType(Material))
          .first,
    );
    final cs = Theme.of(tester.element(find.text('Selected'))).colorScheme;
    expect(selected.color, cs.primaryContainer);
    expect(
      tester.getSemantics(find.text('Selected')),
      isSemantics(isButton: true, isSelected: true, isEnabled: true),
    );
    expect(
      tester.getSemantics(find.text('Disabled')),
      isSemantics(isButton: true, isEnabled: false),
    );
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    await tester.tap(find.text('Disabled'));
    await tester.pump();
    expect(taps, 0);

    await tester.tap(find.text('Selected'));
    await tester.pump();
    expect(taps, 1);

    final ink = tester.widget<InkWell>(
      find
          .ancestor(of: find.text('Selected'), matching: find.byType(InkWell))
          .first,
    );
    expect(ink.canRequestFocus, isTrue);
  });

  testWidgets('option tile selectedFill overrides the container', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehOptionTile(
            title: Text('Accent'),
            selected: true,
            selectedFill: Color(0xFFFF9800),
          ),
        ),
      ),
    );
    final accent = tester.widget<Material>(
      find
          .ancestor(of: find.text('Accent'), matching: find.byType(Material))
          .first,
    );
    expect(accent.color, const Color(0xFFFF9800));
  });

  testWidgets('dialog scrim dismiss pops null', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Object? result = 'pending';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showSafaehDialog<String>(
                context: context,
                builder: (ctx) => const Material(
                  child: SizedBox(
                    width: 200,
                    height: 120,
                    child: Center(child: Text('dialog-body')),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('dialog-body'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('dialog-body'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('floating nav tap selects destination', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SafaehFloatingNavBar(
                selectedIndex: selected,
                onDestinationSelected: (i) => setState(() => selected = i),
                destinations: const [
                  SafaehSidenavDestination(
                    label: 'Home',
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                  ),
                  SafaehSidenavDestination(
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('safaeh_fab_nav_0'))),
      isSemantics(isButton: true, isSelected: true),
    );
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(selected, 1);
  });

  testWidgets('floating nav defaults to a transparent background', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehFloatingNavBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              SafaehSidenavDestination(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
              ),
            ],
          ),
        ),
      ),
    );

    final bar = tester.widget<Container>(
      find.descendant(
        of: find.byType(SafaehFloatingNavBar),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration != null,
        ),
      ),
    );
    final decoration = bar.decoration! as BoxDecoration;
    expect(decoration.color, Colors.transparent);
  });

  testWidgets('floating nav destination labelBuilder is used', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehFloatingNavBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: [
              SafaehSidenavDestination(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                labelBuilder: (data, style) =>
                    Text('built-$data', style: style),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('built-Home'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('content band hides aside when narrow', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehContentBand(
            aside: Text('aside-rail'),
            child: Text('band-body'),
          ),
        ),
      ),
    );

    expect(find.text('band-body'), findsOneWidget);
    expect(find.text('aside-rail'), findsNothing);
  });

  test('SafaehThemeData.copyWith replaces every field', () {
    const original = SafaehThemeData();
    final copy = original.copyWith(
      tabletBreakpoint: 700,
      dialogMaxWidth: 480,
      motion: const Duration(milliseconds: 100),
      enterCurve: Curves.linear,
      radius: 8,
      compactNavWidth: 64,
      expandedNavWidth: 200,
      navMotion: const Duration(milliseconds: 90),
      pageIndexMotion: const Duration(milliseconds: 80),
      sheetRoll: const Duration(milliseconds: 70),
      sheetRollEnter: Curves.easeIn,
      exitCurve: Curves.linear,
      cameraCompactHeightFraction: 0.5,
      contentMaxWidth: 640,
    );
    expect(copy.tabletBreakpoint, 700);
    expect(copy.dialogMaxWidth, 480);
    expect(copy.motion, const Duration(milliseconds: 100));
    expect(copy.enterCurve, Curves.linear);
    expect(copy.radius, 8);
    expect(copy.compactNavWidth, 64);
    expect(copy.expandedNavWidth, 200);
    expect(copy.navMotion, const Duration(milliseconds: 90));
    expect(copy.pageIndexMotion, const Duration(milliseconds: 80));
    expect(copy.sheetRoll, const Duration(milliseconds: 70));
    expect(copy.sheetRollEnter, Curves.easeIn);
    expect(copy.exitCurve, Curves.linear);
    expect(copy.cameraCompactHeightFraction, 0.5);
    expect(copy.contentMaxWidth, 640);
    expect(original.copyWith(), original);
  });

  testWidgets('showSafaeh morphs phone handle to tablet header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_drag_handle')), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.text('sheet-body'), findsOneWidget);

    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safaeh_panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_drag_handle')), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('sheet-body'), findsOneWidget);
  });

  testWidgets('tile picker header, disabled row, and morph', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              chosen = await showSafaehTilePicker<String>(
                context: context,
                title: 'Import',
                header: const Text('Preview counts'),
                selected: 'add',
                options: const [
                  SafaehTileOption(
                    value: 'add',
                    label: 'Add copies',
                    subtitle: 'Keeps existing',
                    leading: Icon(Icons.add),
                  ),
                  SafaehTileOption(
                    value: 'replace',
                    label: 'Replace',
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
    expect(find.text('Import'), findsWidgets);
    expect(find.text('Preview counts'), findsOneWidget);
    expect(find.text('Keeps existing'), findsOneWidget);

    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(chosen, isNull);
    expect(find.text('Replace'), findsOneWidget);

    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    expect(find.text('Import'), findsOneWidget);

    await tester.tap(find.text('Add copies'));
    await tester.pumpAndSettle();
    expect(chosen, 'add');
  });

  testWidgets('card picker honors enabled', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    int? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              chosen = await showSafaehPicker<int>(
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
    await tester.pumpAndSettle();
    expect(chosen, isNull);
    expect(find.text('Locked'), findsOneWidget);
  });

  testWidgets('option picker body onSelected skips pop', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSafaeh<int>(
              context: context,
              title: 'How to settle',
              child: SafaehOptionPickerBody<int>(
                selected: 1,
                onSelected: (value) => tapped = value,
                options: const [
                  SafaehOption(
                    value: 2,
                    label: 'Pairs',
                    subtitle: 'Per pair',
                    icon: Icons.people_outline,
                  ),
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
    await tester.tap(find.text('Pairs'));
    await tester.pump();
    expect(tapped, 2);
    expect(find.text('Pairs'), findsOneWidget);
  });

  testWidgets('buildSafaehSheetShell shows title, body, and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildSafaehSheetShell(
            title: const Text('Shell title'),
            body: const Text('Shell body'),
            actions: [TextButton(onPressed: () {}, child: const Text('OK'))],
          ),
        ),
      ),
    );

    expect(find.text('Shell title'), findsOneWidget);
    expect(find.text('Shell body'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.byType(OverflowBar), findsOneWidget);
  });

  testWidgets('option tile and card picker consume theme radius', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SafaehTheme(
        data: SafaehThemeData(radius: 20),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SafaehOptionTile(title: Text('Row')),
                SafaehOptionPickerBody<int>(
                  title: 'Pick',
                  options: [
                    SafaehOption(
                      value: 1,
                      label: 'Minimal',
                      subtitle: 'Fewest',
                      icon: Icons.bolt_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final tile = tester.widget<Material>(
      find
          .ancestor(of: find.text('Row'), matching: find.byType(Material))
          .first,
    );
    expect(tile.borderRadius, BorderRadius.circular(20));

    final card = tester.widget<Material>(
      find
          .ancestor(of: find.text('Minimal'), matching: find.byType(Material))
          .first,
    );
    expect(card.borderRadius, BorderRadius.circular(20));
  });

  testWidgets('sidenav asDrawer shows title without expand control', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehSidenav(
            asDrawer: true,
            title: 'Menu',
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              SafaehSidenavDestination(
                label: 'Groups',
                icon: Icons.group_outlined,
                selectedIcon: Icons.group,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.byKey(const ValueKey('safaeh_nav_rail')), findsNothing);
    expect(find.byKey(const ValueKey('safaeh_nav_expand')), findsNothing);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('safaeh_nav_0'))),
      isSemantics(isButton: true, isSelected: true),
    );
  });

  testWidgets('option tile destructive uses error color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehOptionTile(
            title: const Text('Danger'),
            destructive: true,
            onTap: () {},
          ),
        ),
      ),
    );

    final ink = tester.widget<IconTheme>(
      find
          .ancestor(of: find.text('Danger'), matching: find.byType(IconTheme))
          .first,
    );
    final cs = Theme.of(tester.element(find.text('Danger'))).colorScheme;
    expect(ink.data.color, cs.error);
  });

  testWidgets('directional icons flip in RTL', (tester) async {
    late IconData end;
    late IconData start;
    late IconData back;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) {
              end = safaehChevronEnd(context);
              start = safaehChevronStart(context);
              back = safaehArrowBack(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(end, Icons.chevron_right);
    expect(start, Icons.chevron_left);
    expect(back, Icons.arrow_back);
    expect(Icons.chevron_right.matchTextDirection, isTrue);
    expect(Icons.chevron_left.matchTextDirection, isTrue);
    expect(Icons.arrow_back.matchTextDirection, isTrue);
  });

  testWidgets('sidenav collapse chevron mirrors in RTL', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Row(
              children: [
                SafaehSidenav(
                  title: 'Safaeh',
                  collapsed: false,
                  onToggleCompact: _noop,
                  selectedIndex: 0,
                  onDestinationSelected: _noopIndex,
                  destinations: [
                    SafaehSidenavDestination(
                      label: 'Groups',
                      icon: Icons.group_outlined,
                      selectedIcon: Icons.group,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);

    final ink = tester.widget<InkWell>(
      find.byKey(const ValueKey('safaeh_nav_0')),
    );
    expect(ink.canRequestFocus, isTrue);
  });

  testWidgets('multi tile picker confirms a list', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    List<String>? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              chosen = await showSafaehMultiTilePicker<String>(
                context: context,
                title: 'Accounts',
                confirmLabel: 'Apply',
                selected: const ['cash'],
                options: const [
                  SafaehTileOption(value: 'cash', label: 'Cash'),
                  SafaehTileOption(value: 'card', label: 'Card'),
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
    await tester.tap(find.text('Card'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('safaeh_multi_done')));
    await tester.pumpAndSettle();
    expect(chosen, ['cash', 'card']);
  });

  testWidgets('tile picker search filters rows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehTilePickerBody<String>(
            title: 'Accounts',
            searchHint: 'Search',
            searchEmptyLabel: 'No matches',
            options: [
              SafaehTileOption(value: 'cash', label: 'Cash'),
              SafaehTileOption(value: 'card', label: 'Card'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Cash'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('safaeh_tile_search')),
      'car',
    );
    await tester.pump();
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Cash'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('safaeh_tile_search')),
      'zzz',
    );
    await tester.pump();
    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('tile search empty chrome falls back to the hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehTilePickerBody<String>(
            title: 'Accounts',
            searchHint: 'Search',
            options: [SafaehTileOption(value: 'cash', label: 'Cash')],
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('safaeh_tile_search')),
      'zzz',
    );
    await tester.pump();
    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Cash'), findsNothing);
  });

  testWidgets('tileBuilder stays visual; the body owns the tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showSafaehTilePicker<String>(
                context: context,
                title: 'Accounts',
                options: const [
                  SafaehTileOption(value: 'cash', label: 'Cash'),
                  SafaehTileOption(value: 'card', label: 'Card'),
                ],
                tileBuilder: (context, opt, selected) => Text(opt.label),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text('Card'),
        matching: find.byType(GestureDetector),
      ),
    );
    await tester.pumpAndSettle();
    expect(picked, 'card');
  });

  testWidgets('tileBuilder multi-select still toggles on the body', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehTilePickerBody<String>(
            title: 'Accounts',
            multiSelect: true,
            selectedValues: const ['cash'],
            confirmLabel: 'Apply',
            options: const [
              SafaehTileOption(value: 'cash', label: 'Cash'),
              SafaehTileOption(value: 'card', label: 'Card'),
            ],
            tileBuilder: (context, opt, selected) {
              return Text('${opt.label}${selected ? ' *' : ''}');
            },
          ),
        ),
      ),
    );

    expect(find.text('Cash *'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    await tester.tap(
      find.ancestor(
        of: find.text('Card'),
        matching: find.byType(GestureDetector),
      ),
    );
    await tester.pump();
    expect(find.text('Card *'), findsOneWidget);
  });

  testWidgets('tile picker searchMatches overrides default filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehTilePickerBody<String>(
            title: 'Accounts',
            searchHint: 'Search',
            searchMatches: (option, query) => option.value == query,
            options: const [
              SafaehTileOption(value: 'cash', label: 'Cash'),
              SafaehTileOption(value: 'card', label: 'Card'),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('safaeh_tile_search')),
      'cash',
    );
    await tester.pump();
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Card'), findsNothing);
  });

  testWidgets('tile picker selectedValues syncs by contents', (tester) async {
    var selected = <String>['cash'];
    late StateSetter setPageState;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setPageState = setState;
            return Scaffold(
              body: SafaehTilePickerBody<String>(
                multiSelect: true,
                confirmLabel: 'Apply',
                selectedValues: selected,
                options: const [
                  SafaehTileOption(value: 'cash', label: 'Cash'),
                  SafaehTileOption(value: 'card', label: 'Card'),
                ],
              ),
            );
          },
        ),
      ),
    );

    SafaehOptionTile tile(String label) {
      return tester.widget<SafaehOptionTile>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(SafaehOptionTile),
        ),
      );
    }

    expect(tile('Cash').selected, isTrue);
    expect(tile('Card').selected, isFalse);

    selected.add('card');
    setPageState(() {});
    await tester.pump();
    expect(tile('Cash').selected, isTrue);
    expect(tile('Card').selected, isTrue);

    await tester.tap(find.text('Cash'));
    await tester.pump();
    expect(tile('Cash').selected, isFalse);

    setPageState(() => selected = <String>['cash', 'card']);
    await tester.pump();
    expect(tile('Cash').selected, isFalse);
    expect(tile('Card').selected, isTrue);

    setPageState(() => selected = <String>['card']);
    await tester.pump();
    expect(tile('Cash').selected, isFalse);
    expect(tile('Card').selected, isTrue);
  });

  testWidgets('status body shows a busy indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehStatusBody(busy: true, message: Text('Loading')),
        ),
      ),
    );
    expect(find.text('Loading'), findsOneWidget);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      isNull,
    );
  });

  testWidgets('status body honors determinate progress', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafaehStatusBody(
            busy: true,
            progress: 0.4,
            message: Text('Loading'),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      0.4,
    );
  });

  testWidgets('sidenav destination labelBuilder is used', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehSidenav(
            asDrawer: true,
            title: 'Menu',
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: [
              SafaehSidenavDestination(
                label: 'Groups',
                icon: Icons.group_outlined,
                selectedIcon: Icons.group,
                labelBuilder: (data, style) =>
                    Text('built-$data', style: style),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('built-Groups'), findsOneWidget);
    expect(find.text('Groups'), findsNothing);
  });

  testWidgets('collapsed sidenav tooltip uses the navigation label', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SafaehSidenav(
                title: 'Menu',
                collapsed: true,
                onToggleCompact: () {},
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                destinations: [
                  SafaehSidenavDestination(
                    label: 'Groups',
                    icon: Icons.group_outlined,
                    selectedIcon: Icons.group,
                    labelBuilder: (data, style) =>
                        Text('built-$data', style: style),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == 'Groups',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == 'built-Groups',
      ),
      findsNothing,
    );
  });

  testWidgets('sidenav profile defaults to a visible initials avatar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpRail({
      required bool collapsed,
      required ThemeMode mode,
      TextDirection direction = TextDirection.ltr,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          themeMode: mode,
          theme: ThemeData(colorSchemeSeed: const Color(0xFF6750A4)),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          ),
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: Row(
                children: [
                  SafaehSidenav(
                    title: 'Safaeh',
                    collapsed: collapsed,
                    onToggleCompact: _noop,
                    selectedIndex: 0,
                    onDestinationSelected: _noopIndex,
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
              ),
            ),
          ),
        ),
      );
    }

    Future<void> expectVisibleAvatar() async {
      final avatar = find.byKey(const ValueKey('safaeh_nav_profile_avatar'));
      expect(avatar, findsOneWidget);
      expect(find.text('AL'), findsOneWidget);
      final size = tester.getSize(avatar);
      expect(size.width, SafaehSidenavAvatar.defaultSize);
      expect(size.height, SafaehSidenavAvatar.defaultSize);
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: avatar, matching: find.byType(DecoratedBox)),
      );
      final cs = Theme.of(tester.element(avatar)).colorScheme;
      expect((box.decoration as BoxDecoration).color, cs.primary);
    }

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await pumpRail(collapsed: false, mode: mode);
      await tester.pumpAndSettle();
      await expectVisibleAvatar();

      await pumpRail(collapsed: true, mode: mode);
      await tester.pumpAndSettle();
      await expectVisibleAvatar();
    }

    await pumpRail(
      collapsed: false,
      mode: ThemeMode.light,
      direction: TextDirection.rtl,
    );
    await tester.pumpAndSettle();
    await expectVisibleAvatar();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehSidenav(
            asDrawer: true,
            title: 'Menu',
            selectedIndex: 0,
            onDestinationSelected: _noopIndex,
            destinations: const [
              SafaehSidenavDestination(
                label: 'Groups',
                icon: Icons.group_outlined,
                selectedIcon: Icons.group,
              ),
            ],
            profile: SafaehSidenavProfile(label: 'Ada Lovelace', onTap: _noop),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectVisibleAvatar();
  });

  testWidgets('sidenav profile keeps a custom leading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehSidenav(
            asDrawer: true,
            title: 'Menu',
            selectedIndex: 0,
            onDestinationSelected: _noopIndex,
            destinations: const [
              SafaehSidenavDestination(
                label: 'Groups',
                icon: Icons.group_outlined,
                selectedIcon: Icons.group,
              ),
            ],
            profile: SafaehSidenavProfile(
              label: 'Ada Lovelace',
              leading: const Icon(
                Icons.face,
                key: ValueKey('custom_profile_leading'),
              ),
              onTap: _noop,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('custom_profile_leading')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('safaeh_nav_profile_avatar')),
      findsNothing,
    );
    expect(find.text('AL'), findsNothing);
  });
}

void _noop() {}

void _noopIndex(int index) {}
