import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';

class AssistantStudentSummary extends Equatable {
  const AssistantStudentSummary({
    required this.token,
    required this.name,
    required this.stopNumber,
    required this.placeName,
    this.isAbsentToday = false,
    this.hasFamilyInApp = true,
  });

  final String token;

  final String name;

  final int stopNumber;

  final String placeName;

  final bool isAbsentToday;

  // False for a passenger the driver registered without the family in the app
  // (unlinked passenger, VAN-57); the list shows both kinds.
  final bool hasFamilyInApp;

  @override
  List<Object?> get props => [
    token,
    name,
    stopNumber,
    placeName,
    isAbsentToday,
    hasFamilyInApp,
  ];
}

class AssistantStudentsRoster extends Equatable {
  const AssistantStudentsRoster({required this.van, required this.students});

  final AssistantVan van;

  final List<AssistantStudentSummary> students;

  @override
  List<Object?> get props => [van, students];
}

class AssistantStudentsOverview extends Equatable {
  const AssistantStudentsOverview({this.rosters = const []});

  final List<AssistantStudentsRoster> rosters;

  @override
  List<Object?> get props => [rosters];
}
