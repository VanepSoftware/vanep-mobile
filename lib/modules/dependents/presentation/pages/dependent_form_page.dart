import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/iso_calendar_date.dart';
import '../../../../core/formatters/birth_date_formatter.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_gender_select.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_read_only_field.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/value_objects/dependent_draft.dart';
import '../cubit/dependent_form_cubit.dart';
import '../cubit/dependent_form_state.dart';
import '../formatters/dependent_labels.dart';
import '../widgets/dependent_address_card.dart';

const int maxDependentNameLength = 255;

class DependentFormPage extends StatelessWidget {
  const DependentFormPage({this.dependent, super.key});

  final Dependent? dependent;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DependentFormCubit>(param1: dependent),
      child: const DependentFormView(),
    );
  }
}

class DependentFormView extends StatefulWidget {
  const DependentFormView({super.key});

  @override
  State<DependentFormView> createState() => DependentFormViewState();
}

class DependentFormViewState extends State<DependentFormView> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = context.read<DependentFormCubit>().state.draft.name;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DependentFormCubit, DependentFormState>(
      listenWhen: (previous, current) =>
          current.status == DependentFormStatus.saved ||
          current.failure != previous.failure,
      listener: (context, state) {
        if (state.status == DependentFormStatus.saved) {
          Navigator.of(context).pop(true);
          return;
        }
        if (!shouldShowDependentFailureFeedback(state.failure)) return;
        VanepFeedback.showError(
          context,
          dependentFailureLabel(l10n, state.failure!),
        );
      },
      builder: (context, state) {
        final cubit = context.read<DependentFormCubit>();

        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: const VanepAppBar(),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              VanepPageHeader(
                title: state.isCreating
                    ? l10n.dependentFormNewTitle
                    : l10n.dependentFormEditTitle,
                subtitle: l10n.dependentFormSubtitle,
              ),
              ...withSpacing([
                VanepTextField(
                  label: l10n.dependentFieldName,
                  controller: nameController,
                  onChanged: cubit.changeName,
                  enabled: !state.isSaving,
                  maxLength: maxDependentNameLength,
                  textInputAction: TextInputAction.next,
                  errorText: dependentFieldErrorLabel(
                    l10n,
                    state.errorOf(DependentField.name),
                  ),
                ),
                DependentBirthDateField(state: state),
                VanepGenderSelect(
                  label: l10n.dependentFieldGender,
                  value: state.draft.gender,
                  onChanged: cubit.changeGender,
                  enabled: !state.isSaving,
                ),
                DependentAddressCard(state: state),
              ], 20),
            ],
          ),
          bottomNavigationBar: VanepBottomBar(
            child: VanepPrimaryButton(
              label: l10n.dependentFormSave,
              isLoading: state.isSaving,
              onPressed: cubit.save,
            ),
          ),
        );
      },
    );
  }
}

class DependentBirthDateField extends StatelessWidget {
  const DependentBirthDateField({required this.state, super.key});

  final DependentFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentFormCubit>();
    final locale = Localizations.localeOf(context);
    final birthDate = state.draft.birthDate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: VanepReadOnlyField(
            label: l10n.dependentFieldBirthDate,
            value: birthDate == null
                ? ''
                : formatBirthDate(birthDate, locale, ''),
            hintText: l10n.dependentFieldBirthDateEmpty,
            enabled: !state.isSaving,
            errorText: dependentFieldErrorLabel(
              l10n,
              state.errorOf(DependentField.birthDate),
            ),
            onTap: () => pickBirthDate(context, state),
          ),
        ),
        if (birthDate != null)
          IconButton(
            tooltip: l10n.dependentFieldBirthDateClear,
            icon: const Icon(Icons.close, color: VanepColors.textSecondary),
            onPressed: state.isSaving
                ? null
                : () => cubit.changeBirthDate(null),
          ),
      ],
    );
  }
}

Future<void> pickBirthDate(
  BuildContext context,
  DependentFormState state,
) async {
  final cubit = context.read<DependentFormCubit>();
  final today = DateTime.now();
  final current = initialBirthDatePickerDay(state.draft.birthDate, today);
  final picked = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(today.year - 120),
    lastDate: today,
  );
  if (picked == null) return;
  cubit.changeBirthDate(formatIsoCalendarDate(picked));
}

DateTime initialBirthDatePickerDay(String? isoBirthDate, DateTime today) {
  final current = parseIsoCalendarDate(isoBirthDate) ?? today;
  if (current.isAfter(today)) return today;
  return current;
}
