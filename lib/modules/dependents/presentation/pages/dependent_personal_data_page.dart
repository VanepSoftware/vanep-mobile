import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/cpf.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/formatters/birth_date_input_formatter.dart';
import 'package:vanep_mobile/core/formatters/cpf_input_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_gender_select.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_editor_frame.dart';

const int maxDependentNameLength = 255;

Future<Dependent?> openDependentPersonalData(
  BuildContext context, {
  required Dependent dependent,
}) {
  return Navigator.of(context).push<Dependent>(
    MaterialPageRoute<Dependent>(
      builder: (_) => DependentPersonalDataPage(dependent: dependent),
    ),
  );
}

class DependentPersonalDataPage extends StatelessWidget {
  const DependentPersonalDataPage({required this.dependent, super.key});

  final Dependent dependent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<DependentPersonalDataCubit>(param1: dependent),
      child: DependentEditorFrame(
        title: l10n.dependentRowPersonalData,
        caption: dependentFirstName(dependent.name),
        body: const DependentPersonalDataBody(),
        bottomBar:
            DependentEditorSaveBar<
              DependentPersonalDataCubit,
              DependentPersonalDataState
            >(
              label: l10n.dependentEditorSave,
              onSaved: (state) => Navigator.of(context).pop(state.saved),
            ),
      ),
    );
  }
}

class DependentPersonalDataBody extends StatefulWidget {
  const DependentPersonalDataBody({super.key});

  @override
  State<DependentPersonalDataBody> createState() =>
      DependentPersonalDataBodyState();
}

class DependentPersonalDataBodyState extends State<DependentPersonalDataBody> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController documentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = context.read<DependentPersonalDataCubit>().state.draft;
    nameController.text = draft.name;
    birthDateController.text = isoToBirthDateInput(draft.birthDate);
    documentController.text = formatPartialCpf(
      extractCpfDigits(draft.document ?? ''),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    documentController.dispose();
    super.dispose();
  }

  Future<void> pickBirthDate() async {
    final cubit = context.read<DependentPersonalDataCubit>();
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialBirthDatePickerDay(
        cubit.state.draft.birthDate,
        today,
      ),
      firstDate: DateTime(today.year - 120),
      lastDate: today,
    );
    if (picked == null) return;
    final iso = formatIsoCalendarDate(picked);
    birthDateController.text = isoToBirthDateInput(iso);
    cubit.changeBirthDate(iso);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentPersonalDataCubit>();

    return BlocConsumer<DependentPersonalDataCubit, DependentPersonalDataState>(
      listenWhen: (previous, current) => current.failure != previous.failure,
      listener: (context, state) {
        final failure = state.failure;
        if (!shouldShowDependentFailureFeedback(failure)) return;
        VanepFeedback.showError(context, dependentFailureLabel(l10n, failure!));
      },
      builder: (context, state) {
        String? errorOf(DependentField field) =>
            dependentFieldErrorLabel(l10n, state.errorOf(field));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: withSpacing([
            ValidateOnLeave(
              onLeave: () => cubit.validateField(DependentField.name),
              child: VanepTextField(
                label: l10n.dependentFieldName,
                controller: nameController,
                onChanged: cubit.changeName,
                enabled: !state.isSaving,
                maxLength: maxDependentNameLength,
                textInputAction: TextInputAction.next,
                errorText: errorOf(DependentField.name),
              ),
            ),
            ValidateOnLeave(
              onLeave: () => cubit.validateField(DependentField.birthDate),
              child: VanepTextField(
                label: l10n.dependentFieldBirthDate,
                controller: birthDateController,
                onChanged: (text) =>
                    cubit.changeBirthDate(birthDateInputToIso(text)),
                enabled: !state.isSaving,
                hintText: l10n.dependentFieldBirthDateHint,
                keyboardType: TextInputType.number,
                inputFormatters: const [BirthDateInputFormatter()],
                textInputAction: TextInputAction.next,
                errorText: errorOf(DependentField.birthDate),
                suffix: IconButton(
                  tooltip: l10n.dependentFieldBirthDatePick,
                  color: VanepColors.textSecondary,
                  icon: const Icon(Icons.calendar_today_outlined, size: 20),
                  onPressed: state.isSaving ? null : pickBirthDate,
                ),
              ),
            ),
            VanepGenderSelect(
              label: l10n.dependentFieldGender,
              value: state.draft.gender,
              onChanged: cubit.changeGender,
              enabled: !state.isSaving,
            ),
            ValidateOnLeave(
              onLeave: () => cubit.validateField(DependentField.document),
              child: VanepTextField(
                label: l10n.dependentFieldDocument,
                controller: documentController,
                onChanged: cubit.changeDocument,
                enabled: !state.isSaving,
                hintText: l10n.dependentFieldDocumentHint,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  const CpfInputFormatter(),
                ],
                errorText: errorOf(DependentField.document),
              ),
            ),
          ], 20),
        );
      },
    );
  }
}

class ValidateOnLeave extends StatelessWidget {
  const ValidateOnLeave({
    required this.onLeave,
    required this.child,
    super.key,
  });

  final VoidCallback onLeave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        if (!hasFocus) onLeave();
      },
      child: child,
    );
  }
}

DateTime initialBirthDatePickerDay(String? isoBirthDate, DateTime today) {
  final current = parseIsoCalendarDate(isoBirthDate) ?? today;
  if (current.isAfter(today)) return today;
  return current;
}
