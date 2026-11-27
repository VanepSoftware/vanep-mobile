import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

class ShiftSeats extends Equatable implements ShiftOccupancy {
  const ShiftSeats({
    required this.shift,
    required this.passengers,
    required this.capacity,
    required this.requested,
  });

  @override
  final OperationShift shift;

  @override
  final int passengers;

  final int capacity;

  final int requested;

  int get vacancies => vacanciesIn(capacity);

  int get passengersAfterAccept => passengers + requested;

  bool get exceedsCapacity => passengersAfterAccept > capacity;

  @override
  List<Object?> get props => [shift, passengers, capacity, requested];
}

Set<OperationShift> requestedShiftsOf(RequestItem item) {
  return {
    for (final day in item.days) ...[
      if (day.needsOutbound)
        deriveOperationShift(day.schoolShift, RouteLeg.outbound),
      if (day.needsReturn)
        deriveOperationShift(day.schoolShift, RouteLeg.homebound),
    ],
  };
}

// The API does not split contracted students by van, so the occupancy only
// describes a van when the driver has a single one.
List<ShiftSeats> findRequestedShiftSeats({
  required List<DriverVan> vans,
  required DriverOccupancy? occupancy,
  required List<RequestItem> items,
}) {
  if (vans.length != 1 || occupancy == null) return const [];
  final shiftsByItem = [for (final item in items) requestedShiftsOf(item)];
  int countStudentsIn(OperationShift shift) {
    return shiftsByItem.where((shifts) => shifts.contains(shift)).length;
  }

  return [
    for (final shift in OperationShift.values)
      if (countStudentsIn(shift) > 0)
        ShiftSeats(
          shift: shift,
          passengers: occupancy.passengersIn(shift),
          capacity: vans.single.capacity,
          requested: countStudentsIn(shift),
        ),
  ];
}
