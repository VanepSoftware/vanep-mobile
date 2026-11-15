import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_family_filter.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/van_student_list.dart';

enum VanStudentsStatus { loading, loaded, loadFailed }

sealed class VanStudentsNotice extends Equatable {
  const VanStudentsNotice();

  @override
  List<Object?> get props => const [];
}

final class VanStudentsMergedNotice extends VanStudentsNotice {
  const VanStudentsMergedNotice({required this.studentName});

  final String studentName;

  @override
  List<Object?> get props => [studentName];
}

final class VanStudentsDismissedNotice extends VanStudentsNotice {
  const VanStudentsDismissedNotice();
}

final class VanStudentsActionFailedNotice extends VanStudentsNotice {
  const VanStudentsActionFailedNotice({required this.failure});

  final DriverStudentFailure failure;

  @override
  List<Object?> get props => [failure];
}

class VanStudentsShareRequest extends Equatable {
  const VanStudentsShareRequest({required this.inviteUrl, this.studentName});

  final String inviteUrl;

  final String? studentName;

  @override
  List<Object?> get props => [inviteUrl, studentName];
}

class VanStudentsState extends Equatable {
  VanStudentsState({
    this.status = VanStudentsStatus.loading,
    this.students = const [],
    this.familyFilter = StudentFamilyFilter.all,
    this.disabledShifts = const {},
    this.query = '',
    this.isSearching = false,
    this.busyStudentToken,
    this.isSharingGroupLink = false,
    this.notice,
    this.shareRequest,
  }) : summary = summarizeVanStudents(
         students,
         familyFilter: familyFilter,
         disabledShifts: disabledShifts,
         query: query,
       );

  final VanStudentsStatus status;
  final List<DriverStudent> students;
  final StudentFamilyFilter familyFilter;
  final Set<OperationShift> disabledShifts;
  final String query;
  final bool isSearching;
  final String? busyStudentToken;
  final bool isSharingGroupLink;
  final VanStudentsNotice? notice;
  final VanStudentsShareRequest? shareRequest;
  final VanStudentSummary summary;

  List<OperationShift> get shifts => summary.shifts;

  Set<OperationShift> get enabledShifts => summary.enabledShifts;

  List<DriverStudent> get visibleStudents => summary.visibleStudents;

  Map<StudentFamilyFilter, int> get counts => summary.counts;

  DriverStudent? get pendingMatch => summary.pendingMatch;

  FamilyProgress get progress => summary.progress;

  bool isBusy(String studentToken) => busyStudentToken == studentToken;

  VanStudentsState copyWith({
    VanStudentsStatus? status,
    List<DriverStudent>? students,
    StudentFamilyFilter? familyFilter,
    Set<OperationShift>? disabledShifts,
    String? query,
    bool? isSearching,
    String? busyStudentToken,
    bool clearBusyStudent = false,
    bool? isSharingGroupLink,
    VanStudentsNotice? notice,
    bool clearNotice = false,
    VanStudentsShareRequest? shareRequest,
    bool clearShareRequest = false,
  }) {
    return VanStudentsState(
      status: status ?? this.status,
      students: students ?? this.students,
      familyFilter: familyFilter ?? this.familyFilter,
      disabledShifts: disabledShifts ?? this.disabledShifts,
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      busyStudentToken: clearBusyStudent
          ? null
          : busyStudentToken ?? this.busyStudentToken,
      isSharingGroupLink: isSharingGroupLink ?? this.isSharingGroupLink,
      notice: clearNotice ? null : notice ?? this.notice,
      shareRequest: clearShareRequest
          ? null
          : shareRequest ?? this.shareRequest,
    );
  }

  @override
  List<Object?> get props => [
    status,
    students,
    familyFilter,
    disabledShifts,
    query,
    isSearching,
    busyStudentToken,
    isSharingGroupLink,
    notice,
    shareRequest,
  ];
}
