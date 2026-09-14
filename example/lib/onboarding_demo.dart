import 'package:flutter/material.dart';
import 'package:safaeh/safaeh.dart';

/// Public catalog page for Safaeh's onboarding and auth presentation APIs.
class OnboardingDesignDemo extends StatefulWidget {
  const OnboardingDesignDemo({super.key});

  @override
  State<OnboardingDesignDemo> createState() => _OnboardingDesignDemoState();
}

class _OnboardingDesignDemoState extends State<OnboardingDesignDemo> {
  SafaehOnboardingDesign _design = SafaehOnboardingDesign.zen;
  SafaehAuthMode _authMode = SafaehAuthMode.signIn;
  bool _showAuth = false;
  bool _darkControls = false;

  @override
  Widget build(BuildContext context) {
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
              label: Text(_showAuth ? 'Onboarding' : 'Auth flow'),
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
                  steps: _steps,
                  labels: const SafaehOnboardingLabels(stepProgress: _progress),
                  actions: SafaehOnboardingHostActions(
                    languageControl: IconButton(
                      tooltip: 'Language',
                      onPressed: () {},
                      icon: const Icon(Icons.language),
                    ),
                    themeControl: IconButton(
                      tooltip: 'Theme',
                      onPressed: () =>
                          setState(() => _darkControls = !_darkControls),
                      icon: Icon(
                        _darkControls
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                      ),
                    ),
                    onComplete: () async => SafaehOnboardingResult.completed,
                  ),
                ),
        ),
      ],
    );
  }

  static String _progress(int current, int total) => 'Page $current / $total';

  static final _steps = <SafaehOnboardingStep>[
    SafaehOnboardingStep(
      id: 'welcome',
      titleBuilder: (_) => const Text('A calmer way to get started'),
      subtitleBuilder: (_) =>
          const Text('Choose a visual direction and explore the host seam.'),
      bodyBuilder: (_) => const SafaehOnboardingList(
        children: [
          SafaehOnboardingListItem(
            title: Text('Shared spaces'),
            subtitle: Text('A reusable list treatment for your app content.'),
            leading: Icon(Icons.dashboard_customize_outlined),
          ),
          SafaehOnboardingListItem(
            title: Text('Your controls'),
            subtitle: Text('Language and theme actions stay with the host.'),
            leading: Icon(Icons.tune_outlined),
          ),
        ],
      ),
    ),
    SafaehOnboardingStep(
      id: 'preferences',
      titleBuilder: (_) => const Text('Make it yours'),
      subtitleBuilder: (_) =>
          const Text('Every label and action is replaceable.'),
      bodyBuilder: (_) => const SafaehOnboardingList(
        children: [
          SafaehOnboardingListItem(
            title: Text('Six complete designs'),
            subtitle: Text('Meadow, Orbit, Paper, Atelier, Zen, and Prism.'),
            leading: Icon(Icons.palette_outlined),
            selected: true,
          ),
          SafaehOnboardingListItem(
            title: Text('No hidden state'),
            subtitle: Text('The package never persists your selection.'),
            leading: Icon(Icons.lock_outline),
          ),
        ],
      ),
    ),
    SafaehOnboardingStep(
      id: 'ready',
      titleBuilder: (_) => const Text('Ready to compose'),
      bodyBuilder: (_) =>
          const Center(child: Icon(Icons.auto_awesome, size: 72)),
    ),
  ];
}
