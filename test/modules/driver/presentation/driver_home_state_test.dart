import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_state.dart';

void main() {
  test('default state is off shift, not sharing, empty shift time', () {
    const state = DriverHomeState();

    expect(state.shift, DriverShift.off);
    expect(state.onShift, isFalse);
    expect(state.sharingLocation, isFalse);
    expect(state.shiftStartTime, '');
  });

  test('onShift is true when the shift is on', () {
    const state = DriverHomeState(shift: DriverShift.on);

    expect(state.onShift, isTrue);
  });

  test('copyWith overrides only the provided fields', () {
    const state = DriverHomeState(shiftStartTime: '6h00');

    final updated = state.copyWith(sharingLocation: true);

    expect(updated.sharingLocation, isTrue);
    expect(updated.shiftStartTime, '6h00');
    expect(updated.shift, DriverShift.off);
  });
}
