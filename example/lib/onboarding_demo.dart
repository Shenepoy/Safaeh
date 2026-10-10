import 'package:flutter/material.dart';
import 'package:safaeh/safaeh.dart';

import 'app.dart';

/// Public catalog page for Safaeh's onboarding and auth presentation APIs.
class OnboardingDesignDemo extends StatefulWidget {
  const OnboardingDesignDemo({super.key, required this.t});

  final String Function(String key) t;

  @override
  State<OnboardingDesignDemo> createState() => _OnboardingDesignDemoState();
}

class _OnboardingDesignDemoState extends State<OnboardingDesignDemo> {
  SafaehOnboardingDesign _design = SafaehOnboardingDesign.zen;
  SafaehAuthMode _authMode = SafaehAuthMode.signIn;
  bool _showAuth = false;
  bool? _darkOverride;
  bool? _rtlOverride;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final rtl = _rtlOverride ?? Directionality.of(context) == TextDirection.rtl;
    final dark =
        _darkOverride ?? Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final info in SafaehOnboardingDesignCatalog.all)
              ChoiceChip(
                label: Text(info.displayName),
                selected: info.design == _design,
                onSelected: (_) => setState(() => _design = info.design),
              ),
            FilterChip(
              label: Text(t('ob_auth_flow')),
              selected: _showAuth,
              onSelected: (value) => setState(() => _showAuth = value),
            ),
          ],
        ),
        if (_showAuth) ...[
          const SizedBox(height: 8),
          DropdownButton<SafaehAuthMode>(
            value: _authMode,
            isExpanded: true,
            items:
                const [
                  SafaehAuthMode.signIn,
                  SafaehAuthMode.signUp,
                  SafaehAuthMode.profile,
                  SafaehAuthMode.resetPassword,
                  SafaehAuthMode.pending,
                ].map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode.name));
                }).toList(),
            onChanged: (mode) {
              if (mode != null) setState(() => _authMode = mode);
            },
          ),
        ],
        const SizedBox(height: 8),
        Expanded(
          child: Theme(
            data: catalogTheme(dark ? Brightness.dark : Brightness.light),
            child: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: _showAuth
                  ? SafaehAuthFlow(
                      design: _design,
                      snapshot: SafaehAuthSnapshot(mode: _authMode),
                      actions: const SafaehAuthActions(),
                    )
                  : SafaehOnboarding(
                      design: _design,
                      controlPlacement:
                          SafaehOnboardingControlPlacement.bottomCenter,
                      steps: _steps(t),
                      labels: SafaehOnboardingLabels(
                        stepProgress: (current, total) => t('ob_progress')
                            .replaceAll('{current}', '$current')
                            .replaceAll('{total}', '$total'),
                      ),
                      actions: SafaehOnboardingHostActions(
                        languageControl: IconButton(
                          tooltip: t('ob_language'),
                          onPressed: () => setState(() => _rtlOverride = !rtl),
                          icon: const Icon(Icons.language),
                        ),
                        themeControl: IconButton(
                          tooltip: t('ob_theme'),
                          onPressed: () =>
                              setState(() => _darkOverride = !dark),
                          icon: Icon(
                            dark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                          ),
                        ),
                        onComplete: () async =>
                            SafaehOnboardingResult.completed,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  static List<SafaehOnboardingStep> _steps(String Function(String key) t) => [
    SafaehOnboardingStep(
      id: 'welcome',
      titleBuilder: (_) => Text(t('ob_welcome_title')),
      subtitleBuilder: (_) => Text(t('ob_welcome_sub')),
      bodyBuilder: (_) => SafaehOnboardingList(
        children: [
          SafaehOnboardingListItem(
            title: Text(t('ob_shared_title')),
            subtitle: Text(t('ob_shared_sub')),
            leading: const Icon(Icons.dashboard_customize_outlined),
          ),
          SafaehOnboardingListItem(
            title: Text(t('ob_controls_title')),
            subtitle: Text(t('ob_controls_sub')),
            leading: const Icon(Icons.tune_outlined),
          ),
        ],
      ),
    ),
    SafaehOnboardingStep(
      id: 'preferences',
      titleBuilder: (_) => Text(t('ob_prefs_title')),
      subtitleBuilder: (_) => Text(t('ob_prefs_sub')),
      bodyBuilder: (_) => SafaehOnboardingList(
        children: [
          SafaehOnboardingListItem(
            title: Text(t('ob_designs_title')),
            subtitle: Text(t('ob_designs_sub')),
            leading: const Icon(Icons.palette_outlined),
            selected: true,
          ),
          SafaehOnboardingListItem(
            title: Text(t('ob_state_title')),
            subtitle: Text(t('ob_state_sub')),
            leading: const Icon(Icons.lock_outline),
          ),
        ],
      ),
    ),
    SafaehOnboardingStep(
      id: 'ready',
      titleBuilder: (_) => Text(t('ob_ready_title')),
      bodyBuilder: (_) =>
          const Center(child: Icon(Icons.auto_awesome, size: 72)),
    ),
  ];
}
