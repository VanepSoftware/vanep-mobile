import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/repositories/driver_home_repository.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';

class HomeRepository implements DriverHomeRepository {
  DriverHomeData data = const DriverHomeData(
    registration: RegistrationStatus.approved,
    todayTrip: Trip(id: 'trip', status: TripStatus.notStarted, label: 'Manhã'));
  int starts = 0;
  int confirmations = 0;
  bool failLoad = false;
  Completer<void>? startGate;
  @override
  Future<DriverHomeData> load() async {
    if (failLoad) throw StateError('offline');
    return data;
  }
  @override
  Future<void> startTrip(String tripId) async {
    starts++;
    if (startGate != null) await startGate!.future;
    data = const DriverHomeData(registration: RegistrationStatus.approved,
      todayTrip: Trip(id: 'trip', status: TripStatus.inProgress, label: 'Manhã'));
  }
  @override
  Future<void> confirmStop(StopConfirmation confirmation) async { confirmations++; }
}

void main() {
  late HomeRepository repository;
  late DriverHomeCubit cubit;
  setUp(() {
    repository = HomeRepository();
    cubit = DriverHomeCubit(repository: repository);
  });
  tearDown(() => cubit.close());

  test('RN-02 revalidates approval even when the screen had approved data', () async {
    await cubit.refresh();
    repository.data = const DriverHomeData(registration: RegistrationStatus.underReview);
    await cubit.startRoute();
    expect(repository.starts, 0);
    expect(cubit.state.error, contains('aprovado'));
  });
  test('outside working hours warns without denying start', () async {
    repository.data = const DriverHomeData(registration: RegistrationStatus.approved,
      outsideWorkingHours: true,
      todayTrip: Trip(id: 'trip', status: TripStatus.notStarted, label: 'Manhã'));
    await cubit.startRoute();
    expect(repository.starts, 1);
    expect(cubit.state.onShift, isTrue);
  });
  test('concurrent start commands produce a single mutation', () async {
    repository.startGate = Completer<void>();
    final first = cubit.startRoute();
    await cubit.startRoute();
    repository.startGate!.complete();
    await first;
    expect(repository.starts, 1);
  });
  test('a changed stop is rejected before mutation', () async {
    await cubit.confirmBySlide(const StopConfirmation(tripId: 'trip', stopId: 'old',
      studentId: 'student', studentName: 'Ana', action: StopAction.boarding));
    expect(repository.confirmations, 0);
    expect(cubit.state.error, contains('parada mudou'));
  });
  test('blocked active trip still accepts a matching slide confirmation', () async {
    const next = StopConfirmation(tripId: 'trip', stopId: 'stop', studentId: 's',
      studentName: 'Ana', action: StopAction.disembarking);
    repository.data = const DriverHomeData(registration: RegistrationStatus.approved,
      subscriptionBlocked: true, nextConfirmation: next,
      todayTrip: Trip(id: 'trip', status: TripStatus.inProgress, label: 'Manhã'));
    await cubit.confirmBySlide(next);
    expect(repository.confirmations, 1);
  });
  test('failed refresh preserves the last known trip', () async {
    await cubit.refresh();
    final previous = cubit.state.data;
    repository.failLoad = true;
    await cubit.refresh();
    expect(cubit.state.data, same(previous));
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.loading, isFalse);
  });
  test('missing repository never starts a local fake route', () async {
    final unavailable = DriverHomeCubit();
    await unavailable.startRoute();
    expect(unavailable.state.onShift, isFalse);
    expect(unavailable.state.error, isNotNull);
    await unavailable.close();
  });
}
