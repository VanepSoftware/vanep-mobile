import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/reset_password_with_code.dart';
import '../../domain/value_objects/account_field.dart';
import '../cubit/email_code_verification_state.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';
import '../mappers/account_failure_l10n.dart';
import '../widgets/account_text_field.dart';
import '../widgets/verification_code_field.dart';
import 'email_code_verification_page.dart';

Future<void> openPasswordReset(
  BuildContext context, {
  required String initialEmail,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => getIt<PasswordResetCubit>(param1: initialEmail.trim()),
        child: const PasswordResetPage(),
      ),
    ),
  );
}

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback ||
          previous.status != current.status,
      listener: presentPasswordResetOutcome,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: AppBar(
            backgroundColor: VanepColors.surface,
            foregroundColor: VanepColors.textPrimary,
            elevation: 0,
            title: Text(
              l10n.passwordResetTitle,
              style: VanepTypography.cardTitle,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              switch (state.step) {
                PasswordResetStep.email => PasswordResetEmailStep(state: state),
                PasswordResetStep.code => PasswordResetCodeStep(state: state),
              },
            ],
          ),
        );
      },
    );
  }
}

void presentPasswordResetOutcome(
  BuildContext context,
  PasswordResetState state,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (state.feedback) {
    case CodeResentFeedback():
      VanepFeedback.showInfo(context, l10n.codeResent);
      context.read<PasswordResetCubit>().clearFeedback();
    case AccountFailureCodeFeedback(:final failure):
      VanepFeedback.showError(context, accountFailureMessage(l10n, failure));
      context.read<PasswordResetCubit>().clearFeedback();
    case null:
      break;
  }
  if (state.status == PasswordResetStatus.completed) {
    VanepFeedback.showInfo(context, l10n.passwordResetDone);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class PasswordResetEmailStep extends StatelessWidget {
  const PasswordResetEmailStep({required this.state, super.key});

  final PasswordResetState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PasswordResetCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.passwordResetEmailHint,
          style: VanepTypography.cardSubtitle.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 20),
        AccountTextField(
          label: l10n.loginEmailLabel,
          initialValue: state.email,
          onChanged: cubit.updateEmail,
          enabled: !state.isSubmitting,
          errorText: accountFieldIssueMessageOrNull(
            l10n,
            state.issues,
            AccountField.email,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 24),
        VanepPrimaryButton(
          label: l10n.passwordResetSendCode,
          isLoading: state.isSubmitting,
          onPressed: cubit.requestCode,
        ),
      ],
    );
  }
}

class PasswordResetCodeStep extends StatelessWidget {
  const PasswordResetCodeStep({required this.state, super.key});

  final PasswordResetState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PasswordResetCubit>();
    String? issueOf(AccountField field) => accountFieldIssueMessageOrNull(
      l10n,
      state.issues,
      field,
      passwordMinLength: PasswordResetRules.newPasswordMinLength,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.passwordResetCodeSentTo(state.email.trim()),
          style: VanepTypography.cardSubtitle.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 20),
        VerificationCodeField(
          label: l10n.verificationCodeLabel,
          initialValue: state.code,
          onChanged: cubit.updateCode,
          enabled: !state.isSubmitting,
          errorText: issueOf(AccountField.code),
        ),
        const SizedBox(height: 16),
        AccountTextField(
          label: l10n.passwordResetNewPasswordLabel,
          initialValue: state.newPassword,
          onChanged: cubit.updateNewPassword,
          enabled: !state.isSubmitting,
          errorText: issueOf(AccountField.password),
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 24),
        VanepPrimaryButton(
          label: l10n.passwordResetSubmit,
          isLoading: state.isSubmitting,
          onPressed: cubit.resetPassword,
        ),
        const SizedBox(height: 8),
        Center(
          child: ResendCodeButton(
            secondsLeft: state.resendSecondsLeft,
            onPressed: state.canResend ? cubit.resend : null,
          ),
        ),
      ],
    );
  }
}
