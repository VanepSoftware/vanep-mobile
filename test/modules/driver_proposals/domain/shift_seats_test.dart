import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_request_seats.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/shift_seats.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';

import '../../driver_van_central/driver_van_central_mocks.dart'
    show MockFindDriverOccupancy;
import '../../driver_vans/driver_vans_mocks.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../driver_proposals_fixtures.dart';

void main() {
  group('findRequestedShiftSeats', () {
    test('counts the occupancy and the students of each requested shift', () {
      final seats = findRequestedShiftSeats(
        vans: const [masterVan],
        occupancy: afternoonOccupancy,
        items: afternoonSiblings,
      );

      expect(seats, [afternoonSeats]);
      expect(seats.single.vacancies, 3);
      expect(seats.single.passengersAfterAccept, 14);
      expect(seats.single.exceedsCapacity, isFalse);
    });

    test('a full time student rides in the morning and the afternoon', () {
      final shifts = requestedShiftsOf(
        TestDriverRequestItem(
          days: const [
            TestRequestedDay(
              weekday: Weekday.monday,
              schoolShift: SchoolShift.fullTime,
            ),
          ],
        ),
      );

      expect(shifts, {OperationShift.morning, OperationShift.afternoon});
    });

    test('has no seats without a van or with more than one', () {
      for (final vans in [
        <Never>[],
        [masterVan, sprinterVan],
      ]) {
        final seats = findRequestedShiftSeats(
          vans: vans,
          occupancy: afternoonOccupancy,
          items: afternoonSiblings,
        );

        expect(seats, isEmpty);
      }
    });

    test('has no seats without the occupancy', () {
      final seats = findRequestedShiftSeats(
        vans: const [masterVan],
        occupancy: null,
        items: afternoonSiblings,
      );

      expect(seats, isEmpty);
    });

    test('flags a request that does not fit in the van', () {
      const seats = ShiftSeats(
        shift: OperationShift.afternoon,
        passengers: 14,
        capacity: 15,
        requested: 2,
      );

      expect(seats.exceedsCapacity, isTrue);
      expect(seats.vacancies, 1);
    });
  });

  group('LoadRequestSeats', () {
    late MockListMyVans listMyVans;
    late MockFindDriverOccupancy findOccupancy;
    final request = TestDriverServiceRequest(items: afternoonSiblings);

    setUp(() {
      listMyVans = MockListMyVans();
      findOccupancy = MockFindDriverOccupancy();
      when(() => listMyVans()).thenAnswer((_) async => const Ok([masterVan]));
      when(() => findOccupancy())
          .thenAnswer((_) async => const Ok(afternoonOccupancy));
    });

    LoadRequestSeats useCase() => LoadRequestSeats(
      listMyVans: listMyVans,
      findDriverOccupancy: findOccupancy,
    );

    test('reads the seats of the only van', () async {
      expect(await useCase()(request), [afternoonSeats]);
    });

    test('shows no seats when the occupancy fails', () async {
      when(() => findOccupancy())
          .thenAnswer((_) async => const Err(VanCentralFailure.network));

      expect(await useCase()(request), isEmpty);
    });

    test('shows no seats when the vans fail', () async {
      when(() => listMyVans())
          .thenAnswer((_) async => const Err(DriverVanFailure.network));

      expect(await useCase()(request), isEmpty);
    });
  });
}
