import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/value_objects/draft_text.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';

const adjustmentSuggestedValueMaxLength = 100;

const adjustmentNoteMaxLength = 500;

enum ProposalAdjustmentDraftError {
  fieldRequired,
  valueOrNoteRequired,
  suggestedValueTooLong,
  noteTooLong,
}

class ProposalAdjustmentDraft extends Equatable {
  const ProposalAdjustmentDraft({
    this.field,
    this.suggestedValue = '',
    this.note = '',
  });

  final ProposalAdjustmentField? field;

  final String suggestedValue;

  final String note;

  String? get suggestedValueToSend => trimmedOrNull(suggestedValue);

  String? get noteToSend => trimmedOrNull(note);

  ProposalAdjustmentDraft withField(ProposalAdjustmentField value) {
    return ProposalAdjustmentDraft(
      field: value,
      suggestedValue: suggestedValue,
      note: note,
    );
  }

  ProposalAdjustmentDraft withSuggestedValue(String value) {
    return ProposalAdjustmentDraft(
      field: field,
      suggestedValue: value,
      note: note,
    );
  }

  ProposalAdjustmentDraft withNote(String value) {
    return ProposalAdjustmentDraft(
      field: field,
      suggestedValue: suggestedValue,
      note: value,
    );
  }

  @override
  List<Object?> get props => [field, suggestedValue, note];
}

Set<ProposalAdjustmentDraftError> validateProposalAdjustmentDraft(
  ProposalAdjustmentDraft draft,
) {
  return {
    if (draft.field == null) ProposalAdjustmentDraftError.fieldRequired,
    if (draft.suggestedValueToSend == null && draft.noteToSend == null)
      ProposalAdjustmentDraftError.valueOrNoteRequired,
    if (isLongerThan(draft.suggestedValue, adjustmentSuggestedValueMaxLength))
      ProposalAdjustmentDraftError.suggestedValueTooLong,
    if (isLongerThan(draft.note, adjustmentNoteMaxLength))
      ProposalAdjustmentDraftError.noteTooLong,
  };
}
