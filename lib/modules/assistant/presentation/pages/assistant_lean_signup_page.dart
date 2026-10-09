import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/formatters/signup_input_formatters.dart';
import '../../../auth/presentation/widgets/password_requirements_checklist.dart';
import '../cubit/assistant_invite_cubit.dart';
import '../cubit/assistant_invite_state.dart';
import '../mappers/assistant_failure_l10n.dart';

class AssistantLeanSignupPage extends StatefulWidget {
  const AssistantLeanSignupPage({super.key});

  @override
  State<AssistantLeanSignupPage> createState() =>
      _AssistantLeanSignupPageState();
}

class _AssistantLeanSignupPageState extends State<AssistantLeanSignupPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emailController;
  late final TextEditingController _cpfController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordConfirmationController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AssistantInviteCubit>();
    _nameController = TextEditingController(text: cubit.state.name);
    _birthDateController = TextEditingController(
      text: cubit.state.birthDate == null
          ? ''
          : _formatDate(cubit.state.birthDate!),
    );
    _emailController = TextEditingController(text: cubit.state.email);
    _cpfController = TextEditingController(text: cubit.state.cpf);
    _passwordController = TextEditingController(text: cubit.state.password);
    _passwordConfirmationController =
        TextEditingController(text: cubit.state.passwordConfirmation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickBirthDate() async {
    final cubit = context.read<AssistantInviteCubit>();
    final now = DateTime.now();
    final initial = cubit.state.birthDate ?? DateTime(now.year - 20, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      cubit.updateBirthDate(picked);
      _birthDateController.text = _formatDate(picked);
    }
  }

  String? _resolveFieldError(
    AppLocalizations l10n,
    AssistantInviteState state,
    AssistantSignupField field,
  ) {
    final issue = state.fieldErrors[field];
    if (issue == null) return null;
    return switch (field) {
      AssistantSignupField.name => l10n.assistantSignupErrorNameRequired,
      AssistantSignupField.birthDate =>
        issue == AssistantSignupFieldError.underage
            ? l10n.assistantSignupErrorBirthDateUnderage
            : l10n.assistantSignupErrorBirthDateRequired,
      AssistantSignupField.email => l10n.assistantSignupErrorEmailInvalid,
      AssistantSignupField.cpf => l10n.assistantSignupErrorCpfInvalid,
      AssistantSignupField.password =>
        l10n.assistantSignupErrorPasswordRequired,
      AssistantSignupField.passwordConfirmation =>
        l10n.assistantSignupErrorPasswordMismatch,
      AssistantSignupField.acceptTerms =>
        l10n.assistantSignupErrorTermsRequired,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AssistantInviteCubit>();

    return BlocConsumer<AssistantInviteCubit, AssistantInviteState>(
      listenWhen: (previous, current) =>
          previous.step != current.step ||
          previous.signupFailure != current.signupFailure,
      listener: (context, state) {
        if (state.step == AssistantInviteStep.success) {
          VanepFeedback.showInfo(context, l10n.assistantSignupSuccess);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state.signupFailure != null) {
          VanepFeedback.showError(
            context,
            assistantFailureMessage(l10n, state.signupFailure!),
          );
        }
      },
      builder: (context, state) {
        final invite = state.invite;

        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: const VanepAppBar(),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                VanepPageHeader(
                  title: l10n.assistantSignupTitle,
                  subtitle: l10n.assistantSignupSubtitle,
                ),
                if (invite != null) ...[
                  VanepOutlinedPanel(
                    child: Row(
                      children: [
                        const VanepIconBadge(
                          icon: Icons.airport_shuttle_outlined,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.assistantSignupInvitedBy(
                                  invite.driverName,
                                ),
                                style: VanepTypography.cardTitle,
                              ),
                              if (invite.vehicleDescription != null &&
                                  invite.vehicleDescription!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  l10n.assistantSignupVehicle(
                                    invite.vehicleDescription!,
                                  ),
                                  style: VanepTypography.cardSubtitle,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                VanepTextField(
                  label: l10n.assistantSignupFieldName,
                  hintText: l10n.assistantSignupNameHint,
                  controller: _nameController,
                  errorText: _resolveFieldError(
                    l10n,
                    state,
                    AssistantSignupField.name,
                  ),
                  onChanged: cubit.updateName,
                  autofillHints: const [AutofillHints.name],
                  enabled: !state.isSubmittingSignup,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: state.isSubmittingSignup ? null : _pickBirthDate,
                  behavior: HitTestBehavior.opaque,
                  child: AbsorbPointer(
                    child: VanepTextField(
                      label: l10n.assistantSignupFieldBirthDate,
                      hintText: l10n.assistantSignupBirthDateHint,
                      controller: _birthDateController,
                      errorText: _resolveFieldError(
                        l10n,
                        state,
                        AssistantSignupField.birthDate,
                      ),
                      onChanged: (_) {},
                      readOnly: true,
                      enabled: !state.isSubmittingSignup,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                VanepTextField(
                  label: l10n.assistantSignupFieldEmail,
                  hintText: l10n.assistantSignupEmailHint,
                  controller: _emailController,
                  errorText: _resolveFieldError(
                    l10n,
                    state,
                    AssistantSignupField.email,
                  ),
                  onChanged: cubit.updateEmail,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  enabled: !state.isSubmittingSignup,
                ),
                const SizedBox(height: 16),
                VanepTextField(
                  label: l10n.assistantSignupFieldCpf,
                  hintText: l10n.assistantSignupCpfHint,
                  controller: _cpfController,
                  errorText: _resolveFieldError(
                    l10n,
                    state,
                    AssistantSignupField.cpf,
                  ),
                  onChanged: cubit.updateCpf,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [CpfInputFormatter()],
                  enabled: !state.isSubmittingSignup,
                ),
                const SizedBox(height: 16),
                VanepTextField(
                  label: l10n.assistantSignupFieldPassword,
                  hintText: l10n.assistantSignupPasswordHint,
                  controller: _passwordController,
                  errorText: _resolveFieldError(
                    l10n,
                    state,
                    AssistantSignupField.password,
                  ),
                  onChanged: cubit.updatePassword,
                  obscureText: true,
                  enabled: !state.isSubmittingSignup,
                ),
                const SizedBox(height: 8),
                PasswordRequirementsChecklist(
                  password: state.password,
                  highlightUnmet: state.fieldErrors.containsKey(
                    AssistantSignupField.password,
                  ),
                ),
                const SizedBox(height: 16),
                VanepTextField(
                  label: l10n.assistantSignupFieldPasswordConfirmation,
                  hintText: l10n.assistantSignupPasswordConfirmationHint,
                  controller: _passwordConfirmationController,
                  errorText: _resolveFieldError(
                    l10n,
                    state,
                    AssistantSignupField.passwordConfirmation,
                  ),
                  onChanged: cubit.updatePasswordConfirmation,
                  obscureText: true,
                  enabled: !state.isSubmittingSignup,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: state.acceptTerms,
                      onChanged: state.isSubmittingSignup
                          ? null
                          : (checked) =>
                              cubit.updateAcceptTerms(checked ?? false),
                      activeColor: VanepColors.action,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: state.isSubmittingSignup
                            ? null
                            : () => cubit.updateAcceptTerms(!state.acceptTerms),
                        child: Text(
                          l10n.assistantSignupAcceptTerms,
                          style: VanepTypography.cardSubtitle.copyWith(
                            color: state.fieldErrors.containsKey(
                              AssistantSignupField.acceptTerms,
                            )
                                ? VanepColors.danger
                                : VanepColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.fieldErrors.containsKey(
                  AssistantSignupField.acceptTerms,
                )) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      l10n.assistantSignupErrorTermsRequired,
                      style: VanepTypography.cardSubtitle.copyWith(
                        color: VanepColors.danger,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                VanepPrimaryButton(
                  label: l10n.assistantSignupSubmit,
                  isLoading: state.isSubmittingSignup,
                  onPressed: cubit.submitSignup,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
