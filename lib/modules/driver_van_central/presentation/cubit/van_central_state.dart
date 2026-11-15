import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';

enum VanCentralStatus { loading, loaded, loadFailed }

sealed class VanCentralNotice extends Equatable {
  const VanCentralNotice();

  @override
  List<Object?> get props => [];
}

class AttendanceChangeFailedNotice extends VanCentralNotice {
  const AttendanceChangeFailedNotice();
}

class VanCentralState extends Equatable {
  const VanCentralState({
    this.status = VanCentralStatus.loading,
    this.vans = const [],
    this.selectedVanToken,
    this.occupancy,
    this.attendance,
    this.assistants,
    this.serviceAreas,
    this.isChangingAttendance = false,
    this.notice,
  });

  final VanCentralStatus status;
  final List<DriverVan> vans;
  final String? selectedVanToken;
  final DriverOccupancy? occupancy;
  final DriverAttendance? attendance;
  final List<VanAssistant>? assistants;
  final List<ServiceArea>? serviceAreas;
  final bool isChangingAttendance;
  final VanCentralNotice? notice;

  bool get hasVans => vans.isNotEmpty;

  // The API reports totals for the driver, not for an individual vehicle.
  DriverOccupancy? get selectedVanOccupancy => vans.length == 1 ? occupancy : null;

  DriverVan? get selectedVan {
    if (vans.isEmpty) return null;
    for (final van in vans) {
      if (van.token == selectedVanToken) return van;
    }
    return vans.first;
  }

  bool get hasWorkingAssistant => (assistants ?? const []).working.isNotEmpty;

  VanCentralState copyWith({
    VanCentralStatus? status,
    List<DriverVan>? vans,
    String? selectedVanToken,
    DriverOccupancy? occupancy,
    DriverAttendance? attendance,
    List<VanAssistant>? assistants,
    List<ServiceArea>? serviceAreas,
    bool? isChangingAttendance,
    VanCentralNotice? notice,
  }) {
    return VanCentralState(
      status: status ?? this.status,
      vans: vans ?? this.vans,
      selectedVanToken: selectedVanToken ?? this.selectedVanToken,
      occupancy: occupancy ?? this.occupancy,
      attendance: attendance ?? this.attendance,
      assistants: assistants ?? this.assistants,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      isChangingAttendance: isChangingAttendance ?? false,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    vans,
    selectedVanToken,
    occupancy,
    attendance,
    assistants,
    serviceAreas,
    isChangingAttendance,
    notice,
  ];
}
