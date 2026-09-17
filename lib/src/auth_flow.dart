import 'package:flutter/material.dart';

import 'onboarding.dart';

/// Provider buttons a host can expose in [SafaehAuthFlow].
enum SafaehAuthProvider { google, github, apple, other }

/// Visual/authentication state supplied by the host adapter.
enum SafaehAuthMode { signIn, signUp, profile, resetPassword, pending }

class SafaehAuthSnapshot {
  const SafaehAuthSnapshot({
    this.mode = SafaehAuthMode.signIn,
    this.busy = false,
    this.errorMessage,
    this.pendingEmail,
  });

  final SafaehAuthMode mode;
  final bool busy;
  final String? errorMessage;
  final String? pendingEmail;
}

class SafaehAuthCredentials {
  const SafaehAuthCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class SafaehAuthProfile {
  const SafaehAuthProfile({required this.displayName});

  final String displayName;
}

/// Host callbacks for the generic auth presentation.
class SafaehAuthActions {
  const SafaehAuthActions({
    this.onSubmit,
    this.onProfileSubmit,
    this.onProvider,
    this.onMagicLink,
    this.onPasswordReset,
    this.onToggleMode,
    this.onBack,
    this.onResend,
  });

  final Future<void> Function(SafaehAuthCredentials credentials)? onSubmit;
  final Future<void> Function(SafaehAuthProfile profile)? onProfileSubmit;
  final Future<void> Function(SafaehAuthProvider provider)? onProvider;
  final Future<void> Function(String email)? onMagicLink;
  final Future<void> Function(String email)? onPasswordReset;
  final VoidCallback? onToggleMode;
  final VoidCallback? onBack;
  final Future<void> Function()? onResend;
}

/// Copy supplied by the host. Safaeh deliberately has no localization
/// dependency and uses these English values only as a usable fallback.
class SafaehAuthLabels {
  const SafaehAuthLabels({
    this.signInTitle = 'Welcome back',
    this.signUpTitle = 'Create your account',
    this.profileTitle = 'Tell us about you',
    this.resetTitle = 'Reset your password',
    this.pendingTitle = 'Check your email',
    this.email = 'Email',
    this.password = 'Password',
    this.displayName = 'Name',
    this.signIn = 'Sign in',
    this.signUp = 'Sign up',
    this.continueLabel = 'Continue',
    this.reset = 'Send reset link',
    this.magicLink = 'Sign in with magic link',
    this.forgotPassword = 'Forgot password?',
    this.switchToSignUp = 'Create an account',
    this.switchToSignIn = 'I already have an account',
    this.back = 'Back',
    this.resend = 'Resend email',
    this.pendingDescription = 'Use the link we sent to finish signing in.',
    this.google = 'Google',
    this.github = 'GitHub',
    this.apple = 'Apple',
    this.otherProvider = 'Continue with provider',
    this.emailDivider = 'or continue with email',
    this.requiredField = 'Required',
    this.invalidEmail = 'Enter a valid email address',
  });

  final String signInTitle;
  final String signUpTitle;
  final String profileTitle;
  final String resetTitle;
  final String pendingTitle;
  final String email;
  final String password;
  final String displayName;
  final String signIn;
  final String signUp;
  final String continueLabel;
  final String reset;
  final String magicLink;
  final String forgotPassword;
  final String switchToSignUp;
  final String switchToSignIn;
  final String back;
  final String resend;
  final String pendingDescription;
  final String google;
  final String github;
  final String apple;
  final String otherProvider;
  final String emailDivider;
  final String requiredField;
  final String invalidEmail;

  String provider(SafaehAuthProvider provider) => switch (provider) {
    SafaehAuthProvider.google => google,
    SafaehAuthProvider.github => github,
    SafaehAuthProvider.apple => apple,
    SafaehAuthProvider.other => otherProvider,
  };
}

typedef SafaehAuthProviderBuilder =
    Widget Function(
      BuildContext context,
      SafaehAuthProvider provider,
      String label,
      VoidCallback? onPressed,
    );

/// Generic sign-in/signup presentation with no account or network knowledge.
class SafaehAuthFlow extends StatefulWidget {
  const SafaehAuthFlow({
    super.key,
    this.snapshot = const SafaehAuthSnapshot(),
    this.actions = const SafaehAuthActions(),
    this.labels = const SafaehAuthLabels(),
    this.design = SafaehOnboardingDesign.zen,
    this.providers = const [
      SafaehAuthProvider.google,
      SafaehAuthProvider.github,
    ],
    this.providerBuilder,
    this.brand,
  });

