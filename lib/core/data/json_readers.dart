import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';

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

DateTime readInstant(Object? raw) {
  final parsed = raw is String ? DateTime.tryParse(raw)?.toUtc() : null;
  return requireRead(parsed, 'instant', raw);
}

DateTime? readOptionalInstant(Object? raw) {
  return raw == null ? null : readInstant(raw);
}
