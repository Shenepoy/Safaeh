import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as m;
import 'package:safaeh_example/catalog.dart';
import 'package:widgetbook/widgetbook.dart' as wb;

import 'catalog.dart';
import 'preview_host.dart';

void main() => runApp(const SafaehWidgetbook());

class SafaehWidgetbook extends StatelessWidget {
  const SafaehWidgetbook({super.key, this.initialRoute = '/'});
  final String initialRoute;

  @override
  Widget build(BuildContext context) => wb.Widgetbook(
    initialRoute: initialRoute,
    directories: catalogDirectories,
    addons: previewAddons(),
    appBuilder: (_, child) => m.MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [for (final item in catalogLocales) item.locale],
      localizationsDelegates: m.GlobalMaterialLocalizations.delegates,
      home: child,
    ),
  );
}
