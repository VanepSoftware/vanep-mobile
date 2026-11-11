import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_state.dart';

void main() {
  test('default does not invent approval or an active trip', () {
    const state = DriverHomeState();
    expect(state.data, isNull);
    expect(state.shift, DriverShift.off);
    expect(state.onShift, isFalse);
    expect(state.sharingLocation, isFalse);
  });
  test('shift reflects the trip from the repository', () {
    const state = DriverHomeState(
      data: DriverHomeData(
        registration: RegistrationStatus.approved,
        todayTrip: Trip(
          id: 'trip',
          status: TripStatus.inProgress,
          label: 'Manhã',
        ),
      ),
    );
    expect(state.onShift, isTrue);
  });
  test('copyWith preserves data and can clear errors explicitly', () {
    const state = DriverHomeState(
      shiftStartTime: '6h00',
      error: DriverHomeMessage.actionFailed,
    );
    final updated = state.copyWith(sharingLocation: true, clearError: true);
    expect(updated.sharingLocation, isTrue);
    expect(updated.shiftStartTime, '6h00');
    expect(updated.error, isNull);
  });
}