  final SafaehAuthSnapshot snapshot;
  final SafaehAuthActions actions;
  final SafaehAuthLabels labels;
  final SafaehOnboardingDesign design;
  final List<SafaehAuthProvider> providers;
  final SafaehAuthProviderBuilder? providerBuilder;
  final Widget? brand;

  @override
  State<SafaehAuthFlow> createState() => _SafaehAuthFlowState();
}

class _SafaehAuthFlowState extends State<SafaehAuthFlow> {
  late SafaehAuthMode _mode;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _displayNameController;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _mode = widget.snapshot.mode;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _displayNameController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant SafaehAuthFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot.mode != widget.snapshot.mode) {
      _mode = widget.snapshot.mode;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? widget.labels.requiredField
      : null;

  String? _email(String? value) {
    final required = _required(value);
    if (required != null) return required;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
        ? null
        : widget.labels.invalidEmail;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    if (_mode == SafaehAuthMode.profile) {
      await widget.actions.onProfileSubmit?.call(
        SafaehAuthProfile(displayName: _displayNameController.text.trim()),
      );
      return;
    }
    if (_mode == SafaehAuthMode.resetPassword) {
      await widget.actions.onPasswordReset?.call(email);
      return;
    }
    await widget.actions.onSubmit?.call(
      SafaehAuthCredentials(email: email, password: _passwordController.text),
    );
  }

  Future<void> _sendMagicLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.actions.onMagicLink?.call(_emailController.text.trim());
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == SafaehAuthMode.signIn
          ? SafaehAuthMode.signUp
          : SafaehAuthMode.signIn;
    });
    widget.actions.onToggleMode?.call();
  }

  String get _title => switch (_mode) {
    SafaehAuthMode.signIn => widget.labels.signInTitle,
    SafaehAuthMode.signUp => widget.labels.signUpTitle,
    SafaehAuthMode.profile => widget.labels.profileTitle,
    SafaehAuthMode.resetPassword => widget.labels.resetTitle,
    SafaehAuthMode.pending => widget.labels.pendingTitle,
  };

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final busy = snapshot.busy;
    final content = switch (_mode) {
      SafaehAuthMode.pending => _PendingAuthPanel(
        labels: widget.labels,
        email: snapshot.pendingEmail ?? _emailController.text,
        busy: busy,
        error: snapshot.errorMessage,
        onResend: widget.actions.onResend,
        onBack: widget.actions.onBack,
      ),
      SafaehAuthMode.profile => _buildForm(
        fields: [_displayNameField()],
        actionLabel: widget.labels.continueLabel,
        busy: busy,
      ),
      SafaehAuthMode.resetPassword => _buildForm(
        fields: [_emailField()],
        actionLabel: widget.labels.reset,
        busy: busy,
      ),
      _ => _buildCredentialsForm(busy),
    };

    return Semantics(
      container: true,
      label: _title,
      child: _AuthSurface(
        design: widget.design,
        brand: widget.brand,
        title: Text(_title),
        error: snapshot.errorMessage,
        child: content,
      ),
    );
  }

  Widget _buildCredentialsForm(bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.providers.isNotEmpty) ...[
          for (var i = 0; i < widget.providers.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _provider(widget.providers[i], busy),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.labels.emailDivider,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
        ],
        _buildForm(
          fields: [_emailField(), _passwordField()],
          actionLabel: _mode == SafaehAuthMode.signUp
              ? widget.labels.signUp
              : widget.labels.signIn,
          busy: busy,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: busy
                ? null
                : () => setState(() => _mode = SafaehAuthMode.resetPassword),
            child: Text(widget.labels.forgotPassword),
          ),
        ),
        OutlinedButton(
          onPressed: busy ? null : _sendMagicLink,
          child: Text(widget.labels.magicLink),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy ? null : _toggleMode,
          child: Text(
            _mode == SafaehAuthMode.signIn
                ? widget.labels.switchToSignUp
                : widget.labels.switchToSignIn,
          ),
        ),
      ],
    );
  }

  Widget _buildForm({
    required List<Widget> fields,
    required String actionLabel,
    required bool busy,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            fields[i],
          ],
          const SizedBox(height: 18),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(actionLabel),
          ),
          if (_mode == SafaehAuthMode.resetPassword)
            TextButton(
              onPressed: busy
                  ? null
                  : () => setState(() => _mode = SafaehAuthMode.signIn),
              child: Text(widget.labels.back),
            ),
        ],
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: _email,
      decoration: InputDecoration(labelText: widget.labels.email),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      autofillHints: const [AutofillHints.password],
      validator: _required,
      decoration: InputDecoration(
        labelText: widget.labels.password,
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }

  Widget _displayNameField() {
    return TextFormField(
      controller: _displayNameController,
      textCapitalization: TextCapitalization.words,
      validator: _required,
      decoration: InputDecoration(labelText: widget.labels.displayName),
    );
  }

  Widget _provider(SafaehAuthProvider provider, bool busy) {
    final label = widget.labels.provider(provider);
    final onPressed = busy || widget.actions.onProvider == null
        ? null
        : () => widget.actions.onProvider!(provider);
    final custom = widget.providerBuilder;
    if (custom != null) {
      return custom(context, provider, label, onPressed);
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(switch (provider) {
        SafaehAuthProvider.google => Icons.g_mobiledata,
        SafaehAuthProvider.github => Icons.code,
        SafaehAuthProvider.apple => Icons.apple,
        SafaehAuthProvider.other => Icons.login,
      }),
      label: Text(label),
    );
  }
}

