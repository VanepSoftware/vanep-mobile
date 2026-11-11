import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/repositories/driver_home_repository.dart';

const driverHomeStopFixture = StopConfirmation(
  tripId: 'trip',
  stopId: 'stop',
  studentId: 'student',
  studentName: 'Ana',
  action: StopAction.boarding,
);

DriverHomeData driverHomeFixture(
  HomePhase phase, {
  bool blockedInProgress = false,
  bool outsideWorkingHours = false,
  int? familiesInApp = 3,
}) => DriverHomeData(
  registration: switch (phase) {
    HomePhase.incomplete => RegistrationStatus.incomplete,
    HomePhase.underReview => RegistrationStatus.underReview,
    HomePhase.rejected => RegistrationStatus.rejected,
    _ => RegistrationStatus.approved,
  },
  subscriptionBlocked: phase == HomePhase.blocked || blockedInProgress,
  rejectionReason: phase == HomePhase.rejected ? 'CNH ilegível' : null,
  todayTrip: switch (phase) {
    HomePhase.inProgress => const Trip(
      id: 'trip',
      status: TripStatus.inProgress,
      label: 'MORNING',
    ),
    HomePhase.beforeDeparture => const Trip(
      id: 'trip',
      status: TripStatus.notStarted,
      label: 'MORNING',
    ),
    HomePhase.shiftCompleted => const Trip(
      id: 'trip',
      status: TripStatus.completed,
      label: 'MORNING',
    ),
    _ => null,
  },
  laterShiftLabel: phase == HomePhase.shiftCompleted ? 'AFTERNOON' : null,
  studentCount: phase == HomePhase.buildingRoute ? 0 : 3,
  familiesInApp: familiesInApp,
  nextConfirmation: phase == HomePhase.inProgress
      ? driverHomeStopFixture
      : null,
  contactLabel: phase == HomePhase.inProgress ? 'Responsável da Ana' : null,
  outsideWorkingHours: outsideWorkingHours,
);

class DriverHomeFixtureRepository implements DriverHomeRepository {
  DriverHomeFixtureRepository(this.data);
  DriverHomeData data;
  int starts = 0;
  int confirmations = 0;
  @override
  Future<DriverHomeData> load() async => data;
  @override
  Future<void> startTrip(String tripId) async {
    starts++;
    data = driverHomeFixture(HomePhase.inProgress);
  }

  @override
  Future<void> confirmStop(StopConfirmation confirmation) async {
    confirmations++;
  }
}
