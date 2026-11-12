import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:widgetbook/widgetbook.dart';

import '../text_knob.dart';
import 'common.dart';

Widget dropdownStory(BuildContext context) {
  final expanded = context.knobs.boolean(label: 'Expand');
  final iconOnly = context.knobs.boolean(label: 'Icon only');
  return _DropdownStory(expanded: expanded, iconOnly: iconOnly);
}

class _DropdownStory extends StatefulWidget {
  const _DropdownStory({required this.expanded, required this.iconOnly});
  final bool expanded;
  final bool iconOnly;
  @override
  State<_DropdownStory> createState() => _DropdownStoryState();
}

class _DropdownStoryState extends State<_DropdownStory> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) => StoryPage(
    child: SafaehAnchoredDropdownChip<int>(
      icon: Icons.filter_list,
      label: storyText(context, _selected == 0 ? 'cash' : 'card'),
      options: [
        SafaehDropdownOption(
          value: 0,
          label: storyText(context, 'cash'),
          icon: Icons.payments_outlined,
        ),
        SafaehDropdownOption(
          value: 1,
          label: storyText(context, 'card'),
          icon: Icons.credit_card,
        ),
      ],
      selected: _selected,
      expand: widget.expanded,
      iconOnly: widget.iconOnly,
      onSelected: (value) => setState(() => _selected = value),
    ),
  );
}

Widget anchoredStory(BuildContext context) => _AnchoredStory(
  motion: context.knobs.object.dropdown(
    label: 'Motion',
    options: SafaehAnchoredMotion.values,
    initialOption: SafaehAnchoredMotion.fadeScale,
    labelBuilder: (value) => value.name,
  ),
);

class _AnchoredStory extends StatefulWidget {
  const _AnchoredStory({required this.motion});
  final SafaehAnchoredMotion motion;
  @override
  State<_AnchoredStory> createState() => _AnchoredStoryState();
}

class _AnchoredStoryState extends State<_AnchoredStory> {
  final _anchor = GlobalKey();
  final _link = LayerLink();

  Rect _source() {
    final box = _anchor.currentContext!.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  }

  @override
  Widget build(BuildContext context) => StoryPage(
    child: Center(
      child: CompositedTransformTarget(
        link: _link,
        child: FilledButton(
          key: _anchor,
          onPressed: () => showSafaehAnchored<void>(
            context: context,
            motion: widget.motion,
            link: _link,
            sourceRect: _source(),
            sourceRectBuilder: _source,
            child: Builder(
              builder: (context) => SafaehContentPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(storyText(context, 'popout_card')),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(storyText(context, 'close')),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: Text(storyText(context, 'anchored_popout')),
        ),
      ),
    ),
  );
}

class CalendarStory extends StatefulWidget {
  const CalendarStory({super.key});
  @override
  State<CalendarStory> createState() => _CalendarStoryState();
}

class _CalendarStoryState extends State<CalendarStory> {
  DateTime _month = DateTime(2026, 11);
  DateTime _selected = DateTime(2026, 11, 12);

  @override
  Widget build(BuildContext context) {
    final labels = MaterialLocalizations.of(context);
    return StoryPage(
      child: SafaehMonthCalendar(
        month: _month,
        firstDate: DateTime(2026),
        lastDate: DateTime(2027, 12, 31),
        start: _selected,
        monthLabel: labels.formatMonthYear(_month),
        weekdayLabels: labels.narrowWeekdays,
        previousTooltip: labels.previousMonthTooltip,
        nextTooltip: labels.nextMonthTooltip,
        onDayTap: (value) => setState(() => _selected = value),
        onPreviousMonth: () =>
            setState(() => _month = DateTime(_month.year, _month.month - 1)),
        onNextMonth: () =>
            setState(() => _month = DateTime(_month.year, _month.month + 1)),
      ),
    );
  }
}

class CycleStory extends StatefulWidget {
  const CycleStory({super.key, required this.enabled});
  final bool enabled;
  @override
  State<CycleStory> createState() => _CycleStoryState();
}

class _CycleStoryState extends State<CycleStory> {
  int _value = 0;
  @override
  Widget build(BuildContext context) => StoryPage(
    child: Column(
      children: [
        Text('$_value'),
        SafaehCycleButton(
          tooltip: storyText(context, 'theme'),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 420),
          onPressed: widget.enabled
              ? () => setState(() => _value = (_value + 1) % 3)
              : null,
        ),
      ],
    ),
  );
}

Widget feedbackStory(BuildContext context) {
  final message = context.catalogString(
    label: 'Message',
    initialValue: storyText(context, 'feedback_info_message'),
  );
  final type = context.knobs.object.dropdown(
    label: 'Type',
    options: SafaehFeedbackType.values,
    initialOption: SafaehFeedbackType.info,
    labelBuilder: (value) => value.name,
  );
  return StoryPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () => context.showSafaehFeedback(message, type: type),
          child: Text(storyText(context, 'feedback')),
        ),
        TextButton(
          onPressed: () => context.showSafaehFeedbackWithAction(
            message,
            type: type,
            actionLabel: storyText(context, 'feedback_undo'),
            onAction: () {},
          ),
          child: Text(storyText(context, 'feedback_action')),
        ),
        TextButton(
          onPressed: () => context.dismissSafaehFeedbacks(),
          child: Text(storyText(context, 'feedback_dismiss_all')),
        ),
      ],
    ),
  );
}
