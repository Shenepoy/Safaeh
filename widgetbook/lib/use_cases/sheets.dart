import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:widgetbook/widgetbook.dart';

import '../text_knob.dart';
import 'common.dart';

Widget adaptiveSheetStory(BuildContext context) => _AdaptiveStory(
  title: context.catalogString(
    label: 'Title',
    initialValue: storyText(context, 'sheet'),
  ),
  body: context.catalogString(
    label: 'Body',
    initialValue: storyText(context, 'shell_body'),
  ),
  raised: context.knobs.boolean(label: 'Raised sheet'),
);

class _AdaptiveStory extends StatefulWidget {
  const _AdaptiveStory({
    required this.title,
    required this.body,
    required this.raised,
  });
  final String title;
  final String body;
  final bool raised;
  @override
  State<_AdaptiveStory> createState() => _AdaptiveStoryState();
}

class _AdaptiveStoryState extends State<_AdaptiveStory> {
  late final _copy = ValueNotifier((widget.title, widget.body));

  @override
  void didUpdateWidget(covariant _AdaptiveStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A dialog is a sibling of this route; publish changes after this build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _copy.value = (widget.title, widget.body);
    });
  }

  @override
  void dispose() {
    _copy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StoryResult(
    label: storyText(context, 'sheet'),
    onOpen: (context) => showSafaeh<void>(
      context: context,
      useRootNavigator: false,
      title: widget.title,
      titleBuilder: (_, style) => ValueListenableBuilder(
        valueListenable: _copy,
        builder: (_, value, _) => Text(value.$1, style: style),
      ),
      phonePlacement: widget.raised
          ? SafaehPhoneSheetPlacement.center
          : SafaehPhoneSheetPlacement.bottom,
      child: ValueListenableBuilder(
        valueListenable: _copy,
        builder: (context, value, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value.$2, key: const ValueKey('adaptive_body')),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => safaehPop(context),
                child: Text(storyText(context, 'close')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget confirmStory(BuildContext context, {bool destructive = false}) {
  final danger = context.knobs.boolean(
    label: 'Destructive',
    initialValue: destructive,
  );
  final content = context.catalogString(
    label: 'Content',
    initialValue: storyText(context, 'cannot_undo'),
  );
  return StoryResult(
    label: storyText(context, 'confirm'),
    onOpen: (context) => showSafaehConfirm(
      context: context,
      useRootNavigator: false,
      title: storyText(context, 'delete_item'),
      content: content,
      confirmLabel: storyText(context, 'delete'),
      isDestructive: danger,
    ),
  );
}

Widget timedConfirmStory(BuildContext context) {
  final seconds = context.knobs.int.slider(
    label: 'Seconds',
    initialValue: 3,
    min: 0,
    max: 10,
  );
  return StoryResult(
    label: 'Timed confirm',
    onOpen: (context) => showSafaehTimedConfirm(
      context: context,
      useRootNavigator: false,
      seconds: seconds,
      title: storyText(context, 'delete_item'),
      content: storyText(context, 'cannot_undo'),
      confirmLabel: storyText(context, 'delete'),
      isDestructive: true,
    ),
  );
}

Widget dialogStory(BuildContext context) => StoryResult(
  label: storyText(context, 'dialog'),
  onOpen: (context) => showSafaehDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: TextButton(
        onPressed: () => safaehPop(context),
        child: Text(storyText(context, 'close')),
      ),
    ),
  ),
);

Widget infoStory(BuildContext context) => StoryResult(
  label: 'Information',
  onOpen: (context) => showSafaehInfo(
    context: context,
    useRootNavigator: false,
    title: storyText(context, 'chrome_ready'),
    content: storyText(context, 'shell_body'),
    primaryLabel: storyText(context, 'done'),
  ),
);

Widget actionsStory(BuildContext context) => StoryResult(
  label: 'Action sheet',
  onOpen: (context) => showSafaehActionSheet<String>(
    context: context,
    useRootNavigator: false,
    title: storyText(context, 'choose_account'),
    actions: [
      SafaehAction(
        value: 'cash',
        label: storyText(context, 'cash'),
        selected: true,
      ),
      SafaehAction(
        value: 'offline',
        label: storyText(context, 'offline'),
        enabled: false,
      ),
      SafaehAction(
        value: 'delete',
        label: storyText(context, 'delete'),
        destructive: true,
      ),
    ],
  ),
);

Widget textInputStory(BuildContext context) {
  final initial = context.catalogString(
    label: 'Initial value',
    initialValue: 'Safaeh',
  );
  final required = context.knobs.boolean(label: 'Required', initialValue: true);
  return StoryResult(
    label: storyText(context, 'text_input'),
    onOpen: (context) => showSafaehTextInput(
      context: context,
      useRootNavigator: false,
      title: storyText(context, 'rename'),
      hint: storyText(context, 'name'),
      doneLabel: storyText(context, 'done'),
      initialValue: initial,
      validator: (value) =>
          required && value.trim().isEmpty ? storyText(context, 'name') : null,
    ),
  );
}

Widget pickerStory(
  BuildContext context, {
  bool tiles = false,
  bool multi = false,
  bool empty = false,
}) {
  final count = context.knobs.int.slider(
    label: 'Item count',
    initialValue: empty ? 0 : 6,
    min: 0,
    max: 30,
  );
  return StoryResult(
    label: storyText(
      context,
      multi
          ? 'multi_picker'
          : tiles
          ? 'tile_picker'
          : 'picker',
    ),
    onOpen: (context) {
      final options = [
        for (var i = 0; i < count; i++)
          SafaehTileOption<int>(
            value: i,
            label: '${storyText(context, 'groups')} ${i + 1}',
            enabled: i != 2,
          ),
      ];
      if (multi) {
        return showSafaehMultiTilePicker<int>(
          context: context,
          useRootNavigator: false,
          options: options,
          selected: const [0],
          title: storyText(context, 'choose_account'),
          confirmLabel: storyText(context, 'apply'),
          searchHint: storyText(context, 'search_accounts'),
          searchEmptyLabel: storyText(context, 'no_matches'),
        );
      }
      if (tiles) {
        return showSafaehTilePicker<int>(
          context: context,
          useRootNavigator: false,
          options: options,
          selected: 0,
          title: storyText(context, 'choose_account'),
          searchHint: storyText(context, 'search_accounts'),
          searchEmptyLabel: storyText(context, 'no_matches'),
        );
      }
      return showSafaehPicker<int>(
        context: context,
        useRootNavigator: false,
        selected: 0,
        title: storyText(context, 'choose_account'),
        options: [
          for (final option in options)
            SafaehOption(
              value: option.value,
              label: option.label,
              subtitle: '',
              enabled: option.enabled,
              icon: Icons.group_outlined,
            ),
        ],
      );
    },
  );
}

Widget templateStory(BuildContext context) {
  final withFooter = context.knobs.boolean(
    label: 'Show footer',
    initialValue: true,
  );
  final compact = context.knobs.boolean(label: 'Compact spacing');
  final title = context.catalogString(
    label: 'Title',
    initialValue: storyText(context, 'sheet'),
  );
  return StoryPage(
    child: SizedBox(
      height: 420,
      child: SafaehSheetTemplate(
        padding: compact ? const EdgeInsets.all(12) : null,
        header: SafaehSheetHeading(
          title: title,
          leading: const Icon(Icons.edit_outlined),
        ),
        body: SafaehSheetSurface(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: storyText(context, 'name'),
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < 12; i++)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(storyText(context, 'shell_body')),
                  ),
              ],
            ),
          ),
        ),
        footer: withFooter
            ? FilledButton(
                onPressed: () {},
                child: Text(storyText(context, 'apply')),
              )
            : null,
      ),
    ),
  );
}

