import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';

enum DriverShift { off, on }

class DriverHomeState extends Equatable {
  const DriverHomeState({
    this.data,
    this.loading = false,
    this.busy = false,
    this.error,
    this.sharingLocation = false,
    this.shiftStartTime = '',
  });

  final DriverHomeData? data;
  final bool loading;
  final bool busy;
  final DriverHomeMessage? error;
  final bool sharingLocation;
  final String shiftStartTime;

  bool get onShift => data?.isOperating ?? false;
  DriverShift get shift => onShift ? DriverShift.on : DriverShift.off;

  DriverHomeState copyWith({
    DriverHomeData? data,
    bool? loading,
    bool? busy,
    DriverHomeMessage? error,
    bool clearError = false,
    bool? sharingLocation,
    String? shiftStartTime,
  }) => DriverHomeState(
    data: data ?? this.data,
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
    sharingLocation: sharingLocation ?? this.sharingLocation,
    shiftStartTime: shiftStartTime ?? this.shiftStartTime,
  );

  @override
  List<Object?> get props => [
    data,
    loading,
    busy,
    error,
    sharingLocation,
    shiftStartTime,
  ];
}
