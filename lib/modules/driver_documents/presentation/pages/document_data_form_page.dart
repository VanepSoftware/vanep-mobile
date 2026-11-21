import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/upper_case_input_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_choice_chips.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_read_only_field.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_field_rules.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_field_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_submission_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_form_fields.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_source_sheet.dart';

class DocumentDataFormPage extends StatefulWidget {
  const DocumentDataFormPage({this.vehicleCaption, super.key});

  final String? vehicleCaption;

  @override
  State<DocumentDataFormPage> createState() => DocumentDataFormPageState();
}

class DocumentDataFormPageState extends State<DocumentDataFormPage> {
  final number = TextEditingController();
  final expiresAt = TextEditingController();
  final registration = TextEditingController();
  final issueDate = TextEditingController();
  final issuingState = TextEditingController();
  String category = '';
  final editedSinceRefusal = <DocumentField>{};

  DocumentSubmissionCubit get cubit => context.read<DocumentSubmissionCubit>();

  DocumentType get type => cubit.state.type;

  @override
  void initState() {
    super.initState();
    fillFrom(context.read<DocumentSubmissionCubit>().state.draft);
  }

  @override
  void dispose() {
    for (final controller in [
      number,
      expiresAt,
      registration,
      issueDate,
      issuingState,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void fillFrom(DocumentDraft? draft) {
    switch (draft) {
      case PersonalDocumentDraft():
        number.text = draft.documentNumber ?? '';
        expiresAt.text = formatDocumentDateInput(draft.expiresAt);
      case VehicleDocumentDraft():
        number.text = draft.documentNumber ?? '';
        expiresAt.text = formatDocumentDateInput(draft.expiresAt);
      case CnhDraft():
        registration.text = draft.registrationNumber;
        category = draft.category.toUpperCase();
        issueDate.text = formatDocumentDateInput(draft.issueDate);
        expiresAt.text = formatDocumentDateInput(draft.validUntil);
        issuingState.text = draft.issuingState ?? '';
      case null:
        return;
    }
  }

  DocumentDraft buildDraft() {
    final state = cubit.state;
    final expiry = parseDocumentDateInput(expiresAt.text);
    if (type == DocumentType.driverLicense) {
      return CnhDraft(
        registrationNumber: registration.text,
        category: category,
        issueDate: parseDocumentDateInput(issueDate.text),
        validUntil: expiry,
        issuingState: issuingState.text,
      );
    }
    final vehicleToken = state.vehicleToken;
    if (vehicleToken != null) {
      return VehicleDocumentDraft(
        vehicleToken: vehicleToken,
        type: type,
        documentNumber: number.text,
        expiresAt: expiry,
      );
    }
    return PersonalDocumentDraft(
      type: type,
      documentNumber: number.text,
      expiresAt: expiry,
    );
  }

  Map<DocumentField, DocumentFieldError> currentErrors(DateTime asOf) {
    final errors = {...validateDocumentDraft(buildDraft(), asOf)};
    for (final entry in {
      DocumentField.expiresAt: expiresAt,
      DocumentField.cnhIssueDate: issueDate,
    }.entries) {
      final text = entry.value.text;
      final unreadable =
          text.isNotEmpty && parseDocumentDateInput(text) == null;
      if (unreadable) errors[entry.key] = DocumentFieldError.invalidFormat;
    }
    return errors;
  }

  DocumentFieldError? refusedByBack(DocumentField field) {
    final failure = cubit.state.failure;
    if (editedSinceRefusal.contains(field)) return null;
    return switch (failure) {
      FieldRejectedFailure(field: final rejected, :final error)
          when rejected == field =>
        error,
      CnhNumberTakenFailure()
          when field == DocumentField.cnhRegistrationNumber =>
        DocumentFieldError.invalidFormat,
      _ => null,
    };
  }

  String? visibleError(
    AppLocalizations l10n,
    DocumentField field,
    Map<DocumentField, DocumentFieldError> errors,
    TextEditingController? controller,
  ) {
    if (cubit.state.failure is CnhNumberTakenFailure &&
        field == DocumentField.cnhRegistrationNumber &&
        !editedSinceRefusal.contains(field)) {
      return l10n.documentSubmissionCnhTaken;
    }
    final error = refusedByBack(field) ?? errors[field];
    if (error == null || error == DocumentFieldError.required) return null;
    final isDate =
        field == DocumentField.expiresAt || field == DocumentField.cnhIssueDate;
    if (isDate && controller != null && !isFilledDateInput(controller.text)) {
      return null;
    }
    return documentFieldErrorMessage(l10n, field, error);
  }

  void edited(DocumentField field) {
    setState(() => editedSinceRefusal.add(field));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<DocumentSubmissionCubit>().state;
    final asOf =
        context.watch<DriverComplianceCubit>().state.compliance?.asOf ??
        DateUtils.dateOnly(DateTime.now());
    final errors = currentErrors(asOf);
    final hasBackRefusal = fieldRulesFor(type)
        .any((rule) => refusedByBack(rule.field) != null);
    final canSubmit = errors.isEmpty && !hasBackRefusal && state.file != null;
    final generalFailure = state.failure;
    final generalMessage =
        generalFailure == null || generalFailure is CnhNumberTakenFailure
        ? null
        : submissionFailureMessage(l10n, generalFailure);
    final file = state.file;

    return BlocListener<DocumentSubmissionCubit, DocumentSubmissionState>(
      listenWhen: (previous, current) =>
          (previous.draft == null && current.draft != null) ||
          (current.failure != null && current.failure != previous.failure),
      listener: (context, state) => setState(() {
        if (state.failure != null) editedSinceRefusal.clear();
        if (number.text.isEmpty && registration.text.isEmpty) {
          fillFrom(state.draft);
        }
      }),
      child: Scaffold(
        backgroundColor: context.palette.surface,
        appBar: VanepAppBar(title: documentTypeLabel(l10n, type)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            if (file != null)
              DocumentFileSummaryCard(
                file: file,
                onChange: () => showDocumentSourceSheet(context, cubit),
              ),
            const SizedBox(height: 22),
            Text(
              l10n.documentDataSection,
              style: context.typography.sectionTitle,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.documentDataHint,
              style: context.typography.cardSubtitle.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            for (final rule in fieldRulesFor(type)) ...[
              buildField(l10n, rule, errors, asOf),
              const SizedBox(height: 16),
            ],
            if (widget.vehicleCaption != null)
              VanepReadOnlyField(
                label: l10n.documentFieldVan,
                value: widget.vehicleCaption!,
                enabled: false,
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (generalMessage != null) ...[
                  Text(
                    generalMessage,
                    style: context.typography.cardSubtitle.copyWith(
                      color: context.palette.dangerText,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                VanepPrimaryButton(
                  label: l10n.documentDataSubmit,
                  onPressed: canSubmit
                      ? () => cubit.submit(buildDraft())
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(
    AppLocalizations l10n,
    FieldRule rule,
    Map<DocumentField, DocumentFieldError> errors,
    DateTime asOf,
  ) {
    final label = documentFieldRuleLabel(l10n, type, rule);
    return switch (rule.field) {
      DocumentField.documentNumber => VanepTextField(
        label: label,
        controller: number,
        maxLength: maxDocumentNumberLength,
        errorText: visibleError(l10n, rule.field, errors, number),
        onChanged: (_) => edited(rule.field),
      ),
      DocumentField.expiresAt => DocumentDateField(
        label: label,
        controller: expiresAt,
        firstDate: asOf,
        lastDate: latestExpiryFor(type, asOf) ?? DateTime(asOf.year + 50),
        helperText: documentFieldHint(l10n, type, rule.field),
        errorText: visibleError(l10n, rule.field, errors, expiresAt),
        onChanged: (_) => edited(rule.field),
      ),
      DocumentField.cnhRegistrationNumber => VanepTextField(
        label: label,
        controller: registration,
        keyboardType: TextInputType.number,
        inputFormatters: cnhRegistrationFormatters,
        errorText: visibleError(l10n, rule.field, errors, registration),
        onChanged: (_) => edited(rule.field),
      ),
      DocumentField.cnhCategory => CnhCategoryField(
        label: label,
        selected: category,
        onSelected: (value) {
          category = value;
          edited(rule.field);
        },
      ),
      DocumentField.cnhIssueDate => DocumentDateField(
        label: label,
        controller: issueDate,
        firstDate: DateTime(asOf.year - 60),
        lastDate: asOf,
        errorText: visibleError(l10n, rule.field, errors, issueDate),
        onChanged: (_) => edited(rule.field),
      ),
      DocumentField.cnhIssuingState => VanepTextField(
        label: label,
        controller: issuingState,
        maxLength: 2,
        inputFormatters: const [UpperCaseInputFormatter()],
        errorText: visibleError(l10n, rule.field, errors, issuingState),
        onChanged: (_) => edited(rule.field),
      ),
    };
  }
}

class CnhCategoryField extends StatelessWidget {
  const CnhCategoryField({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final warns =
        cnhCategories.contains(selected) &&
        !cnhCategoryAllowsSchoolTransport(selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.typography.fieldLabel),
        const SizedBox(height: 8),
        VanepChoiceChips<String>(
          choices: [
            for (final category in cnhCategories)
              VanepChoice(value: category, label: category),
          ],
          selected: selected,
          onSelected: onSelected,
        ),
        if (warns) ...[
          const SizedBox(height: 8),
          Text(
            l10n.documentCnhCategoryWarning,
            style: context.typography.cardSubtitle.copyWith(
              color: context.palette.warningText,
            ),
          ),
        ],
      ],
    );
  }
}