class _PendingAuthPanel extends StatelessWidget {
  const _PendingAuthPanel({
    required this.labels,
    required this.email,
    required this.busy,
    required this.error,
    required this.onResend,
    required this.onBack,
  });

  final SafaehAuthLabels labels;
  final String email;
  final bool busy;
  final String? error;
  final Future<void> Function()? onResend;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 56, color: cs.primary),
        const SizedBox(height: 16),
        Text(labels.pendingDescription, textAlign: TextAlign.center),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.error),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: busy || onResend == null ? null : onResend,
          child: busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(labels.resend),
        ),
        TextButton(onPressed: busy ? null : onBack, child: Text(labels.back)),
      ],
    );
  }
}

class _AuthSurface extends StatelessWidget {
  const _AuthSurface({
    required this.design,
    required this.title,
    required this.child,
    required this.error,
    required this.brand,
  });

  final SafaehOnboardingDesign design;
  final Widget title;
  final Widget child;
  final String? error;
  final Widget? brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = switch (design) {
      SafaehOnboardingDesign.paper => 6.0,
      SafaehOnboardingDesign.zen => 2.0,
      _ => 24.0,
    };
    final inner = ListView(
      // Unlike SingleChildScrollView, a shrink-wrapped ListView sizes the
      // wide auth panel to its content while retaining scrolling for short
      // viewports.
      shrinkWrap: true,
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (brand != null) ...[brand!, const SizedBox(height: 16)],
              DefaultTextStyle(
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                child: title,
              ),
              if (error != null) ...[
                const SizedBox(height: 14),
                Text(error!, style: TextStyle(color: cs.error)),
              ],
              const SizedBox(height: 22),
              child,
            ],
          ),
        ),
      ],
    );
    final decorated = switch (design) {
      SafaehOnboardingDesign.zen => inner,
      SafaehOnboardingDesign.paper => Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: inner,
      ),
      SafaehOnboardingDesign.prism => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.5),
            border: Border.all(color: cs.onSurface.withValues(alpha: 0.2)),
          ),
          child: inner,
        ),
      ),
      _ => Material(
        color: cs.surface,
        elevation: design == SafaehOnboardingDesign.orbit ? 8 : 2,
        shadowColor: cs.primary.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: inner,
      ),
    };
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: Padding(padding: const EdgeInsets.all(16), child: decorated),
    );
  }
}
