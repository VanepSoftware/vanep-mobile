import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/email_code_verification_cubit.dart';
import '../cubit/email_code_verification_state.dart';
import '../mappers/account_failure_l10n.dart';
import '../widgets/verification_code_field.dart';

Future<void> openEmailCodeVerification(
  BuildContext context, {
  required String email,
  required String password,
  required bool codeAlreadySent,
  bool replaceCurrent = false,
}) {
  final startSession = context.read<AuthCubit>().startSession;
  final route = MaterialPageRoute<void>(
    builder: (_) => BlocProvider(
      create: (_) {
        final cubit = getIt<EmailCodeVerificationCubit>(
          param1: EmailCodeVerificationRequest(
            email: email.trim(),
            password: password,
          ),
          param2: startSession,
        );
        if (codeAlreadySent) cubit.startResendCooldown();
        return cubit;
      },
      child: const EmailCodeVerificationPage(),
    ),
  );
  final navigator = Navigator.of(context);
  return replaceCurrent
      ? navigator.pushReplacement(route)
      : navigator.push(route);
}

class EmailCodeVerificationPage extends StatelessWidget {
  const EmailCodeVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<EmailCodeVerificationCubit, EmailCodeVerificationState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback ||
          previous.status != current.status,
      listener: presentEmailCodeVerificationOutcome,
      builder: (context, state) {
        final cubit = context.read<EmailCodeVerificationCubit>();
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: AppBar(
            backgroundColor: VanepColors.surface,
            foregroundColor: VanepColors.textPrimary,
            elevation: 0,
            title: Text(
              l10n.emailVerificationTitle,
              style: VanepTypography.cardTitle,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                l10n.emailCodeSentTo(state.email),
                style: VanepTypography.cardSubtitle.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 20),
              VerificationCodeField(
                label: l10n.verificationCodeLabel,
                initialValue: state.code,
                onChanged: cubit.updateCode,
                enabled: state.isEditing,
              ),
              const SizedBox(height: 24),
              VanepPrimaryButton(
                label: l10n.emailVerificationSubmit,
                isLoading: !state.isEditing,
                onPressed: state.canVerify ? cubit.verify : null,
              ),
              const SizedBox(height: 8),
              ResendCodeButton(
                secondsLeft: state.resendSecondsLeft,
                onPressed: state.canResend ? cubit.resend : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

void presentEmailCodeVerificationOutcome(
  BuildContext context,
  EmailCodeVerificationState state,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (state.feedback) {
    case CodeResentFeedback():
      VanepFeedback.showInfo(context, l10n.codeResent);
      context.read<EmailCodeVerificationCubit>().clearFeedback();
    case AccountFailureCodeFeedback(:final failure):
      VanepFeedback.showError(context, accountFailureMessage(l10n, failure));
      context.read<EmailCodeVerificationCubit>().clearFeedback();
    case null:
      break;
  }
  if (state.status == EmailCodeVerificationStatus.verified) {
    VanepFeedback.showInfo(context, l10n.emailVerifiedSignIn);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class ResendCodeButton extends StatelessWidget {
  const ResendCodeButton({
    required this.secondsLeft,
    required this.onPressed,
    super.key,
  });

  final int secondsLeft;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: VanepColors.textPrimary),
      child: Text(
        secondsLeft > 0 ? l10n.resendCodeIn(secondsLeft) : l10n.resendCode,
      ),
    );
  }
}