Widget sheetLoadingStory(BuildContext context) {
  final cached = context.knobs.boolean(label: 'Preloaded');
  final fail = context.knobs.boolean(
    label: 'Fail first read',
    initialValue: true,
  );
  final ar = Localizations.localeOf(context).languageCode == 'ar';
  return StoryPage(
    child: SafaehSheetDataLoader<String>(
      key: ValueKey((cached, fail)),
      header: SafaehSheetHeading(
        title: storyText(context, 'sheet'),
        leading: const Icon(Icons.group_outlined),
      ),
      initialData: cached ? storyText(context, 'shell_body') : null,
      labels: SafaehSheetLoadLabels(
        loading: ar ? 'جارٍ تحميل التفاصيل…' : 'Loading details…',
        error: ar
            ? 'تعذّر تحميل التفاصيل. حاول مرة أخرى.'
            : 'Couldn’t load these details. Please try again.',
        retry: ar ? 'إعادة المحاولة' : 'Retry',
      ),
      load: (retry) async {
        final result = storyText(context, 'shell_body');
        await Future<void>.delayed(const Duration(seconds: 2));
        if (fail && !retry) throw StateError('Preview read failed');
        return result;
      },
      builder: (_, value) => SafaehSheetSurface(
        child: Padding(padding: const EdgeInsets.all(24), child: Text(value)),
      ),
    ),
  );
}

