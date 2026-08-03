import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/value_objects/profile_field_limits.dart';
import '../cubit/personal_data_cubit.dart';
import '../cubit/personal_data_state.dart';
import '../formatters/profile_field_formatters.dart';
import '../mappers/profile_edit_failure_l10n.dart';
import '../widgets/email_change_sheet.dart';
import '../widgets/personal_data_gender_chips.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage>
    with WidgetsBindingObserver {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  UserProfile? _boundProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      syncControllers(context.read<PersonalDataCubit>().state);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    final profile = context.read<PersonalDataCubit>().state.profile;
    if (profile?.pendingEmail == null) return;
    context.read<PersonalDataCubit>().refresh();
  }

  void syncControllers(PersonalDataState state) {
    final profile = state.profile;
    if (profile == null || identical(profile, _boundProfile)) return;
    _boundProfile = profile;
    if (_nameController.text != state.draftName) {
      _nameController.text = state.draftName;
    }
    final maskedPhone = formatProfilePhoneDigits(state.draftPhone);
    if (_phoneController.text != maskedPhone) {
      _phoneController.text = maskedPhone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return BlocConsumer<PersonalDataCubit, PersonalDataState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback ||
          previous.profile != current.profile,
      listener: (context, state) {
        syncControllers(state);
        final feedback = state.feedback;
        if (feedback == null) return;
        if (context.mounted) {
          presentPersonalDataFeedback(context, l10n, locale, feedback);
          context.read<PersonalDataCubit>().clearFeedback();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: AppBar(
            backgroundColor: VanepColors.surface,
            foregroundColor: VanepColors.textPrimary,
            elevation: 0,
            title: Text(
              l10n.profilePersonalData,
              style: VanepTypography.cardTitle,
            ),
          ),
          body: buildPersonalDataBody(
            context: context,
            l10n: l10n,
            locale: locale,
            state: state,
            nameController: _nameController,
            phoneController: _phoneController,
          ),
        );
      },
    );
  }
}

Widget buildPersonalDataBody({
  required BuildContext context,
  required AppLocalizations l10n,
  required Locale locale,
  required PersonalDataState state,
  required TextEditingController nameController,
  required TextEditingController phoneController,
}) {
  if (state.status == PersonalDataStatus.loading ||
      state.status == PersonalDataStatus.initial) {
    return const Center(child: CircularProgressIndicator());
  }

  if (state.status == PersonalDataStatus.loadFailed || state.profile == null) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.profileEditLoadError,
              textAlign: TextAlign.center,
              style: VanepTypography.cardSubtitle,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<PersonalDataCubit>().load(),
              child: Text(l10n.profileEditRetry),
            ),
          ],
        ),
      ),
    );
  }

  final profile = state.profile!;
  final empty = l10n.profileFieldEmpty;
  final nameCooldown = profile.nameChangeAvailableAt;
  final phoneCooldown = profile.phoneChangeAvailableAt;
  final emailCooldown = profile.emailChangeAvailableAt;
  final pendingEmail = profile.pendingEmail;
  final canChangeEmail =
      pendingEmail == null && emailCooldown == null && !state.isEmailSubmitting;
  final cubit = context.read<PersonalDataCubit>();

  return Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (pendingEmail != null) ...[
              PendingEmailBanner(email: pendingEmail),
              const SizedBox(height: 20),
            ],
            Material(
              color: VanepColors.card,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  PersonalDataRow(
                    label: l10n.profileFieldName,
                    isFirst: true,
                    cooldownText: nameCooldown == null
                        ? null
                        : l10n.profileCooldownDaysRemaining(
                            profileCooldownDaysRemaining(nameCooldown),
                          ),
                    child: nameCooldown == null
                        ? PersonalDataInlineField(
                            controller: nameController,
                            onChanged: cubit.updateName,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            maxLength: ProfileFieldLimits.nameMaxLength,
                            errorText: profileFieldErrorMessage(
                              l10n,
                              state.fieldErrors['name'],
                            ),
                          )
                        : PersonalDataStaticValue(
                            value: profileDisplayOrEmpty(profile.name, empty),
                          ),
                  ),
                  const PersonalDataRowDivider(),
                  PersonalDataRow(
                    label: l10n.profileFieldEmail,
                    trailing: TextButton(
                      onPressed: canChangeEmail
                          ? () => showEmailChangeSheet(context)
                          : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.profileChange,
                        style: VanepTypography.cardSubtitle.copyWith(
                          color: canChangeEmail
                              ? VanepColors.brand
                              : VanepColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    cooldownText: emailCooldown == null
                        ? null
                        : l10n.profileCooldownDaysRemaining(
                            profileCooldownDaysRemaining(emailCooldown),
                          ),
                    child: PersonalDataStaticValue(
                      value: profileDisplayOrEmpty(profile.email, empty),
                    ),
                  ),
                  const PersonalDataRowDivider(),
                  PersonalDataRow(
                    label: l10n.profileFieldPhone,
                    cooldownText: phoneCooldown == null
                        ? null
                        : l10n.profileCooldownDaysRemaining(
                            profileCooldownDaysRemaining(phoneCooldown),
                          ),
                    child: phoneCooldown == null
                        ? PersonalDataInlineField(
                            controller: phoneController,
                            onChanged: cubit.updatePhone,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            inputFormatters: const [
                              ProfilePhoneInputFormatter(),
                            ],
                            errorText: profileFieldErrorMessage(
                              l10n,
                              state.fieldErrors['phone'],
                            ),
                          )
                        : PersonalDataStaticValue(
                            value: formatProfilePhone(profile.phone, empty),
                          ),
                  ),
                  const PersonalDataRowDivider(),
                  PersonalDataRow(
                    label: l10n.profileFieldDocument,
                    child: PersonalDataStaticValue(
                      value: formatProfileDocument(profile.document, empty),
                      muted: true,
                    ),
                  ),
                  const PersonalDataRowDivider(),
                  PersonalDataRow(
                    label: l10n.profileFieldBirthDate,
                    child: PersonalDataStaticValue(
                      value: formatProfileBirthDate(
                        profile.birthDate,
                        locale,
                        empty,
                      ),
                      muted: true,
                    ),
                  ),
                  const PersonalDataRowDivider(),
                  PersonalDataRow(
                    label: l10n.profileFieldGender,
                    isLast: true,
                    child: PersonalDataGenderChips(
                      value: state.draftGender,
                      onChanged: cubit.updateGender,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: VanepPrimaryButton(
            label: l10n.profileSave,
            isLoading: state.isSaving,
            onPressed: state.canSave ? cubit.save : null,
          ),
        ),
      ),
    ],
  );
}

