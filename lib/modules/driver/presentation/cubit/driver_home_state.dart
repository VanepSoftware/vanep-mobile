import 'package:equatable/equatable.dart';

enum DriverShift { off, on }

class DriverHomeState extends Equatable {
  const DriverHomeState({
    this.shift = DriverShift.off,
    this.sharingLocation = false,
    this.shiftStartTime = '',
  });

  final DriverShift shift;
  final bool sharingLocation;
  final String shiftStartTime;

  bool get onShift => shift == DriverShift.on;

  DriverHomeState copyWith({
    DriverShift? shift,
    bool? sharingLocation,
    String? shiftStartTime,
  }) {
    return DriverHomeState(
      shift: shift ?? this.shift,
      sharingLocation: sharingLocation ?? this.sharingLocation,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
    );
  }

  @override
  List<Object?> get props => [shift, sharingLocation, shiftStartTime];
}
