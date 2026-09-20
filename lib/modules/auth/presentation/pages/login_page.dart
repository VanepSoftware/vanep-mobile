import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_secondary_button.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../core/ui/vanep_wordmark.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/auth_failure.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../mappers/auth_failure_l10n.dart';
import 'account_type_page.dart';
import 'email_code_verification_page.dart';
import 'password_reset_page.dart';
import 'signup_page.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: VanepColors.card,
        body: SafeArea(
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
  context.read<LoginCubit>().clearFailure();
  if (failure is RegistrationRequiredAuthFailure) {
    openAccountTypeChoice(
      context,
      onTypeSelected: (context, type) =>
          openSignup(context, type, googleTicket: failure.ticket),
    );
    return;
  }
  if (failure is EmailNotVerifiedAuthFailure) {
    openEmailCodeVerification(
      context,
      email: state.email,
      password: state.password,
      codeAlreadySent: false,
    );
    return;
  }
  final l10n = AppLocalizations.of(context)!;
  VanepFeedback.showError(context, authFailureMessage(l10n, failure));
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: VanepWordmark(
                    color: VanepColors.textPrimary,
                    fontSize: 44,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  l10n.loginHeading,
                  textAlign: TextAlign.center,
                  style: VanepTypography.loginTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: VanepTypography.cardSubtitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 36),
                VanepTextField(
                  label: l10n.loginEmailLabel,
                  controller: emailController,
                  onChanged: cubit.updateEmail,
                  enabled: editable,
                  hintText: l10n.loginEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 20),
                VanepTextField(
                  label: l10n.loginPasswordLabel,
                  controller: passwordController,
                  onChanged: cubit.updatePassword,
                  enabled: editable,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => cubit.submitPassword(),
                ),
                const SizedBox(height: 28),
                VanepPrimaryButton(
                  label: l10n.loginTitle,
                  isLoading: state.isSubmittingPassword,
                  onPressed: state.canSubmit ? cubit.submitPassword : null,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: editable
                        ? () => openPasswordReset(
                            context,
                            initialEmail: state.email,
                          )
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: VanepColors.action,
                    ),
                    child: Text(
                      l10n.loginForgotPassword,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                LoginDivider(label: l10n.loginOrDivider),
                const SizedBox(height: 20),
                VanepSecondaryButton(
                  label: l10n.loginWithGoogle,
                  icon: Icons.account_circle_outlined,
                  isLoading: state.isSubmittingGoogle,
                  onPressed: editable ? cubit.signInWithGoogle : null,
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.loginNoAccount,
                      style: VanepTypography.cardSubtitle.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: editable
                          ? () => openAccountTypeChoice(context)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: VanepColors.action,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      child: Text(
                        l10n.signupCreateAccount,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginDivider extends StatelessWidget {
  const LoginDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: VanepColors.inputBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: VanepTypography.cardSubtitle),
        ),
        const Expanded(child: Divider(color: VanepColors.inputBorder)),
      ],
    );
  }
}
