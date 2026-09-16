import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/value_objects/account_field.dart';
import '../../domain/value_objects/google_signup_ticket.dart';
import '../../domain/value_objects/user_type.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/signup_cubit.dart';
import '../cubit/signup_state.dart';
import '../cubit/signup_steps.dart';
import '../formatters/profile_field_formatters.dart';
import '../formatters/signup_input_formatters.dart';
import '../mappers/account_failure_l10n.dart';
import '../widgets/account_text_field.dart';
import '../widgets/auth_page_chrome.dart';
import '../widgets/password_requirements_checklist.dart';
import '../widgets/personal_data_gender_chips.dart';
import 'account_type_page.dart';
import 'email_code_verification_page.dart';

Future<void> openPasswordSignup(BuildContext context, UserType type) {
  return openSignup(context, type);
}

Future<void> openSignup(
  BuildContext context,
  UserType type, {
  GoogleSignupTicket? googleTicket,
}) {
  final startSession = context.read<AuthCubit>().startSession;
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => getIt<SignupCubit>(
          param1: SignupEntry(type: type, googleTicket: googleTicket),
          param2: startSession,
        ),
        child: const SignupPage(),
      ),
    ),
  );
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<SignupCubit, SignupState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure ||
          previous.status != current.status,
      listener: presentSignupOutcome,
      builder: (context, state) {
        final cubit = context.read<SignupCubit>();
        return PopScope(
          canPop: state.isFirstStep,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.previousStep();
          },
          child: Scaffold(
            backgroundColor: VanepColors.card,
            appBar: const AuthAppBar(),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    key: ValueKey(state.currentStep),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      SignupStepHeader(state: state),
                      SignupStepFields(state: state),
                    ],
                  ),
                ),
                AuthBottomBar(
                  child: VanepPrimaryButton(
                    label: state.isLastStep
                        ? l10n.signupCreateAccount
                        : l10n.signupContinue,
                    isLoading: state.isSubmitting,
                    onPressed: state.isLastStep ? cubit.submit : cubit.nextStep,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void presentSignupOutcome(BuildContext context, SignupState state) {
  final l10n = AppLocalizations.of(context)!;
  final failure = state.failure;
  if (failure != null) {
    VanepFeedback.showError(context, accountFailureMessage(l10n, failure));
    context.read<SignupCubit>().clearFailure();
    if (failure is InvalidSignupTicketAccountFailure) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    return;
  }
  if (state.status == SignupStatus.registeredWithoutSession) {
    VanepFeedback.showInfo(context, l10n.signupGoogleRegisteredSignIn);
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }
  if (state.isCompleted) {
    openEmailCodeVerification(
      context,
      email: state.form.email,
      password: state.form.password,
      codeAlreadySent: true,
      replaceCurrent: true,
    );
  }
}

String signupTitle(AppLocalizations l10n, UserType type) {
  return switch (type) {
    UserType.driver => l10n.signupTitleDriver,
    UserType.assistant => l10n.signupTitleAssistant,
    UserType.client || UserType.admin => l10n.signupTitleClient,
  };
}

String signupStepTitle(AppLocalizations l10n, SignupStep step) {
  return switch (step) {
    SignupStep.access => l10n.signupSectionAccess,
    SignupStep.personal => l10n.signupSectionPersonal,
    SignupStep.professional => l10n.signupSectionProfessional,
    SignupStep.confirmation => l10n.signupStepConfirmationTitle,
  };
}

String signupStepSubtitle(AppLocalizations l10n, SignupStep step) {
  return switch (step) {
    SignupStep.access => l10n.signupStepAccessSubtitle,
    SignupStep.personal => l10n.signupStepPersonalSubtitle,
    SignupStep.professional => l10n.signupStepProfessionalSubtitle,
    SignupStep.confirmation => l10n.signupStepConfirmationSubtitle,
  };
}

class SignupStepHeader extends StatelessWidget {
  const SignupStepHeader({required this.state, super.key});

  final SignupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalSteps = state.steps.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                signupTitle(l10n, state.form.type),
                style: VanepTypography.fieldLabel.copyWith(
                  color: VanepColors.action,
                ),
              ),
            ),
            Text(
              l10n.signupStepProgress(state.stepIndex + 1, totalSteps),
              style: VanepTypography.cardSubtitle,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SignupStepProgressBar(
          completedSteps: state.stepIndex + 1,
          totalSteps: totalSteps,
        ),
        const SizedBox(height: 28),
        AuthPageHeader(
          title: signupStepTitle(l10n, state.currentStep),
          subtitle: signupStepSubtitle(l10n, state.currentStep),
        ),
      ],
    );
  }
}

