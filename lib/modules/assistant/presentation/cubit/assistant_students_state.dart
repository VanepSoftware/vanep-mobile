import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/filter_assistant_students.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';

enum AssistantStudentsStatus { loading, ready, loadFailed }

class AssistantStudentsState extends Equatable {
  const AssistantStudentsState({
    this.status = AssistantStudentsStatus.loading,
    this.overview,
    this.failure,
    this.selectedRosterIndex = 0,
    this.query = '',
  });

  final AssistantStudentsStatus status;

  final AssistantStudentsOverview? overview;

  final AssistantFailure? failure;

  final int selectedRosterIndex;

  final String query;

  AssistantStudentsRoster? get selectedRoster {
    final rosters = overview?.rosters ?? const [];
    if (selectedRosterIndex >= rosters.length) return null;
    return rosters[selectedRosterIndex];
  }

  List<AssistantStudentSummary> get visibleStudents {
    final roster = selectedRoster;
    if (roster == null) return const [];
    return filterAssistantStudents(roster.students, query);
  }

  AssistantStudentsState copyWith({int? selectedRosterIndex, String? query}) {
    return AssistantStudentsState(
      status: status,
      overview: overview,
      failure: failure,
      selectedRosterIndex: selectedRosterIndex ?? this.selectedRosterIndex,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overview,
    failure,
    selectedRosterIndex,
    query,
  ];
}
