import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';

void main() {
  const priceAdjustment = ProposalAdjustmentDraft(
    field: ProposalAdjustmentField.price,
    suggestedValue: 'R\$ 290',
  );

  test('a subject with a suggested value is valid', () {
    expect(validateProposalAdjustmentDraft(priceAdjustment), isEmpty);
  });

  test('a subject with only a message is valid', () {
    const draft = ProposalAdjustmentDraft(
      field: ProposalAdjustmentField.schedule,
      note: 'Pode buscar 10 min antes?',
    );

    expect(validateProposalAdjustmentDraft(draft), isEmpty);
  });

  test('the subject is required', () {
    const draft = ProposalAdjustmentDraft(suggestedValue: 'R\$ 290');

    expect(validateProposalAdjustmentDraft(draft), {
      ProposalAdjustmentDraftError.fieldRequired,
    });
  });

  test('needs a suggested value or a message', () {
    const draft = ProposalAdjustmentDraft(
      field: ProposalAdjustmentField.other,
      suggestedValue: '  ',
      note: '',
    );

    expect(validateProposalAdjustmentDraft(draft), {
      ProposalAdjustmentDraftError.valueOrNoteRequired,
    });
  });

  test('the suggested value has up to 100 characters', () {
    final draft = priceAdjustment.withSuggestedValue('a' * 101);

    expect(validateProposalAdjustmentDraft(draft), {
      ProposalAdjustmentDraftError.suggestedValueTooLong,
    });
  });

  test('the message has up to 500 characters', () {
    final draft = priceAdjustment.withNote('a' * 501);

    expect(validateProposalAdjustmentDraft(draft), {
      ProposalAdjustmentDraftError.noteTooLong,
    });
  });

  test('blank texts are sent as absent', () {
    final draft = priceAdjustment.withNote('   ');

    expect(draft.suggestedValueToSend, 'R\$ 290');
    expect(draft.noteToSend, isNull);
  });
}