Widget sheetActionStory(BuildContext context) => _SheetActionStory(
  state: context.knobs.object.dropdown(
    label: 'State',
    options: SafaehSheetActionState.values,
    initialOption: SafaehSheetActionState.cooldown,
    labelBuilder: (value) => value.name,
  ),
  destructive: context.knobs.boolean(label: 'Destructive'),
  auxiliary: context.knobs.boolean(
    label: 'Custom auxiliary slots',
    initialValue: true,
  ),
);

class _SheetActionStory extends StatefulWidget {
  const _SheetActionStory({
    required this.state,
    required this.destructive,
    required this.auxiliary,
  });
  final SafaehSheetActionState state;
  final bool destructive, auxiliary;
  @override
  State<_SheetActionStory> createState() => _SheetActionStoryState();
}

class _SheetActionStoryState extends State<_SheetActionStory>
    with SingleTickerProviderStateMixin {
  late final _activity = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  @override
  void initState() {
    super.initState();
    _updateActivity();
  }

  void _updateActivity() {
    _activity.stop();
    if (widget.state == SafaehSheetActionState.working ||
        widget.state == SafaehSheetActionState.cooldown) {
      _activity.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _SheetActionStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) _updateActivity();
  }

  @override
  void dispose() {
    _activity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final labels = [
      ar ? 'حفظ' : 'Save',
      ar ? 'جارٍ الحفظ…' : 'Saving…',
      ar ? 'حاول مرة أخرى' : 'Try again',
    ];
    return StoryPage(
      child: SafaehSheetActionButton(
        state: widget.state,
        activity: _activity,
        cooldownProgress: .5,
        label:
            labels[widget.state == SafaehSheetActionState.failed
                ? 2
                : widget.state == SafaehSheetActionState.working
                ? 1
                : 0],
        stateLabels: labels,
        reserveActionSpace: widget.auxiliary,
        color: widget.destructive ? cs.error : cs.primary,
        foregroundColor: widget.destructive ? cs.onError : cs.onPrimary,
        leading:
            widget.auxiliary && widget.state == SafaehSheetActionState.failed
            ? IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info_outline),
                tooltip: ar ? 'تفاصيل' : 'Details',
              )
            : null,
        trailing:
            widget.auxiliary && widget.state == SafaehSheetActionState.failed
            ? IconButton(
                onPressed: () {},
                icon: const Icon(Icons.copy),
                tooltip: ar ? 'نسخ' : 'Copy',
              )
            : null,
        onPressed: () {},
      ),
    );
  }
}
