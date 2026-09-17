import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/iso_calendar_date.dart';
import '../../../../core/formatters/birth_date_formatter.dart';
import '../../../../core/formatters/gender_label.dart';
import '../../../../core/places/place_autocomplete_controller.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_gender_chips.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_screen_background.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/value_objects/dependent_draft.dart';
import '../cubit/dependent_form_cubit.dart';
import '../cubit/dependent_form_state.dart';
import '../formatters/dependent_labels.dart';
import '../widgets/dependent_address_field.dart';

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
  final TextEditingController numberController = TextEditingController();
  final TextEditingController complementController = TextEditingController();
  final PlaceAutocompleteController autocomplete =
      getIt<PlaceAutocompleteController>();

  @override
  void initState() {
    super.initState();
    final draft = context.read<DependentFormCubit>().state.draft;
    nameController.text = draft.name;
    numberController.text = draft.address?.number ?? '';
    complementController.text = draft.address?.complement ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    complementController.dispose();
    autocomplete.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: BlocBuilder<DependentFormCubit, DependentFormState>(
            buildWhen: (previous, current) =>
                previous.isCreating != current.isCreating,
            builder: (context, state) => Text(
              state.isCreating
                  ? l10n.dependentFormNewTitle
                  : l10n.dependentFormEditTitle,
            ),
          ),
        ),
        body: BlocConsumer<DependentFormCubit, DependentFormState>(
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

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  const SizedBox(height: 20),
                  DependentBirthDateField(state: state),
                  const SizedBox(height: 20),
                  Text(
                    l10n.dependentFieldGender,
                    style: VanepTypography.cardSubtitle,
                  ),
                  const SizedBox(height: 8),
                  VanepGenderChips(
                    value: state.draft.gender,
                    onChanged: cubit.changeGender,
                    labelOf: (gender) => genderLabel(gender, l10n),
                  ),
                  if (state.draft.gender != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => cubit.changeGender(null),
                        child: Text(l10n.dependentFieldGenderClear),
                      ),
                    ),
                  const SizedBox(height: 20),
                  DependentAddressField(
                    state: state,
                    autocomplete: autocomplete,
                    numberController: numberController,
                    complementController: complementController,
                  ),
                  const SizedBox(height: 28),
                  VanepPrimaryButton(
                    label: l10n.dependentFormSave,
                    isLoading: state.isSaving,
                    onPressed: cubit.save,
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
    final errorText = dependentFieldErrorLabel(
      l10n,
      state.errorOf(DependentField.birthDate),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dependentFieldBirthDate, style: VanepTypography.cardSubtitle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.isSaving
                    ? null
                    : () => pickBirthDate(context, state),
                child: Text(
                  formatBirthDate(
                    state.draft.birthDate,
                    locale,
                    l10n.dependentFieldBirthDateEmpty,
                  ),
                ),
              ),
            ),
            if (state.draft.birthDate != null)
              IconButton(
                tooltip: l10n.dependentFieldBirthDateClear,
                icon: const Icon(
                  Icons.close,
                  color: VanepColors.textSecondary,
                ),
                onPressed: () => cubit.changeBirthDate(null),
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.textPrimary,
              ),
            ),
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
