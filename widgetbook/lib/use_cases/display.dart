import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh_example/pages.dart';
import 'package:widgetbook/widgetbook.dart';

import '../text_knob.dart';
import 'common.dart';

Widget optionTileStory(BuildContext context, {bool longText = false}) {
  final title = context.catalogString(
    label: 'Title',
    initialValue: longText
        ? 'حساب المصروفات المشتركة للعائلة — Shared family expenses'
        : storyText(context, 'selected'),
  );
  final subtitle = context.catalogString(
    label: 'Subtitle',
    initialValue: storyText(context, 'selected_sub'),
  );
  return StoryPage(
    child: SafaehOptionTile(
      title: SafaehUserText(title),
      subtitle:
          context.knobs.boolean(label: 'Show subtitle', initialValue: true)
          ? SafaehUserText(subtitle)
          : null,
      selected: context.knobs.boolean(label: 'Selected', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      destructive: context.knobs.boolean(label: 'Destructive'),
      leading: context.knobs.boolean(label: 'Leading icon', initialValue: true)
          ? const Icon(Icons.account_balance_wallet_outlined)
          : null,
      onTap: () {},
    ),
  );
}

Widget metaChipStory(BuildContext context) => StoryPage(
  child: Align(
    alignment: AlignmentDirectional.centerStart,
    child: SafaehMetaChip(
      label: context.catalogString(
        label: 'Label',
        initialValue: storyText(context, 'work'),
      ),
      compact: context.knobs.boolean(label: 'Compact'),
      icon: context.knobs.boolean(label: 'Icon', initialValue: true)
          ? Icons.work_outline
          : null,
    ),
  ),
);

Widget contentPanelStory(BuildContext context) => StoryPage(
  child: SafaehContentPanel(
    padding: EdgeInsets.all(
      context.knobs.double.slider(
        label: 'Padding',
        initialValue: 14,
        min: 0,
        max: 40,
      ),
    ),
    child: SafaehUserText(
      context.catalogString(
        label: 'Content',
        initialValue: storyText(context, 'shell_body'),
      ),
    ),
  ),
);

Widget inlineBannerStory(
  BuildContext context, {
  SafaehBannerTone initialTone = SafaehBannerTone.info,
}) => StoryPage(
  child: SafaehInlineBanner(
    tone: context.knobs.object.dropdown(
      label: 'Tone',
      options: SafaehBannerTone.values,
      initialOption: initialTone,
      labelBuilder: (value) => value.name,
    ),
    message: context.catalogString(
      label: 'Message',
      initialValue: storyText(context, 'chrome_failed'),
    ),
    detail: context.knobs.boolean(label: 'Show detail', initialValue: true)
        ? storyText(context, 'try_again')
        : null,
    fullBleed: context.knobs.boolean(label: 'Full bleed'),
    actions: context.knobs.boolean(label: 'Action')
        ? [
            TextButton(
              onPressed: () {},
              child: Text(storyText(context, 'try_again')),
            ),
          ]
        : [],
  ),
);

Widget emptyStateStory(BuildContext context) => StoryPage(
  child: SafaehEmptyState(
    icon: Icons.inbox_outlined,
    title: context.catalogString(
      label: 'Title',
      initialValue: storyText(context, 'nothing_here'),
    ),
    subtitle: context.catalogString(
      label: 'Subtitle',
      initialValue: storyText(context, 'empty_state_sub'),
    ),
    actionLabel: context.knobs.boolean(label: 'Action', initialValue: true)
        ? storyText(context, 'add')
        : null,
    onAction: () {},
  ),
);

Widget kpiStory(BuildContext context) => StoryPage(
  child: SafaehKpiCard(
    label: context.catalogString(
      label: 'Label',
      initialValue: storyText(context, 'groups'),
    ),
    value: context.catalogString(label: 'Value', initialValue: '12,345.67'),
    flat: context.knobs.boolean(label: 'Flat'),
  ),
);

enum AsyncScenario { data, loading, empty, error }

Widget asyncStory(BuildContext context, AsyncScenario initial) {
  final scenario = context.knobs.object.dropdown(
    label: 'State',
    options: AsyncScenario.values,
    initialOption: initial,
    labelBuilder: (value) => value.name,
  );
  return StoryPage(
    child: SafaehAsyncBody(
      isLoading: scenario == AsyncScenario.loading,
      isEmpty: scenario == AsyncScenario.empty,
      error: scenario == AsyncScenario.error
          ? storyText(context, 'chrome_failed')
          : null,
      data: (_) =>
          SafaehContentPanel(child: Text(storyText(context, 'chrome_ready'))),
      empty: (_) => SafaehEmptyState(
        icon: Icons.inbox_outlined,
        title: storyText(context, 'nothing_here'),
      ),
    ),
  );
}

Widget statusStory(BuildContext context) => StoryPage(
  child: SafaehStatusBody(
    message: Text(
      context.catalogString(
        label: 'Message',
        initialValue: storyText(context, 'loading'),
      ),
    ),
    busy: context.knobs.boolean(label: 'Busy', initialValue: true),
    progress: context.knobs.double.slider(
      label: 'Progress',
      initialValue: 0.6,
      min: 0,
      max: 1,
    ),
    icon: Icons.info_outline,
  ),
);

Widget shellStory(BuildContext context) => StoryPage(
  child: buildSafaehSheetShell(
    title: Text(storyText(context, 'sheet_shell')),
    showTitleInBody: context.knobs.boolean(
      label: 'Show title',
      initialValue: true,
    ),
    body: SafaehContentPanel(
      child: Text(
        context.catalogString(
          label: 'Content',
          initialValue: storyText(context, 'shell_body'),
        ),
      ),
    ),
    actions: [
      FilledButton(onPressed: () {}, child: Text(storyText(context, 'done'))),
    ],
  ),
);

Widget userTextStory(BuildContext context) => StoryPage(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SafaehUserText(
        context.catalogString(
          label: 'User text',
          initialValue: 'ملاحظات الحساب — account@example.com',
        ),
      ),
      const SizedBox(height: 16),
      const SafaehLtrText('account@example.com'),
      const SizedBox(height: 16),
      UserTextDemo(t: (key) => storyText(context, key)),
    ],
  ),
);