class SignupStepProgressBar extends StatelessWidget {
  const SignupStepProgressBar({
    required this.completedSteps,
    required this.totalSteps,
    super.key,
  });

  final int completedSteps;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var stepIndex = 0; stepIndex < totalSteps; stepIndex++) ...[
          if (stepIndex > 0) const SizedBox(width: 6),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              decoration: BoxDecoration(
                color: stepIndex < completedSteps
                    ? VanepColors.action
                    : VanepColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SignupStepFields extends StatelessWidget {
  const SignupStepFields({required this.state, super.key});

  final SignupState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.currentStep) {
      SignupStep.access => SignupCredentialFields(state: state),
      SignupStep.personal => SignupPersonalFields(state: state),
      SignupStep.professional => SignupProfessionalFields(state: state),
      SignupStep.confirmation => SignupConfirmation(state: state),
    };
  }
}

class SignupCredentialFields extends StatelessWidget {
  const SignupCredentialFields({required this.state, super.key});

  final SignupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SignupCubit>();
    String? issueOf(AccountField field) =>
        accountFieldIssueMessageOrNull(l10n, state.issues, field);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: withSpacing([
          AccountTextField(
            label: l10n.signupFieldName,
            initialValue: state.form.name,
            onChanged: cubit.updateName,
            errorText: issueOf(AccountField.name),
            hintText: l10n.signupNameHint,
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            autofillHints: const [AutofillHints.name],
          ),
          AccountTextField(
            label: l10n.loginEmailLabel,
            initialValue: state.form.email,
            onChanged: cubit.updateEmail,
            errorText: issueOf(AccountField.email),
            hintText: l10n.loginEmailHint,
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccountTextField(
                label: l10n.loginPasswordLabel,
                initialValue: state.form.password,
                onChanged: cubit.updatePassword,
                errorText: issueOf(AccountField.password),
                hintText: l10n.signupPasswordHint,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 4),
              PasswordRequirementsChecklist(
                password: state.form.password,
                highlightUnmet: state.issues.containsKey(AccountField.password),
              ),
            ],
          ),
          AccountTextField(
            label: l10n.signupFieldPasswordConfirmation,
            initialValue: state.form.passwordConfirmation,
            onChanged: cubit.updatePasswordConfirmation,
            errorText: issueOf(AccountField.passwordConfirmation),
            hintText: l10n.signupPasswordConfirmationHint,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
          ),
        ], 20),
      ),
    );
  }
}

class SignupPersonalFields extends StatelessWidget {
  const SignupPersonalFields({required this.state, super.key});

  final SignupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SignupCubit>();
    final form = state.form;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: withSpacing([
        AccountTextField(
          label: l10n.signupFieldDocument,
          initialValue: form.document,
          onChanged: cubit.updateDocument,
          errorText: accountFieldIssueMessageOrNull(
            l10n,
            state.issues,
            AccountField.document,
          ),
          hintText: l10n.signupDocumentHint,
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: const [CpfInputFormatter()],
        ),
        AccountTextField(
          label: l10n.signupFieldPhone,
          initialValue: form.phone,
          onChanged: cubit.updatePhone,
          hintText: l10n.signupPhoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: const [ProfilePhoneInputFormatter()],
        ),
        SignupBirthDateField(
          value: form.birthDate,
          onChanged: cubit.updateBirthDate,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.signupFieldGender, style: VanepTypography.fieldLabel),
            const SizedBox(height: 8),
            PersonalDataGenderChips(
              value: form.gender,
              onChanged: cubit.updateGender,
            ),
          ],
        ),
      ], 20),
    );
  }
}

