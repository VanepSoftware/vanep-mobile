import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/formatters/birth_date_formatter.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_gender_select.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_read_only_field.dart';
import '../../../../core/ui/vanep_skeleton.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/value_objects/profile_field_limits.dart';
import '../cubit/personal_data_cubit.dart';
import '../cubit/personal_data_state.dart';
import '../formatters/profile_field_formatters.dart';
import '../mappers/personal_address_failure_l10n.dart';
import '../mappers/profile_edit_failure_l10n.dart';
import '../widgets/email_change_sheet.dart';
import '../widgets/personal_address_card.dart';

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
        if (feedback == null || !context.mounted) return;
        if (feedback is PersonalDataAddressSaveFailureFeedback &&
            !(ModalRoute.of(context)?.isCurrent ?? true)) {
          return;
        }
        presentPersonalDataFeedback(context, l10n, locale, feedback);
        context.read<PersonalDataCubit>().clearFeedback();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: const VanepAppBar(),
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
    return const PersonalDataSkeleton();
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
            VanepPrimaryButton(
              label: l10n.profileEditRetry,
              onPressed: () => context.read<PersonalDataCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  final cubit = context.read<PersonalDataCubit>();
  final profile = state.profile!;

  return Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            VanepPageHeader(
              title: l10n.profilePersonalData,
              subtitle: l10n.personalDataSubtitle,
            ),
            if (profile.pendingEmail != null) ...[
              PendingEmailBanner(email: profile.pendingEmail!),
              const SizedBox(height: 20),
            ],
            VanepOutlinedPanel(
              child: PersonalDataFields(
                profile: profile,
                state: state,
                locale: locale,
                nameController: nameController,
                phoneController: phoneController,
              ),
            ),
            const SizedBox(height: 16),
            PersonalAddressCard(address: state.address),
          ],
        ),
      ),
      VanepBottomBar(
        child: VanepPrimaryButton(
          label: l10n.profileSave,
          isLoading: state.isSaving,
          onPressed: state.isProfileDirty ? cubit.save : null,
        ),
      ),
    ],
  );
}

/// Number of fields [PersonalDataFields] renders, mirrored by the placeholder
/// so the panel keeps its height once the profile arrives.
const int personalDataFieldCount = 6;

/// Placeholder that mirrors the personal-data form while the profile loads.
///
/// The header is the real one: its copy is static, so there is nothing to
/// wait for. Only the panels, which the API fills, are boned.
class PersonalDataSkeleton extends StatelessWidget {
  const PersonalDataSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepSkeleton(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          VanepPageHeader(
            title: l10n.profilePersonalData,
            subtitle: l10n.personalDataSubtitle,
          ),
          VanepOutlinedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: withSpacing([
                for (
                  var fieldIndex = 0;
                  fieldIndex < personalDataFieldCount;
                  fieldIndex++
                )
                  const PersonalDataFieldSkeleton(),
              ], 20),
            ),
          ),
          const SizedBox(height: 16),
          const VanepOutlinedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 2, fontSize: 16),
                SizedBox(height: 12),
                Bone.text(words: 4, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label above a field-sized box, the shape every row of the form takes.
class PersonalDataFieldSkeleton extends StatelessWidget {
  const PersonalDataFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: 96, fontSize: 13),
        SizedBox(height: 8),
        Bone(height: 48, borderRadius: BorderRadius.all(Radius.circular(10))),
      ],
    );
  }
}

class PersonalDataFields extends StatelessWidget {
  const PersonalDataFields({
    required this.profile,
    required this.state,
    required this.locale,
    required this.nameController,
    required this.phoneController,
    super.key,
  });

  final UserProfile profile;
  final PersonalDataState state;
  final Locale locale;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PersonalDataCubit>();
    final empty = l10n.profileFieldEmpty;
    final nameCooldown = profile.nameChangeAvailableAt;
    final phoneCooldown = profile.phoneChangeAvailableAt;
    final emailCooldown = profile.emailChangeAvailableAt;
    final canChangeEmail =
        profile.pendingEmail == null &&
        emailCooldown == null &&
        !state.isEmailSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: withSpacing([
        CooldownField(
          cooldown: nameCooldown,
          child: nameCooldown == null
              ? VanepTextField(
                  label: l10n.profileFieldName,
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
              : VanepReadOnlyField(
                  label: l10n.profileFieldName,
                  value: profileDisplayOrEmpty(profile.name, empty),
                  enabled: false,
                ),
        ),
        CooldownField(
          cooldown: emailCooldown,
          child: VanepReadOnlyField(
            label: l10n.profileFieldEmail,
            value: profileDisplayOrEmpty(profile.email, empty),
            enabled: canChangeEmail,
            onTap: canChangeEmail ? () => showEmailChangeSheet(context) : null,
          ),
        ),
        CooldownField(
          cooldown: phoneCooldown,
          child: phoneCooldown == null
              ? VanepTextField(
                  label: l10n.profileFieldPhone,
                  controller: phoneController,
                  onChanged: cubit.updatePhone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: const [ProfilePhoneInputFormatter()],
                  errorText: profileFieldErrorMessage(
                    l10n,
                    state.fieldErrors['phone'],
                  ),
                )
              : VanepReadOnlyField(
                  label: l10n.profileFieldPhone,
                  value: formatProfilePhone(profile.phone, empty),
                  enabled: false,
                ),
        ),
        VanepReadOnlyField(
          label: l10n.profileFieldDocument,
          value: formatProfileDocument(profile.document, empty),
          enabled: false,
        ),
        VanepReadOnlyField(
          label: l10n.profileFieldBirthDate,
          value: formatBirthDate(profile.birthDate, locale, empty),
          enabled: false,
        ),
        VanepGenderSelect(
          label: l10n.profileFieldGender,
          value: state.draftGender,
          onChanged: cubit.updateGender,
        ),
      ], 20),
    );
  }
}

class CooldownField extends StatelessWidget {
  const CooldownField({required this.cooldown, required this.child, super.key});

  final DateTime? cooldown;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final target = cooldown;
    if (target == null) return child;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: 8),
        CooldownBadge(
          text: l10n.profileCooldownDaysRemaining(
            profileCooldownDaysRemaining(target),
          ),
        ),
      ],
    );
  }
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
    case PersonalDataAddressClearedFeedback():
      VanepFeedback.showInfo(context, l10n.personalAddressClearSuccess);
    case PersonalDataAddressFailureFeedback(:final failure) ||
        PersonalDataAddressSaveFailureFeedback(:final failure):
      VanepFeedback.showError(
        context,
        personalAddressFailureMessage(l10n, failure),
      );
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
        borderRadius: BorderRadius.circular(12),
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

class CooldownBadge extends StatelessWidget {
  const CooldownBadge({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
