import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';

class DropdownVariantsDemo extends StatelessWidget {
  const DropdownVariantsDemo({super.key, required this.t});

  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('dropdown_single'), style: labelStyle),
        const SizedBox(height: 4),
        DropdownChoiceDemo(t: t),
        const SizedBox(height: 12),
        Text(t('dropdown_scrollable'), style: labelStyle),
        const SizedBox(height: 4),
        const ScrollableDropdownDemo(),
        const SizedBox(height: 12),
        Text(t('dropdown_toggles'), style: labelStyle),
        const SizedBox(height: 4),
        ToggleDropdownDemo(t: t),
      ],
    );
  }
}

class DropdownChoiceDemo extends StatefulWidget {
  const DropdownChoiceDemo({
    super.key,
    required this.t,
    this.expanded = false,
    this.iconOnly = false,
  });

  final String Function(String key) t;
  final bool expanded;
  final bool iconOnly;
  @override
  State<DropdownChoiceDemo> createState() => _DropdownChoiceDemoState();
}

class _DropdownChoiceDemoState extends State<DropdownChoiceDemo> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) => SafaehAnchoredDropdownChip<int>(
    icon: Icons.filter_list,
    label: widget.t(_selected == 0 ? 'cash' : 'card'),
    options: [
      SafaehDropdownOption(
        value: 0,
        label: widget.t('cash'),
        icon: Icons.payments_outlined,
      ),
      SafaehDropdownOption(
        value: 1,
        label: widget.t('card'),
        icon: Icons.credit_card,
      ),
    ],
    selected: _selected,
    expand: widget.expanded,
    iconOnly: widget.iconOnly,
    onSelected: (value) => setState(() => _selected = value),
  );
}

class ScrollableDropdownDemo extends StatefulWidget {
  const ScrollableDropdownDemo({super.key});

  @override
  State<ScrollableDropdownDemo> createState() => _ScrollableDropdownDemoState();
}

class _ScrollableDropdownDemoState extends State<ScrollableDropdownDemo> {
  int _selectedMonth = 1;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    String monthLabel(int month) =>
        localizations.formatMonthYear(DateTime(2026, month));

    return SafaehAnchoredDropdownChip<int>.scrollable(
      icon: Icons.calendar_month_outlined,
      label: monthLabel(_selectedMonth),
      selected: _selectedMonth,
      options: [
        for (var month = 1; month <= 12; month++)
          SafaehDropdownOption(value: month, label: monthLabel(month)),
      ],
      onSelected: (month) => setState(() => _selectedMonth = month),
    );
  }
}

class ToggleDropdownDemo extends StatefulWidget {
  const ToggleDropdownDemo({super.key, required this.t});

  final String Function(String key) t;

  @override
  State<ToggleDropdownDemo> createState() => _ToggleDropdownDemoState();
}

class _ToggleDropdownDemoState extends State<ToggleDropdownDemo> {
  final _selection = <String>{'cash'};

  @override
  Widget build(BuildContext context) =>
      SafaehAnchoredToggleDropdownChip<String>(
        icon: Icons.filter_list,
        label: widget.t('choose_account'),
        active: _selection.isNotEmpty,
        selectedValues: _selection,
        options: [
          for (final value in ['cash', 'card'])
            SafaehDropdownOption(value: value, label: widget.t(value)),
        ],
        onToggled: (value, checked) => setState(() {
          if (checked) {
            _selection.add(value);
          } else {
            _selection.remove(value);
          }
        }),
      );
}
