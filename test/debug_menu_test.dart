import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safaeh/safaeh.dart';

void main() {
  testWidgets('showSafaehDebugMenu lists host sections', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSafaehDebugMenu(
                context,
                title: 'Debug',
                identity: const SafaehDebugIdentityCard(
                  package: 'demo',
                  version: '1.0.0',
                  chips: ['Debug'],
                ),
                sections: [
                  SafaehDebugSection(
                    title: 'Tools',
                    icon: Icons.build_outlined,
                    initiallyExpanded: true,
                    children: [
                      SafaehDebugActionTile(
                        icon: Icons.refresh,
                        label: 'Reload',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
                statusMessage: 'Ready',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Debug console'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  test('SafaehL10nOverrideStore reverse-looks up keys', () {
    final store = SafaehL10nOverrideStore(locales: const ['en', 'ar']);
    store.setBundled('en', {'hello': 'Hello', 'bye': 'Goodbye {name}'});
    expect(store.findKeysForText('Hello', 'en'), ['hello']);
    expect(store.findKeysForText('Goodbye Ada', 'en'), ['bye']);
    store.set('en', 'hello', 'Hi');
    expect(store.exportJson(), contains('"hello": "Hi"'));
  });
}
