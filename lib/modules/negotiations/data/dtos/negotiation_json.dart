import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

T requireRead<T>(T? value, String what, Object? raw) {
  if (value == null) throw FormatException('Unreadable $what.', raw);
  return value;
}

String readToken(Object? raw) {
  return requireRead(
    raw is String && raw.isNotEmpty ? raw : null,
    'token',
    raw,
  );
}

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

RouteLeg readRouteLeg(Object? raw) {
  return requireRead(RouteLeg.fromApi(raw), 'route leg', raw);
}

OperationShift readOperationShift(Object? raw) {
  return requireRead(OperationShift.fromApi(raw), 'operation shift', raw);
}

Weekday readWeekday(Object? raw) {
  return requireRead(Weekday.fromApi(raw), 'weekday', raw);
}

ClockTime readClockTime(Object? raw) {
  return requireRead(ClockTime.fromApi(raw), 'time of day', raw);
}

DateTime readCalendarDate(Object? raw) {
  final parsed = raw is String ? parseIsoCalendarDate(raw) : null;
  return requireRead(parsed, 'date', raw);
}

DateTime readInstant(Object? raw) {
  final parsed = raw is String ? DateTime.tryParse(raw)?.toUtc() : null;
  return requireRead(parsed, 'instant', raw);
}

DateTime? readOptionalInstant(Object? raw) {
  return raw == null ? null : readInstant(raw);
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
