import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';
import 'package:vanep_mobile/core/data/json_readers.dart';

export 'package:vanep_mobile/core/data/json_readers.dart';

ServiceRequestStatus readServiceRequestStatus(Object? raw) {
  return requireRead(ServiceRequestStatus.fromApi(raw), 'request status', raw);
}

ProposalStatus readProposalStatus(Object? raw) {
  return requireRead(ProposalStatus.fromApi(raw), 'proposal status', raw);
}

ProposalAdjustmentPolicy readAdjustmentPolicy(Object? raw) {
  return requireRead(
    ProposalAdjustmentPolicy.fromApi(raw),
    'adjustment policy',
    raw,
  );
}

ProposalCancellationPolicy readCancellationPolicy(Object? raw) {
  return requireRead(
    ProposalCancellationPolicy.fromApi(raw),
    'cancellation policy',
    raw,
  );
}

ProposalAdjustmentField readAdjustmentField(Object? raw) {
  return requireRead(
    ProposalAdjustmentField.fromApi(raw),
    'adjustment field',
    raw,
  );
}

DateTime readCalendarDate(Object? raw) {
  final parsed = raw is String ? parseIsoCalendarDate(raw) : null;
  return requireRead(parsed, 'date', raw);
}

int readInt(Object? raw) {
  return requireRead(raw is num ? raw.toInt() : null, 'number', raw);
}

int readCents(Object? raw) {
  return requireRead(readOptionalCents(raw), 'amount', raw);
}

int? readOptionalCents(Object? raw) {
  return raw is num ? (raw * 100).round() : null;
}

double centsToAmount(int cents) => cents / 100;