void presentPersonalDataFeedback(
  BuildContext context,
  AppLocalizations l10n,
  Locale locale,
  PersonalDataFeedback feedback,
) {
  switch (feedback) {
    case PersonalDataSaveSuccessFeedback():
      VanepFeedback.showInfo(context, l10n.profileEditSaveSuccess);
    case PersonalDataEmailChangeSuccessFeedback():
      break;
    case PersonalDataFailureFeedback(:final failure):
      final message = profileEditFailureMessage(
        l10n,
        failure,
        formattedRetryAfter: formattedRetryAfterFromFailure(failure, locale),
      );
      VanepFeedback.showError(context, message);
  }
}

String? formattedRetryAfterFromFailure(
  ProfileEditFailure failure,
  Locale locale,
) {
  if (failure is! StructuredProfileEditFailure) return null;
  final retryAfter = failure.retryAfter;
  if (retryAfter == null) return null;
  return formatProfileCooldownDate(retryAfter, locale);
}

class PendingEmailBanner extends StatelessWidget {
  const PendingEmailBanner({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: VanepColors.warningSurface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: VanepColors.warning, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            color: VanepColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.profilePendingEmailBanner(email),
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalDataRow extends StatelessWidget {
  const PersonalDataRow({
    required this.label,
    required this.child,
    this.trailing,
    this.cooldownText,
    this.isFirst = false,
    this.isLast = false,
    super.key,
  });

  final String label;
  final Widget child;
  final Widget? trailing;
  final String? cooldownText;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 18 : 14, 16, isLast ? 18 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: VanepTypography.cardSubtitle),
              if (cooldownText != null) ...[
                const SizedBox(width: 8),
                CooldownBadge(text: cooldownText!),
              ],
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class PersonalDataRowDivider extends StatelessWidget {
  const PersonalDataRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: VanepColors.divider,
    );
  }
}

class PersonalDataStaticValue extends StatelessWidget {
  const PersonalDataStaticValue({
    required this.value,
    this.muted = false,
    super.key,
  });

  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: VanepTypography.cardTitle.copyWith(
        color: muted ? VanepColors.textMuted : VanepColors.textPrimary,
      ),
    );
  }
}

class PersonalDataInlineField extends StatelessWidget {
  const PersonalDataInlineField({
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: VanepTypography.cardTitle,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.only(bottom: 6),
        counterText: '',
        errorText: errorText,
        errorStyle: VanepTypography.cardSubtitle.copyWith(
          color: VanepColors.danger,
          fontSize: 12,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VanepColors.brand, width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VanepColors.danger),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VanepColors.danger, width: 1.5),
        ),
      ),
    );
  }
}

class CooldownBadge extends StatelessWidget {
  const CooldownBadge({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: VanepColors.surface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 14, color: VanepColors.textMuted),
            const SizedBox(width: 5),
            Text(
              text,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
