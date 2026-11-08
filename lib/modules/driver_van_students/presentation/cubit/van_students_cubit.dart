import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/dismiss_student_family_match.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/find_parents_group_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/invite_student_family.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/list_driver_students.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/usecases/merge_student_family.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/van_student_list.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/van_students_state.dart';

class VanStudentsCubit extends Cubit<VanStudentsState> {
  VanStudentsCubit({
    required this.vehicleToken,
    required this.listDriverStudents,
    required this.findDriverOccupancy,
    required this.inviteStudentFamily,
    required this.findParentsGroupInvite,
    required this.mergeStudentFamily,
    required this.dismissStudentFamilyMatch,
  }) : super(const VanStudentsState());

  final String? vehicleToken;
  final ListDriverStudents listDriverStudents;
  final FindDriverOccupancy findDriverOccupancy;
  final InviteStudentFamily inviteStudentFamily;
  final FindParentsGroupInvite findParentsGroupInvite;
  final MergeStudentFamily mergeStudentFamily;
  final DismissStudentFamilyMatch dismissStudentFamilyMatch;

  Future<void> load() async {
    emit(state.copyWith(status: VanStudentsStatus.loading));
    await refresh();
  }

  Future<void> refresh() async {
    final studentsFuture = listDriverStudents(vehicleToken: vehicleToken);
    final occupancyFuture = findDriverOccupancy();
    final students = await studentsFuture;
    final occupancy = await occupancyFuture;
    if (isClosed) return;
    emit(switch ((students, occupancy)) {
      (Ok(value: final students), Ok(value: final occupancy)) => state.copyWith(
        status: VanStudentsStatus.loaded,
        students: students,
        occupancy: occupancy,
      ),
      _ when state.status == VanStudentsStatus.loaded => state,
      _ => state.copyWith(status: VanStudentsStatus.loadFailed),
    });
  }

  void selectFamilyFilter(StudentFamilyFilter familyFilter) {
    emit(state.copyWith(familyFilter: familyFilter));
  }

  void toggleShift(OperationShift shift) {
    emit(
      state.copyWith(
        disabledShifts: toggleDisabledShift(
          inUse: state.shifts,
          disabled: state.disabledShifts,
          shift: shift,
        ),
      ),
    );
  }

  void openSearch() => emit(state.copyWith(isSearching: true));

  void closeSearch() => emit(state.copyWith(isSearching: false, query: ''));

  void changeQuery(String query) => emit(state.copyWith(query: query));

  Future<void> inviteFamily(DriverStudent student) async {
    if (state.busyStudentToken != null) return;
    emit(state.copyWith(busyStudentToken: student.token));
    final result = await inviteStudentFamily(student.token);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            clearBusyStudent: true,
            shareRequest: VanStudentsShareRequest(
              inviteUrl: value.inviteUrl,
              studentName: student.name,
            ),
          ),
        );
        await refresh();
      case Err(:final error):
        emitActionFailure(error);
    }
  }

  Future<void> shareParentsGroupLink() async {
    if (state.isSharingGroupLink) return;
    emit(state.copyWith(isSharingGroupLink: true));
    final result = await findParentsGroupInvite();
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(
        isSharingGroupLink: false,
        shareRequest: VanStudentsShareRequest(inviteUrl: value.inviteUrl),
      ),
      Err(:final error) => state.copyWith(
        isSharingGroupLink: false,
        notice: VanStudentsActionFailedNotice(failure: error),
      ),
    });
  }

  Future<void> mergeFamily(DriverStudent student) async {
    final match = student.familyMatch;
    if (state.busyStudentToken != null || match == null) return;
    emit(state.copyWith(busyStudentToken: student.token));
    final result = await mergeStudentFamily(student.token);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          state.copyWith(
            clearBusyStudent: true,
            notice: VanStudentsMergedNotice(studentName: match.dependentName),
          ),
        );
        await refresh();
      case Err(:final error):
        emitActionFailure(error);
        await refresh();
    }
  }

  Future<void> dismissFamilyMatch(DriverStudent student) async {
    if (state.busyStudentToken != null) return;
    emit(state.copyWith(busyStudentToken: student.token));
    final result = await dismissStudentFamilyMatch(student.token);
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          state.copyWith(
            clearBusyStudent: true,
            notice: const VanStudentsDismissedNotice(),
          ),
        );
        await refresh();
      case Err(:final error):
        emitActionFailure(error);
        await refresh();
    }
  }

  void emitActionFailure(DriverStudentFailure failure) {
    emit(
      state.copyWith(
        clearBusyStudent: true,
        notice: VanStudentsActionFailedNotice(failure: failure),
      ),
    );
  }

  void clearNotice() => emit(state.copyWith(clearNotice: true));

  void clearShareRequest() => emit(state.copyWith(clearShareRequest: true));
}
