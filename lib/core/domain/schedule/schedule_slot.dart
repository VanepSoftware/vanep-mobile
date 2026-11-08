import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';

abstract class ScheduleSlot {
  Weekday get weekday;

  RouteLeg get leg;

  OperationShift get shift;

  ClockTime get pickupTime;
}
