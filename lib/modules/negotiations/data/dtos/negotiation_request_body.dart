import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/negotiation_json.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/draft_text.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

Map<String, Object?> serviceRequestDraftToJson(ServiceRequestDraft draft) {
  return {
    'driverToken': draft.driverToken,
    if (draft.desiredStartDate case final date?)
      'desiredStartDate': formatIsoCalendarDate(date),
    'notes': ?draft.notesToSend,
    'items': [
      for (final item in draft.items)
        {
          'dependentToken': item.dependentToken,
          'days': [
            for (final MapEntry(key: weekday, value: legs)
                in item.daysToSend.entries)
              {
                'weekday': Weekday.toApi(weekday),
                'needsOutbound': legs.contains(RouteLeg.outbound),
                'needsReturn': legs.contains(RouteLeg.homebound),
              },
          ],
        },
    ],
  };
}

Map<String, Object?> proposalDraftToJson(ProposalDraft draft) {
  return {
    if (draft.startsOn case final startsOn?)
      'startsOn': formatIsoCalendarDate(startsOn),
    if (draft.endsOn case final endsOn?)
      'endsOn': formatIsoCalendarDate(endsOn),
    if (draft.totalAmountCents case final total?)
      'totalAmount': centsToAmount(total),
    'installments': ?draft.installments,
    'dueDay': ?draft.dueDay,
    if (draft.enrollmentFeeCents case final fee?)
      'enrollmentFee': centsToAmount(fee),
    'adjustmentPolicy': ProposalAdjustmentPolicy.toApi(draft.adjustmentPolicy),
    'cancellationPolicy': ProposalCancellationPolicy.toApi(
      draft.cancellationPolicy,
    ),
    'vehicleToken': ?draft.vehicleToken,
    'validDays': draft.validDays,
    'message': ?draft.messageToSend,
    'items': [
      for (final item in draft.items)
        {
          'dependentToken': item.dependentToken,
          'slots': [
            for (final slot in item.slotsToSend)
              {
                'weekday': Weekday.toApi(slot.weekday),
                'leg': RouteLeg.toApi(slot.leg),
                'shift': slot.shift.apiName,
                'pickupTime': slot.pickupTime.toApi(),
              },
          ],
        },
    ],
  };
}

Map<String, Object?> proposalAdjustmentDraftToJson(
  ProposalAdjustmentDraft draft,
) {
  return {
    'field': ProposalAdjustmentField.toApi(draft.field),
    'suggestedValue': ?draft.suggestedValueToSend,
    'note': ?draft.noteToSend,
  };
}

Map<String, Object?> declineToJson(String? reason) {
  return {'reason': ?trimmedOrNull(reason ?? '')};
}
