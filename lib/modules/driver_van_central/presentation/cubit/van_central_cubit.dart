import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver_service_areas/domain/usecases/find_my_service_areas.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/change_accepting_students.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/list_van_assistants.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';

class VanCentralCubit extends Cubit<VanCentralState> {
  VanCentralCubit({
    required this.listMyVans,
    required this.findMyServiceAreas,
    required this.findDriverOccupancy,
    required this.findDriverAttendance,
    required this.changeAcceptingStudents,
    required this.listVanAssistants,
  }) : super(const VanCentralState());

  final ListMyVans listMyVans;
  final FindMyServiceAreas findMyServiceAreas;
  final FindDriverOccupancy findDriverOccupancy;
  final FindDriverAttendance findDriverAttendance;
  final ChangeAcceptingStudents changeAcceptingStudents;
  final ListVanAssistants listVanAssistants;

  Future<void> load() async {
    emit(const VanCentralState());
    await refresh();
  }

  Future<void> refresh() async {
    final vansCall = listMyVans();
    final occupancyCall = findDriverOccupancy();
    final attendanceCall = findDriverAttendance();
    final assistantsCall = listVanAssistants();
    final areasCall = findMyServiceAreas();

    final vans = (await vansCall).valueOrNull;
    final occupancy = (await occupancyCall).valueOrNull;
    final attendance = (await attendanceCall).valueOrNull;
    final assistants = (await assistantsCall).valueOrNull;
    final serviceAreas = (await areasCall).valueOrNull;

    if (vans == null) {
      emit(const VanCentralState(status: VanCentralStatus.loadFailed));
      return;
    }
    emit(
      VanCentralState(
        status: VanCentralStatus.loaded,
        vans: vans,
        selectedVanToken: keepSelectedVanToken(vans, state.selectedVanToken),
        occupancy: occupancy,
        attendance: attendance,
        assistants: assistants,
        serviceAreas: serviceAreas,
      ),
    );
  }

  void selectVan(String vanToken) {
    emit(state.copyWith(selectedVanToken: vanToken));
  }

  Future<void> setAcceptingStudents(bool acceptingStudents) async {
    if (state.isChangingAttendance) return;
    emit(state.copyWith(isChangingAttendance: true));
    final result = await changeAcceptingStudents(
      acceptingStudents: acceptingStudents,
    );
    emit(
      result.fold(
        (_) => state.copyWith(notice: const AttendanceChangeFailedNotice()),
        (attendance) => state.copyWith(attendance: attendance),
      ),
    );
  }

  void clearNotice() {
    if (state.notice == null) return;
    emit(state.copyWith());
  }
}

String? keepSelectedVanToken(List<DriverVan> vans, String? selectedVanToken) {
  if (vans.isEmpty) return null;
  final stillThere = vans.any((van) => van.token == selectedVanToken);
  return stillThere ? selectedVanToken : vans.first.token;
}
