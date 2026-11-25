import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:widgetbook/widgetbook.dart';

import '../text_knob.dart';
import 'common.dart';

Widget statusIndicatorStory(BuildContext context) {
  final state = context.knobs.object.dropdown<SafaehSyncState>(
    label: 'State',
    options: SafaehSyncState.values,
    initialOption: SafaehSyncState.syncing,
    labelBuilder: (s) => s.name,
  );
  final label = context.catalogString(
    label: 'Label',
    initialValue: 'Syncing 2 changes',
  );
  final custom = context.knobs.boolean(label: 'Custom status colors');
  final base = Theme.of(context);
  final themed = custom
      ? base.copyWith(
          extensions: const [
            SafaehStatusColors(
              success: Color(0xFF40798C),
              onSuccess: Color(0xFFFFFFFF),
              warning: Color(0xFFB36B00),
              onWarning: Color(0xFFFFFFFF),
              danger: Color(0xFF5A2A27),
              onDanger: Color(0xFFFFFFFF),
            ),
          ],
        )
      : base;
  return Theme(
    data: themed,
    child: StoryPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          SafaehStatusIndicator(
            state: state,
            label: label,
            showLabel: context.knobs.boolean(
              label: 'Show label',
              initialValue: true,
            ),
          ),
          SafaehSyncChip(
            key: ValueKey(state),
            state: state,
            label: label,
            onTap: () {},
          ),
          SafaehConnectivityBar(
            state: state,
            label: label,
            retryLabel: 'Retry',
            onRetry: () {},
            recoveredLabel: 'Back online',
            showWhenSyncing: context.knobs.boolean(label: 'Show when syncing'),
          ),
        ],
      ),
    ),
  );
}

