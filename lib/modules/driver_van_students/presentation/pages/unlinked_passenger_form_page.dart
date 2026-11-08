import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:vanep_mobile/core/ui/vanep_city_picker_sheet.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_filter_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_schedule_editor.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';
import 'package:vanep_mobile/core/ui/vanep_postal_address_form.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_state.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/formatters/van_student_labels.dart';

const unlinkedPassengerSectionSpacing = 20.0;

class UnlinkedPassengerFormPage extends StatelessWidget {
  const UnlinkedPassengerFormPage({required this.vanCaption, super.key});

  final String vanCaption;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<UnlinkedPassengerFormCubit>();

    return BlocListener<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
      listenWhen: (previous, current) =>
          current.status != previous.status ||
          current.saveFailure != previous.saveFailure ||
          current.schoolFailure != previous.schoolFailure,
      listener: (context, state) {
        if (state.status == UnlinkedPassengerFormStatus.saved) {
          Navigator.of(context).pop(state.draft.name.trim());
          return;
        }
        final saveFailure = state.saveFailure;
        if (saveFailure != null) {
          VanepFeedback.showError(
            context,
            driverStudentFailureMessage(l10n, saveFailure),
          );
        }
        final schoolFailure = state.schoolFailure;
        if (schoolFailure != null) {
          VanepFeedback.showError(
            context,
            schoolFailureLabel(l10n, schoolFailure),
          );
        }
      },
      child: Scaffold(
        backgroundColor: VanepColors.surface,
        appBar: VanepAppBar(
          title: l10n.unlinkedPassengerFormTitle,
          caption: vanCaption,
        ),
        bottomNavigationBar: VanepBottomBar(
          child:
              BlocBuilder<
                UnlinkedPassengerFormCubit,
                UnlinkedPassengerFormState
              >(
                builder: (context, state) => VanepPrimaryButton(
                  label: l10n.unlinkedPassengerSubmit,
                  isLoading: state.isSaving,
                  onPressed: state.blocksSave ? null : cubit.submit,
                ),
              ),
        ),
        body: const UnlinkedPassengerFormBody(),
      ),
    );
  }
}

class UnlinkedPassengerFormBody extends StatelessWidget {
  const UnlinkedPassengerFormBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              l10n.unlinkedPassengerFormIntro,
              style: VanepTypography.cardSubtitle,
            ),
            const SizedBox(height: unlinkedPassengerSectionSpacing),
            UnlinkedPassengerStudentSection(state: state),
            const SizedBox(height: unlinkedPassengerSectionSpacing),
            UnlinkedPassengerSchoolSection(state: state),
            const SizedBox(height: unlinkedPassengerSectionSpacing),
            UnlinkedPassengerPickupSection(state: state),
            const SizedBox(height: unlinkedPassengerSectionSpacing),
            UnlinkedPassengerScheduleSection(state: state),
            const SizedBox(height: unlinkedPassengerSectionSpacing),
            UnlinkedPassengerNotesSection(state: state),
          ],
        );
      },
    );
  }
}

class UnlinkedPassengerFieldError extends StatelessWidget {
  const UnlinkedPassengerFieldError({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: VanepTypography.cardSubtitle.copyWith(color: VanepColors.danger),
      ),
    );
  }
}

class UnlinkedPassengerStudentSection extends StatefulWidget {
  const UnlinkedPassengerStudentSection({required this.state, super.key});

  final UnlinkedPassengerFormState state;

  @override
  State<UnlinkedPassengerStudentSection> createState() =>
      UnlinkedPassengerStudentSectionState();
}

class UnlinkedPassengerStudentSectionState
    extends State<UnlinkedPassengerStudentSection> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;
    return VanepSection(
      title: l10n.unlinkedPassengerSectionStudent,
      child: VanepTextField(
        label: l10n.unlinkedPassengerNameLabel,
        controller: controller,
        isRequired: true,
        enabled: !state.isSaving,
        textInputAction: TextInputAction.next,
        maxLength: unlinkedPassengerNameMaxLength,
        errorText: unlinkedPassengerErrorText(l10n, state.visibleErrors, const [
          UnlinkedPassengerDraftError.nameRequired,
          UnlinkedPassengerDraftError.nameTooLong,
        ]),
        onChanged: context.read<UnlinkedPassengerFormCubit>().changeName,
      ),
    );
  }
}

class UnlinkedPassengerSchoolSection extends StatelessWidget {
  const UnlinkedPassengerSchoolSection({required this.state, super.key});

  final UnlinkedPassengerFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<UnlinkedPassengerFormCubit>();
    final school = state.draft.school;
    final schoolError = unlinkedPassengerErrorText(
      l10n,
      state.visibleErrors,
      const [UnlinkedPassengerDraftError.schoolRequired],
    );
    final shiftError = unlinkedPassengerErrorText(
      l10n,
      state.visibleErrors,
      const [UnlinkedPassengerDraftError.schoolShiftRequired],
    );

