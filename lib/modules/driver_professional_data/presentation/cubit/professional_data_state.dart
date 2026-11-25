import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';

enum ProfessionalDataStatus { loading, ready, failed }

class ProfessionalDataState extends Equatable {
  const ProfessionalDataState({
    this.status = ProfessionalDataStatus.loading,
    this.summary,
    this.attendance,
    this.isChangingAttendance = false,
    this.attendanceChangeFailed = false,
  });

  final ProfessionalDataStatus status;
  final DriverProfileSummary? summary;
  final DriverAttendance? attendance;
  final bool isChangingAttendance;
  final bool attendanceChangeFailed;

  ProfessionalDataState copyWith({
    ProfessionalDataStatus? status,
    DriverProfileSummary? summary,
    DriverAttendance? attendance,
    bool? isChangingAttendance,
    bool? attendanceChangeFailed,
  }) {
    return ProfessionalDataState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      attendance: attendance ?? this.attendance,
      isChangingAttendance: isChangingAttendance ?? this.isChangingAttendance,
      attendanceChangeFailed:
          attendanceChangeFailed ?? this.attendanceChangeFailed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    summary,
    attendance,
    isChangingAttendance,
    attendanceChangeFailed,
  ];
}
