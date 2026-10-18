import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';

class AssistantChecklistState extends Equatable {
  const AssistantChecklistState({
    this.isLoading = false,
    this.isUpdating = false,
    this.vanToken,
    this.stops = const [],
    this.selectedStudentTokens = const {},
    this.searchQuery = '',
    this.statusFilter,
    this.isLinkRevoked = false,
    this.failure,
  });

  final bool isLoading;

  final bool isUpdating;

  final String? vanToken;

  final List<AssistantTripStop> stops;

  final Set<String> selectedStudentTokens;

  final String searchQuery;

  final BoardingStatus? statusFilter;

  final bool isLinkRevoked;

  final AssistantFailure? failure;

  List<AssistantChecklistItem> get allStudents {
    final seen = <String>{};
    final result = <AssistantChecklistItem>[];
    for (final stop in stops) {
      for (final student in stop.items) {
        if (seen.add(student.studentToken)) {
          result.add(student);
        }
      }
    }
    return result;
  }

  List<AssistantChecklistItem> get filteredStudents {
    final query = searchQuery.trim().toLowerCase();
    return allStudents.where((student) {
      final matchesFilter =
          statusFilter == null || student.status == statusFilter;
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      return student.studentName.toLowerCase().contains(query) ||
          student.schoolName.toLowerCase().contains(query);
    }).toList();
  }

  int get totalCount => allStudents.length;

  int get completedCount =>
      allStudents.where((s) => s.status != BoardingStatus.pending).length;

  AssistantChecklistState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? Function()? vanToken,
    List<AssistantTripStop>? stops,
    Set<String>? selectedStudentTokens,
    String? searchQuery,
    BoardingStatus? Function()? statusFilter,
    bool? isLinkRevoked,
    AssistantFailure? Function()? failure,
  }) {
    return AssistantChecklistState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      vanToken: vanToken != null ? vanToken() : this.vanToken,
      stops: stops ?? this.stops,
      selectedStudentTokens:
          selectedStudentTokens ?? this.selectedStudentTokens,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      isLinkRevoked: isLinkRevoked ?? this.isLinkRevoked,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isUpdating,
    vanToken,
    stops,
    selectedStudentTokens,
    searchQuery,
    statusFilter,
    isLinkRevoked,
    failure,
  ];
}