Widget syncChipStory(BuildContext context) {
  final label = context.catalogString(label: 'Label', initialValue: 'Synced');
  return StoryPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        for (final state in SafaehSyncState.values) ...[
          Text(state.name, style: Theme.of(context).textTheme.labelMedium),
          Row(
            spacing: 16,
            children: [
              // Roomy slot: shows the label until it collapses.
              SafaehSyncChip(
                key: ValueKey('open-${state.name}'),
                state: state,
                label: switch (state) {
                  SafaehSyncState.saved => label,
                  SafaehSyncState.syncing => 'Syncing',
                  SafaehSyncState.offline => 'Offline',
                  SafaehSyncState.failed => 'Sync failed',
                },
                onTap: () {},
              ),
              // Narrow slot: always the circle, as in a tight app bar.
              SizedBox(
                width: 52,
                child: SafaehSyncChip(
                  key: ValueKey('compact-${state.name}'),
                  state: state,
                  label: state.name,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget snapSheetStory(BuildContext context) {
  final first = context.knobs.int.slider(
    label: 'Initial snap',
    initialValue: 1,
    min: 0,
    max: 2,
  );
  return Scaffold(
    body: SafaehSnapSheet(
      key: ValueKey('snap-$first'),
      initialSnap: first,
      handleLabel: 'Drag to resize',
      child: const ColoredBox(
        color: Color(0xFFCFD8DC),
        child: Center(child: Text('Live content (for example a map)')),
      ),
      sheetBuilder: (context, scroll) => ListView.builder(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: 30,
        itemBuilder: (_, i) => ListTile(title: Text('Place ${i + 1}')),
      ),
    ),
  );
}

class TimelineStory extends StatefulWidget {
  const TimelineStory({super.key, required this.reorderable});
  final bool reorderable;

  @override
  State<TimelineStory> createState() => _TimelineStoryState();
}

class _TimelineStoryState extends State<TimelineStory> {
  final _stops = ['Colosseum', 'Roscioli lunch', 'Vatican Museums', 'Gelato'];

  @override
  Widget build(BuildContext context) => StoryPage(
    child: SafaehTimeline<String>(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      items: _stops,
      itemKey: ValueKey.new,
      itemBuilder: (context, stop, _) => Card(
        margin: EdgeInsets.zero,
        child: ListTile(title: Text(stop), subtitle: const Text('09:00 · 2 h')),
      ),
      legBuilder: (context, stop, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          '11 min walk',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      onReorder: widget.reorderable
          ? (oldIndex, newIndex) => setState(() {
              _stops.insert(newIndex, _stops.removeAt(oldIndex));
            })
          : null,
    ),
  );
}

class SectionChipsStory extends StatefulWidget {
  const SectionChipsStory({super.key, required this.reorderable});
  final bool reorderable;

  @override
  State<SectionChipsStory> createState() => _SectionChipsStoryState();
}

class _SectionChipsStoryState extends State<SectionChipsStory> {
  final _sections = [
    const SafaehSection(id: 'days', label: 'Days'),
    const SafaehSection(id: 'food', label: 'Restaurants', count: 11),
    const SafaehSection(id: 'shops', label: 'Shops', count: 5),
    const SafaehSection(id: 'ideas', label: 'Ideas', icon: Icons.lightbulb),
  ];
  String _selected = 'days';

  @override
  Widget build(BuildContext context) => StoryPage(
    child: SafaehSectionChips(
      sections: _sections,
      selectedId: _selected,
      onSelected: (id) => setState(() => _selected = id),
      onAdd: () => setState(
        () => _sections.add(
          SafaehSection(id: 'new${_sections.length}', label: 'New'),
        ),
      ),
      addLabel: 'Add section',
      onReorder: widget.reorderable
          ? (o, n) => setState(() => _sections.insert(n, _sections.removeAt(o)))
          : null,
    ),
  );
}

/// Branching rail: tap a list to open its sections, then a page inside one.
Widget branchSidenavStory(BuildContext context) =>
    const SizedBox(height: 640, child: _BranchSidenavDemo());

class _BranchSidenavDemo extends StatefulWidget {
  const _BranchSidenavDemo();

  @override
  State<_BranchSidenavDemo> createState() => _BranchSidenavDemoState();
}

enum _BranchPage { trips, plan, stop, map, settings, account }

class _BranchSidenavDemoState extends State<_BranchSidenavDemo> {
  final _history = <_BranchPage>[_BranchPage.trips];
  bool _collapsed = false;

  _BranchPage get _page => _history.last;

  void _visit(_BranchPage page) {
    if (page == _page) return;
    setState(() {
      if (page == _BranchPage.trips || page == _BranchPage.settings) {
        _history.removeRange(1, _history.length);
      }
      if (page != _BranchPage.trips) _history.add(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    SafaehBranchNavItem item(
      _BranchPage page,
      String label,
      IconData icon, {
      int depth = 0,
      bool animateSelection = true,
    }) => SafaehBranchNavItem(
      id: ValueKey(page),
      label: label,
      icon: icon,
      depth: depth,
      animateSelection: animateSelection,
      onTap: () => _visit(page),
    );

    final inTrip = switch (_page) {
      _BranchPage.plan || _BranchPage.stop || _BranchPage.map => true,
      _ => false,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafaehBranchSidenav(
          title: inTrip ? 'Rome in 4 days' : 'Travel planner',
          collapsed: _collapsed,
          onToggleCompact: () => setState(() => _collapsed = !_collapsed),
          expandTooltip: 'Show labels',
          collapseTooltip: 'Hide labels',
          selectedId: ValueKey(_page),
          items: [
            item(
              _BranchPage.trips,
              'Trips',
              Icons.luggage_outlined,
              animateSelection: false,
            ),
            if (inTrip) ...[
              item(
                _BranchPage.plan,
                'Plan',
                Icons.view_list_outlined,
                depth: 1,
              ),
              if (_page == _BranchPage.stop)
                item(
                  _BranchPage.stop,
                  'Colosseum',
                  Icons.account_balance,
                  depth: 2,
                ),
              item(_BranchPage.map, 'Map', Icons.map_outlined, depth: 1),
            ],
          ],
          pinnedItems: [
            item(_BranchPage.settings, 'Settings', Icons.settings_outlined),
            SafaehBranchNavItem(
              id: const ValueKey(_BranchPage.account),
              label: 'Alex Rivera',
              subtitle: 'alex@example.com',
              leading: const SafaehSidenavAvatar(
                label: 'Alex Rivera',
                size: 24,
              ),
              onTap: () => _visit(_BranchPage.account),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (_history.length > 1)
                  TextButton(
                    onPressed: () => setState(() => _history.removeLast()),
                    child: const Text('Back'),
                  ),
                if (_page == _BranchPage.trips)
                  FilledButton(
                    onPressed: () => _visit(_BranchPage.plan),
                    child: const Text('Open Rome in 4 days'),
                  ),
                if (_page == _BranchPage.plan)
                  FilledButton(
                    onPressed: () => _visit(_BranchPage.stop),
                    child: const Text('Open the Colosseum stop'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
