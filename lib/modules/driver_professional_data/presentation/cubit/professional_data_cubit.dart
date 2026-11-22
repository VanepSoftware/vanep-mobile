import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/driver_professional_data/presentation/cubit/professional_data_state.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/change_accepting_students.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_attendance.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/get_profile_summary.dart';

export 'package:vanep_mobile/modules/driver_professional_data/presentation/cubit/professional_data_state.dart';

class ProfessionalDataCubit extends Cubit<ProfessionalDataState> {
  ProfessionalDataCubit({
    required this.getProfileSummary,
    required this.findDriverAttendance,
    required this.changeAcceptingStudents,
  }) : super(const ProfessionalDataState());

  final GetProfileSummary getProfileSummary;
  final FindDriverAttendance findDriverAttendance;
  final ChangeAcceptingStudents changeAcceptingStudents;

  Future<void> load() async {
    emit(const ProfessionalDataState());
    final (summary, attendance) = await (
      getProfileSummary(UserType.driver),
      findDriverAttendance(),
    ).wait;
    if (isClosed) return;
    final driver = summary.valueOrNull;
    if (driver is! DriverProfileSummary) {
      emit(const ProfessionalDataState(status: ProfessionalDataStatus.failed));
      return;
    }
    emit(
      ProfessionalDataState(
        status: ProfessionalDataStatus.ready,
        summary: driver,
        attendance: attendance.valueOrNull,
      ),
    );
  }

  Future<void> setAcceptingStudents(bool acceptingStudents) async {
    if (state.isChangingAttendance) return;
    emit(
      state.copyWith(isChangingAttendance: true, attendanceChangeFailed: false),
    );
    final result = await changeAcceptingStudents(
      acceptingStudents: acceptingStudents,
    );
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final attendance) => state.copyWith(
        attendance: attendance,
        isChangingAttendance: false,
      ),
      Err() => state.copyWith(
        isChangingAttendance: false,
        attendanceChangeFailed: true,
      ),
    });
  }

  void clearAttendanceFailure() =>
      emit(state.copyWith(attendanceChangeFailed: false));
}