    return VanepSection(
      title: l10n.unlinkedPassengerSectionSchool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VanepPlaceAutocompleteField(
            controller: cubit.autocomplete,
            hint: l10n.unlinkedPassengerSchoolHint,
            clearOnSelect: false,
            enabled: !state.isSaving && !state.isResolvingSchool,
            emptyLabel: l10n.placeAutocompleteNoResults,
            networkErrorLabel: l10n.placeAutocompleteNetworkError,
            keyErrorLabel: l10n.placeAutocompleteKeyError,
            retryLabel: l10n.placeAutocompleteRetry,
            onSelected: (selection) => cubit.selectSchool(
              selection.suggestion,
              selection.sessionToken,
            ),
          ),
          if (state.isResolvingSchool)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(color: VanepColors.action),
            )
          else if (school != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: VanepColors.action,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(school.name, style: VanepTypography.cardTitle),
                  ),
                ],
              ),
            ),
          if (schoolError != null)
            UnlinkedPassengerFieldError(text: schoolError),
          const SizedBox(height: 16),
          Text(
            l10n.unlinkedPassengerSchoolShiftLabel,
            style: VanepTypography.fieldLabel,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final shift in SchoolShift.values)
                VanepFilterChip(
                  label: formatShift(l10n, shift),
                  isSelected: state.draft.schoolShift == shift,
                  onTap: () => cubit.selectSchoolShift(shift),
                ),
            ],
          ),
          if (shiftError != null) UnlinkedPassengerFieldError(text: shiftError),
        ],
      ),
    );
  }
}

class UnlinkedPassengerPickupSection extends StatelessWidget {
  const UnlinkedPassengerPickupSection({required this.state, super.key});

  final UnlinkedPassengerFormState state;

  Future<void> openCityPicker(BuildContext context) async {
    final cubit = context.read<UnlinkedPassengerFormCubit>();
    await cubit.refreshCities(cubit.state.draft.address.uf);
    if (!context.mounted) return;
    await showVanepCityPickerSheet(
      context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const UnlinkedPassengerCityPicker(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<UnlinkedPassengerFormCubit>();
    final cepFailure = state.cepFailure;

    return VanepSection(
      title: l10n.unlinkedPassengerSectionPickup,
      child: VanepPostalAddressForm(
        draft: state.draft.address,
        ufOptions: [for (final option in state.catalogStates) option.uf],
        showErrors: state.showErrors,
        isLookingUpCep: state.isLookingUpCep,
        enabled: !state.isSaving,
        zipErrorText: cepFailure == null
            ? null
            : cepFailureLabel(l10n, cepFailure),
        onZipChanged: cubit.changeZipCode,
        onStreetChanged: cubit.changeStreet,
        onNumberChanged: cubit.changeNumber,
        onComplementChanged: cubit.changeComplement,
        onNeighborhoodChanged: cubit.changeNeighborhood,
        onUfChanged: cubit.selectUf,
        onCityTap: () => openCityPicker(context),
      ),
    );
  }
}

class UnlinkedPassengerCityPicker extends StatelessWidget {
  const UnlinkedPassengerCityPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<UnlinkedPassengerFormCubit>();

    return BlocBuilder<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
      builder: (context, state) {
        final failure = state.catalogFailure;
        return VanepCityPickerSheet(
          options: [
            for (final city in state.catalogCities)
              VanepCityOption(token: city.token, name: city.name),
          ],
          selectedToken: state.draft.address.cityToken,
          errorText: failure == null
              ? null
              : catalogFailureLabel(l10n, failure),
          onSearchChanged: (query) =>
              cubit.refreshCities(state.draft.address.uf, search: query),
          onSelected: (option) {
            final city = state.catalogCities.firstWhere(
              (candidate) => candidate.token == option.token,
            );
            cubit.selectCity(city);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class UnlinkedPassengerScheduleSection extends StatelessWidget {
  const UnlinkedPassengerScheduleSection({required this.state, super.key});

  final UnlinkedPassengerFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<UnlinkedPassengerFormCubit>();
    final draft = state.draft;
    final legError = unlinkedPassengerErrorText(
      l10n,
      state.visibleErrors,
      const [UnlinkedPassengerDraftError.legRequired],
    );
    final timeError = unlinkedPassengerErrorText(
      l10n,
      state.visibleErrors,
      const [UnlinkedPassengerDraftError.timeRequired],
    );

    return VanepScheduleEditor(
      isAllowed: (_, _) => true,
      isSelected: draft.isLegSelected,
      timeOf: draft.timeOf,
      onToggled: cubit.toggleLeg,
      onTimePicked: cubit.changeTime,
      onApplyToEveryDay: cubit.applyTimeToEveryDay,
      layoutBuilder: (days, times) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VanepSection(
            title: l10n.unlinkedPassengerSectionDays,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.unlinkedPassengerDaysHint,
                  style: VanepTypography.cardSubtitle,
                ),
                const SizedBox(height: 8),
                days,
                if (legError != null)
                  UnlinkedPassengerFieldError(text: legError),
              ],
            ),
          ),
          if (times != null) ...[
            const SizedBox(height: unlinkedPassengerSectionSpacing),
            VanepSection(
              title: l10n.unlinkedPassengerSectionTimes,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  times,
                  if (timeError != null)
                    UnlinkedPassengerFieldError(text: timeError),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class UnlinkedPassengerNotesSection extends StatefulWidget {
  const UnlinkedPassengerNotesSection({required this.state, super.key});

  final UnlinkedPassengerFormState state;

  @override
  State<UnlinkedPassengerNotesSection> createState() =>
      UnlinkedPassengerNotesSectionState();
}

class UnlinkedPassengerNotesSectionState
    extends State<UnlinkedPassengerNotesSection> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;
    return VanepSection(
      title: l10n.unlinkedPassengerSectionNotes,
      child: VanepTextField(
        label: l10n.unlinkedPassengerNotesLabel,
        hintText: l10n.unlinkedPassengerNotesHint,
        controller: controller,
        enabled: !state.isSaving,
        minLines: 2,
        maxLines: 4,
        maxLength: unlinkedPassengerNotesMaxLength,
        errorText: unlinkedPassengerErrorText(l10n, state.visibleErrors, const [
          UnlinkedPassengerDraftError.notesTooLong,
        ]),
        onChanged: context.read<UnlinkedPassengerFormCubit>().changeNotes,
      ),
    );
  }
}
