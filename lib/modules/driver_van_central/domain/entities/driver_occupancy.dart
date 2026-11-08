import 'package:vanep_mobile/modules/driver_van_central/domain/value_objects/operation_shift.dart';

abstract class ShiftOccupancy {
  OperationShift get shift;

  int get passengers;
}

abstract class DriverOccupancy {
  List<ShiftOccupancy> get shifts;

  int get students;

  int get studentsWithFamily;
}

const alwaysVisibleShifts = {OperationShift.morning, OperationShift.afternoon};

extension ShiftOccupancySeats on ShiftOccupancy {
  int vacanciesIn(int capacity) =>
      passengers >= capacity ? 0 : capacity - passengers;

  bool isFullIn(int capacity) => vacanciesIn(capacity) == 0;

  double fillRatioIn(int capacity) {
    if (capacity <= 0) return 0;
    return (passengers / capacity).clamp(0, 1).toDouble();
  }
}

extension DriverOccupancyShifts on DriverOccupancy {
  int passengersIn(OperationShift shift) {
    for (final occupancy in shifts) {
      if (occupancy.shift == shift) return occupancy.passengers;
    }
    return 0;
  }

  List<ShiftOccupancy> get visibleShifts => [
    for (final occupancy in shifts)
      if (alwaysVisibleShifts.contains(occupancy.shift) ||
          occupancy.passengers > 0)
        occupancy,
  ];

  List<OperationShift> shiftsWithVacanciesIn(int capacity) => [
    for (final occupancy in visibleShifts)
      if (!occupancy.isFullIn(capacity)) occupancy.shift,
  ];
}
