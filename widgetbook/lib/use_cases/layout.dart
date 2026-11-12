import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

import 'common.dart';

class BottomNavStory extends StatefulWidget {
  const BottomNavStory({super.key, this.topFab = false});
  final bool topFab;
  @override
  State<BottomNavStory> createState() => _BottomNavStoryState();
}

class _BottomNavStoryState extends State<BottomNavStory> {
  int _index = 0;
  @override
  Widget build(BuildContext context) => SafaehBottomNavScope(
    child: Builder(
      builder: (context) {
        final layout = SafaehDisplayCutoutLayout.of(context);
        return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation: SafaehCutoutAwareFabLocation(
            base: widget.topFab
                ? FloatingActionButtonLocation.startTop
                : SafaehBottomNavAwareFabLocation.resolve(
                    context,
                    base: FloatingActionButtonLocation.endFloat,
                  ),
            layout: layout,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 120),
                    child: ListView(
                      children: [
                        Text(
                          storyText(context, _index == 0 ? 'home' : 'settings'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: storyText(context, 'name'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (final cutout in layout.cutouts)
                Positioned.fromRect(
                  rect: cutout,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: SafaehKeyboardAwareNav(
                  child: SafaehFloatingNavBar(
                    selectedIndex: _index,
                    onDestinationSelected: (value) =>
                        setState(() => _index = value),
                    destinations: [
                      SafaehSidenavDestination(
                        label: storyText(context, 'home'),
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                      ),
                      SafaehSidenavDestination(
                        label: storyText(context, 'settings'),
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget alignedPageStory(BuildContext context) => SafaehContentAlignedPage(
  builder: (context, width) => Scaffold(
    appBar: SafaehContentAlignedAppBar.forContentArea(
      context,
      contentAreaWidth: width,
      title: Text(storyText(context, 'aligned_title')),
    ),
    body: SafaehContentBand(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(storyText(context, 'band_copy')),
      ),
    ),
  ),
);