class SignupProfessionalFields extends StatelessWidget {
  const SignupProfessionalFields({required this.state, super.key});

  final SignupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SignupCubit>();
    final form = state.form;
    String? issueOf(AccountField field) =>
        accountFieldIssueMessageOrNull(l10n, state.issues, field);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: withSpacing([
        AuthFieldRow(
          children: [
            AccountTextField(
              label: l10n.signupFieldBasePrice,
              initialValue: form.basePrice,
              onChanged: cubit.updateBasePrice,
              errorText: issueOf(AccountField.basePrice),
              hintText: l10n.signupBasePriceHint,
              prefixIcon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: decimalInputFormatters,
            ),
            AccountTextField(
              label: l10n.signupFieldExperienceYears,
              initialValue: form.experienceYears,
              onChanged: cubit.updateExperienceYears,
              errorText: issueOf(AccountField.experienceYears),
              hintText: l10n.signupExperienceYearsHint,
              prefixIcon: Icons.work_history_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        AccountTextField(
          label: l10n.signupFieldCnpj,
          initialValue: form.cnpj,
          onChanged: cubit.updateCnpj,
          hintText: l10n.signupCnpjHint,
          prefixIcon: Icons.business_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
      ], 20),
    );
  }
}

class SignupConfirmation extends StatelessWidget {
  const SignupConfirmation({required this.state, super.key});

  final SignupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final googleTicket = state.googleTicket;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SignupAccountSummary(
          name: googleTicket?.name ?? state.form.name.trim(),
          email: googleTicket?.email ?? state.form.email.trim(),
          type: state.form.type,
        ),
        const SizedBox(height: 16),
        SignupTermsField(
          accepted: state.form.acceptTerms,
          onChanged: context.read<SignupCubit>().updateAcceptTerms,
          errorText: accountFieldIssueMessageOrNull(
            l10n,
            state.issues,
            AccountField.acceptTerms,
          ),
        ),
      ],
    );
  }
}

class SignupAccountSummary extends StatelessWidget {
  const SignupAccountSummary({
    required this.name,
    required this.email,
    required this.type,
    super.key,
  });

  final String name;
  final String email;
  final UserType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthOutlinedPanel(
      child: Row(
        children: [
          AuthIconBadge(icon: accountTypeIcon(type)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: VanepTypography.cardTitle),
                const SizedBox(height: 2),
                Text(email, style: VanepTypography.cardSubtitle),
                const SizedBox(height: 6),
                Text(
                  accountTypeLabel(l10n, type),
                  style: VanepTypography.cardSubtitle.copyWith(
                    color: VanepColors.action,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignupBirthDateField extends StatefulWidget {
  const SignupBirthDateField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  State<SignupBirthDateField> createState() => _SignupBirthDateFieldState();
}

class _SignupBirthDateFieldState extends State<SignupBirthDateField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showDate(widget.value);
  }

  @override
  void didUpdateWidget(SignupBirthDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) showDate(widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void showDate(DateTime? date) {
    final locale = Localizations.localeOf(context);
    _controller.text = date == null
        ? ''
        : formatProfileBirthDate(date.toIso8601String(), locale, '');
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepTextField(
      label: l10n.signupFieldBirthDate,
      controller: _controller,
      onChanged: (_) {},
      hintText: l10n.signupBirthDateHint,
      prefixIcon: Icons.calendar_today_outlined,
      readOnly: true,
      onTap: pickDate,
    );
  }
}

class SignupTermsField extends StatelessWidget {
  const SignupTermsField({
    required this.accepted,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final errorText = this.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthOutlinedPanel(
          highlighted: accepted,
          onTap: () => onChanged(!accepted),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: accepted,
                  onChanged: (value) => onChanged(value ?? false),
                  activeColor: VanepColors.action,
                  checkColor: VanepColors.card,
                  side: BorderSide(
                    color: errorText == null
                        ? VanepColors.textSecondary
                        : VanepColors.danger,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.signupAcceptTerms,
                  style: VanepTypography.fieldValue,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.danger,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
