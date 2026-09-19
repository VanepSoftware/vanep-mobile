import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/formatters/birth_date_formatter.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_glass_card.dart';
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
import '../formatters/profile_field_formatters.dart';
import '../formatters/signup_input_formatters.dart';
import '../mappers/account_failure_l10n.dart';
import '../widgets/account_text_field.dart';
import '../widgets/personal_data_gender_chips.dart';
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
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: AppBar(
            backgroundColor: VanepColors.surface,
            foregroundColor: VanepColors.textPrimary,
            elevation: 0,
            title: Text(
              signupTitle(l10n, state.form.type),
              style: VanepTypography.cardTitle,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    if (state.googleTicket case final googleTicket?)
                      GoogleAccountSummary(ticket: googleTicket)
                    else
                      SignupCredentialFields(state: state),
                    SignupProfileFields(state: state),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: VanepPrimaryButton(
                    label: l10n.signupCreateAccount,
                    isLoading: state.isSubmitting,
                    onPressed: context.read<SignupCubit>().submit,
                  ),
                ),
              ),
            ],
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
        children: [
          AccountTextField(
            label: l10n.signupFieldName,
            initialValue: state.form.name,
            onChanged: cubit.updateName,
            errorText: issueOf(AccountField.name),
            keyboardType: TextInputType.name,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: 16),
          AccountTextField(
            label: l10n.loginEmailLabel,
            initialValue: state.form.email,
            onChanged: cubit.updateEmail,
            errorText: issueOf(AccountField.email),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          AccountTextField(
            label: l10n.loginPasswordLabel,
            initialValue: state.form.password,
            onChanged: cubit.updatePassword,
            errorText: issueOf(AccountField.password),
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class SignupProfileFields extends StatelessWidget {
  const SignupProfileFields({required this.state, super.key});

  final SignupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SignupCubit>();
    final form = state.form;
    String? issueOf(AccountField field) =>
        accountFieldIssueMessageOrNull(l10n, state.issues, field);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccountTextField(
          label: l10n.signupFieldDocument,
          initialValue: form.document,
          onChanged: cubit.updateDocument,
          errorText: issueOf(AccountField.document),
          keyboardType: TextInputType.number,
          inputFormatters: const [CpfInputFormatter()],
        ),
        if (form.isDriver) ...[
          const SizedBox(height: 16),
          AccountTextField(
            label: l10n.signupFieldBasePrice,
            initialValue: form.basePrice,
            onChanged: cubit.updateBasePrice,
            errorText: issueOf(AccountField.basePrice),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInputFormatters,
          ),
          const SizedBox(height: 16),
          AccountTextField(
            label: l10n.signupFieldCnpj,
            initialValue: form.cnpj,
            onChanged: cubit.updateCnpj,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AccountTextField(
            label: l10n.signupFieldExperienceYears,
            initialValue: form.experienceYears,
            onChanged: cubit.updateExperienceYears,
            errorText: issueOf(AccountField.experienceYears),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
        const SizedBox(height: 16),
        AccountTextField(
          label: l10n.signupFieldPhone,
          initialValue: form.phone,
          onChanged: cubit.updatePhone,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: const [ProfilePhoneInputFormatter()],
        ),
        const SizedBox(height: 16),
        SignupBirthDateField(
          value: form.birthDate,
          onChanged: cubit.updateBirthDate,
        ),
        const SizedBox(height: 16),
        Text(l10n.signupFieldGender, style: VanepTypography.cardSubtitle),
        const SizedBox(height: 8),
        PersonalDataGenderChips(
          value: form.gender,
          onChanged: cubit.updateGender,
        ),
        const SizedBox(height: 12),
        SignupTermsField(
          accepted: form.acceptTerms,
          onChanged: cubit.updateAcceptTerms,
          errorText: issueOf(AccountField.acceptTerms),
        ),
      ],
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
        : formatBirthDate(date.toIso8601String(), locale, '');
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
    return VanepTextField(
      label: AppLocalizations.of(context)!.signupFieldBirthDate,
      controller: _controller,
      onChanged: (_) {},
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged(!accepted),
          child: Row(
            children: [
              Checkbox(
                value: accepted,
                onChanged: (value) => onChanged(value ?? false),
                activeColor: VanepColors.brand,
                checkColor: VanepColors.backgroundDeep,
                side: const BorderSide(color: VanepColors.textSecondary),
              ),
              Expanded(
                child: Text(
                  l10n.signupAcceptTerms,
                  style: VanepTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
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

class GoogleAccountSummary extends StatelessWidget {
  const GoogleAccountSummary({required this.ticket, super.key});

  final GoogleSignupTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: VanepGlassCard(
        child: Row(
          children: [
            const Icon(Icons.account_circle_outlined, color: VanepColors.brand),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.name, style: VanepTypography.cardTitle),
                  const SizedBox(height: 2),
                  Text(ticket.email, style: VanepTypography.cardSubtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
