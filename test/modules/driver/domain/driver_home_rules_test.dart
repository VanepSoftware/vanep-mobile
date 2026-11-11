import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';

void main() {
  const rules = DriverHomeRules();
  final cases = <HomePhase, DriverHomeData>{
    HomePhase.blocked: const DriverHomeData(
      registration: RegistrationStatus.incomplete,
      expiredDocument: true,
    ),
    HomePhase.incomplete: const DriverHomeData(
      registration: RegistrationStatus.incomplete,
    ),
    HomePhase.underReview: const DriverHomeData(
      registration: RegistrationStatus.underReview,
    ),
    HomePhase.rejected: const DriverHomeData(
      registration: RegistrationStatus.rejected,
    ),
    HomePhase.inProgress: const DriverHomeData(
      registration: RegistrationStatus.incomplete,
      subscriptionBlocked: true,
      todayTrip: Trip(id: 't', status: TripStatus.inProgress, label: 'Manhã'),
    ),
    HomePhase.beforeDeparture: const DriverHomeData(
      registration: RegistrationStatus.approved,
      todayTrip: Trip(id: 't', status: TripStatus.notStarted, label: 'Manhã'),
    ),
    HomePhase.shiftCompleted: const DriverHomeData(
      registration: RegistrationStatus.approved,
      laterShiftLabel: 'Tarde',
      todayTrip: Trip(id: 't', status: TripStatus.completed, label: 'Manhã'),
    ),
    HomePhase.buildingRoute: const DriverHomeData(
      registration: RegistrationStatus.approved,
    ),
    HomePhase.noRouteToday: const DriverHomeData(
      registration: RegistrationStatus.approved,
      studentCount: 4,
    ),
  };
  for (final entry in cases.entries) {
    test(
      'resolves ${entry.key}',
      () => expect(rules.resolve(entry.value).phase, entry.key),
    );
  }
  test('active blocked trip has a banner', () {
    expect(rules.resolve(cases[HomePhase.inProgress]!).blockBanner, isNotNull);
  });
  test('incomplete registration enables only Documents', () {
    for (final shortcut in Shortcut.values) {
      expect(
        rules.shortcutEnabled(cases[HomePhase.incomplete]!, shortcut),
        shortcut == Shortcut.documents,
      );
    }
  });
  test('D12 includes 100 percent and omits zero students', () {
    expect(
      rules.familyCounter(
        const DriverHomeData(
          registration: RegistrationStatus.approved,
          studentCount: 3,
          familiesInApp: 3,
        ),
      ),
      3,
    );
    expect(rules.familyCounter(cases[HomePhase.buildingRoute]!), isNull);
    expect(
      rules.familyCounter(
        const DriverHomeData(
          registration: RegistrationStatus.approved,
          studentCount: 3,
        ),
      ),
      isNull,
    );
  });
}
