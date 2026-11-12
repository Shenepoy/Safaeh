import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

import 'appearance_toggles.dart';
import 'catalog.dart';
import 'catalog_theme.dart';
import 'gallery.dart';
import 'pages.dart';
import 'theme_ripple.dart';

export 'catalog_theme.dart';

class SafaehExampleApp extends StatefulWidget {
  const SafaehExampleApp({
    super.key,
    this.initialLocale = 'en',
    this.initialThemeMode = ThemeMode.light,
  });

  final String initialLocale;
  final ThemeMode initialThemeMode;

  @override
  State<SafaehExampleApp> createState() => _SafaehExampleAppState();
}

class _SafaehExampleAppState extends State<SafaehExampleApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _feedbackInset = ValueNotifier<double>(0);
  late String _locale;
  late ThemeMode _themeMode;
  late SafaehFloatingSurfaceStyle _floatingStyle;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _themeMode = widget.initialThemeMode == ThemeMode.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    _floatingStyle = SafaehFloatingSurfaceStyle.solid;
  }

  @override
  void dispose() {
    _feedbackInset.dispose();
    super.dispose();
  }

  Future<void> _openDebugMenu() async {
    final navContext = _navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;
    await openExampleDebugMenu(
      navContext,
      (key) => translateCatalog(key, _locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafaehTheme(
      data: SafaehThemeData(
        tabletBreakpoint: 600,
        dialogMaxWidth: 560,
        contentMaxWidth: 600,
        floatingAppearance: SafaehFloatingAppearance(style: _floatingStyle),
      ),
      child: MaterialApp(
        title: translateCatalog('app_title', _locale),
        debugShowCheckedModeBanner: false,
        locale: catalogFlutterLocale(_locale),
        supportedLocales: [for (final item in catalogLocales) item.locale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: catalogTheme(Brightness.light),
        darkTheme: catalogTheme(Brightness.dark),
        themeMode: _themeMode,
        navigatorKey: _navigatorKey,
        builder: (context, child) {
          return SafaehDebugMenuHost(
            tooltip: translateCatalog('debug_menu', _locale),
            onOpen: _openDebugMenu,
            child: SafaehFeedbackHost(
              relayout: _feedbackInset,
              bottomInsetBuilder: (_) => _feedbackInset.value,
              itemWidthBuilder: (context) =>
                  (MediaQuery.sizeOf(context).width - 32)
                      .clamp(0.0, 560.0)
                      .toDouble(),
              child: CatalogFeedbackInset(
                notifier: _feedbackInset,
                child: ThemeRippleHost(
                  overlay: CatalogAppearanceToggles(
                    localeCode: _locale,
                    themeMode: _themeMode,
                    floatingStyle: _floatingStyle,
                    onSelectLocale: (code) => setState(() => _locale = code),
                    onToggleTheme: () => setState(() {
                      _themeMode = _themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                    }),
                    onCycleFloatingStyle: () => setState(() {
                      final styles = SafaehFloatingSurfaceStyle.values;
                      _floatingStyle =
                          styles[(styles.indexOf(_floatingStyle) + 1) %
                              styles.length];
                    }),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
        home: CatalogHome(localeCode: _locale),
      ),
    );
  }
}

class CatalogHome extends StatelessWidget {
  const CatalogHome({super.key, required this.localeCode});

  final String localeCode;

  String t(String key) => translateCatalog(key, localeCode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('app_title')),
        actions: const [SizedBox(width: 148)],
      ),
      // No SafaehPageIndex / overlay on home — those live only in the
      // page-index demo widgets (own scroll + keys).
      body: SafaehContentBand(
        maxWidth: kCatalogBandMaxWidth,
        child: CatalogGallery(t: t),
      ),
    );
  }
}
