import 'package:material_ui/material_ui.dart';
import 'package:safaeh/safaeh.dart';
import 'package:safaeh_example/pages.dart';
import 'package:widgetbook/widgetbook.dart';

import 'common.dart';

Widget onboardingStory(BuildContext context, SafaehOnboardingDesign design) =>
    Scaffold(
      body: SafeArea(
        child: SafaehOnboarding(
          design: design,
          labels: SafaehOnboardingLabels(
            back: MaterialLocalizations.of(context).backButtonTooltip,
            next: MaterialLocalizations.of(context).continueButtonLabel,
            complete: storyText(context, 'done'),
            skip: MaterialLocalizations.of(context).cancelButtonLabel,
            stepProgress: (current, total) => '$current / $total',
          ),
          steps: [
            SafaehOnboardingStep(
              id: 'welcome',
              titleBuilder: (_) => Text(storyText(context, 'ob_welcome_title')),
              subtitleBuilder: (_) =>
                  Text(storyText(context, 'ob_welcome_sub')),
              bodyBuilder: (_) => SafaehOnboardingList(
                children: [
                  SafaehOnboardingListItem(
                    title: Text(storyText(context, 'ob_shared_title')),
                    leading: const Icon(Icons.groups_outlined),
                  ),
                  SafaehOnboardingListItem(
                    title: Text(storyText(context, 'ob_controls_title')),
                    leading: const Icon(Icons.tune),
                    selected: true,
                  ),
                ],
              ),
            ),
            SafaehOnboardingStep(
              id: 'ready',
              titleBuilder: (_) => Text(storyText(context, 'ob_ready_title')),
              bodyBuilder: (_) =>
                  const Center(child: Icon(Icons.auto_awesome, size: 64)),
            ),
          ],
          actions: SafaehOnboardingHostActions(
            onComplete: () async => SafaehOnboardingResult.completed,
          ),
        ),
      ),
    );

Widget authStory(BuildContext context, SafaehOnboardingDesign design) {
  final mode = context.knobs.object.dropdown(
    label: 'Mode',
    options: SafaehAuthMode.values,
    initialOption: SafaehAuthMode.signIn,
    labelBuilder: (value) => value.name,
  );
  final busy = context.knobs.boolean(label: 'Busy');
  final error = context.knobs.boolean(label: 'Error');
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return StoryPage(
    child: SafaehAuthFlow(
      design: design,
      snapshot: SafaehAuthSnapshot(
        mode: mode,
        busy: busy,
        errorMessage: error ? storyText(context, 'chrome_failed') : null,
        pendingEmail: 'preview@example.com',
      ),
      labels: rtl
          ? const SafaehAuthLabels(
              signInTitle: 'مرحباً بعودتك',
              signUpTitle: 'أنشئ حسابك',
              profileTitle: 'أخبرنا عنك',
              resetTitle: 'إعادة تعيين كلمة المرور',
              pendingTitle: 'تحقق من بريدك',
              email: 'البريد الإلكتروني',
              password: 'كلمة المرور',
              displayName: 'الاسم',
              signIn: 'تسجيل الدخول',
              signUp: 'إنشاء حساب',
              continueLabel: 'متابعة',
              reset: 'إرسال رابط الاستعادة',
              magicLink: 'الدخول برابط البريد',
              forgotPassword: 'نسيت كلمة المرور؟',
              switchToSignUp: 'إنشاء حساب',
              switchToSignIn: 'لدي حساب',
              back: 'رجوع',
              resend: 'إعادة الإرسال',
              pendingDescription: 'استخدم الرابط الذي أرسلناه لإكمال الدخول.',
              emailDivider: 'أو استخدم البريد الإلكتروني',
              requiredField: 'مطلوب',
              invalidEmail: 'أدخل بريداً صالحاً',
              signInSubtitle: 'سجل دخولك لمزامنة بياناتك.',
              signUpSubtitle: 'أنشئ حساباً لحفظ بياناتك.',
              profileSubtitle: 'أضف الاسم الذي تود ظهوره.',
            )
          : const SafaehAuthLabels(),
      actions: SafaehAuthActions(
        onSubmit: (_) async {},
        onProfileSubmit: (_) async {},
        onProvider: (_) async {},
        onMagicLink: (_) async {},
        onPasswordReset: (_) async {},
        onResend: () async {},
      ),
    ),
  );
}

Widget cameraStory(BuildContext context, String kind) => StoryResult(
  label: storyText(context, kind),
  onOpen: (context) => showSafaehCameraSheet<void>(
    context: context,
    useRootNavigator: false,
    builder: (context, sheet) => switch (kind) {
      'qr_overlay' => QrOverlayChrome(
        sheet: sheet,
        t: (key) => storyText(context, key),
      ),
      'qr_message' => QrMessageChrome(
        sheet: sheet,
        t: (key) => storyText(context, key),
      ),
      _ => MockCameraChild(sheet: sheet, t: (key) => storyText(context, key)),
    },
  ),
);

Widget debugStory(BuildContext context) => StoryResult(
  label: storyText(context, 'debug_menu'),
  onOpen: (context) => showSafaeh<void>(
    context: context,
    useRootNavigator: false,
    title: storyText(context, 'debug_menu'),
    child: SizedBox(
      height: 400,
      child: SafaehDebugMenuBody(
        identity: SafaehDebugIdentityCard(
          title: storyText(context, 'app_title'),
          package: 'safaeh',
          version: 'preview',
        ),
        statusMessage: storyText(context, 'chrome_ready'),
        sections: [
          SafaehDebugSection(
            title: storyText(context, 'settings'),
            icon: Icons.settings,
            initiallyExpanded: true,
            children: [
              SafaehDebugActionTile(
                icon: Icons.refresh,
                label: storyText(context, 'try_again'),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
