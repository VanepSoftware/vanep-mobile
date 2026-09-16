import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_glass_card.dart';
import '../../../../core/ui/vanep_gradient_background.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../core/ui/vanep_wordmark.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../mappers/auth_failure_l10n.dart';
import 'account_type_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final state = context.read<LoginCubit>().state;
    _emailController = TextEditingController(text: state.email);
    _passwordController = TextEditingController(text: state.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VanepGradientBackground(
        child: SafeArea(
          child: BlocConsumer<LoginCubit, LoginState>(
            listenWhen: (previous, current) =>
                previous.failure != current.failure && current.failure != null,
            listener: presentLoginFailure,
            builder: (context, state) => LoginForm(
              state: state,
              emailController: _emailController,
              passwordController: _passwordController,
            ),
          ),
        ),
      ),
    );
  }
}

void presentLoginFailure(BuildContext context, LoginState state) {
  final failure = state.failure;
  if (failure == null) return;
  final l10n = AppLocalizations.of(context)!;
  VanepFeedback.showError(context, authFailureMessage(l10n, failure));
  context.read<LoginCubit>().clearFailure();
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.state,
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  final LoginState state;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<LoginCubit>();
    final editable = !state.isSubmitting;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      children: [
        const Center(child: VanepWordmark()),
        const SizedBox(height: 16),
        Text(
          l10n.welcomeTagline,
          textAlign: TextAlign.center,
          style: VanepTypography.tagline.copyWith(
            color: VanepColors.foreground.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 40),
        VanepGlassCard(
          padding: const EdgeInsets.all(20),
          child: AutofillGroup(
            child: Column(
              children: [
                VanepTextField(
                  label: l10n.loginEmailLabel,
                  controller: emailController,
                  onChanged: cubit.updateEmail,
                  enabled: editable,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 16),
                VanepTextField(
                  label: l10n.loginPasswordLabel,
                  controller: passwordController,
                  onChanged: cubit.updatePassword,
                  enabled: editable,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                ),
                const SizedBox(height: 24),
                VanepPrimaryButton(
                  label: l10n.loginTitle,
                  isLoading: state.isSubmitting,
                  onPressed: state.canSubmit ? cubit.submitPassword : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: editable ? () => openAccountTypeChoice(context) : null,
          style: TextButton.styleFrom(foregroundColor: VanepColors.foreground),
          child: Text(l10n.signupCreateAccount),
        ),
      ],
    );
  }
}
