import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

Set<ContractReadinessField> clientGapsOf(ContractReadiness readiness) {
  return {
    for (final gap in readiness.gaps)
      if (gap.subject == ContractReadinessSubject.client) gap.field,
  };
}

ClientServiceRequest? findOpenRequestWithDriver(
  List<ClientServiceRequest> openRequests,
  String driverToken,
) {
  for (final request in openRequests) {
    if (request.driverToken == driverToken) return request;
  }
  return null;
}

class QuoteStudent extends Equatable {
  const QuoteStudent({
    required this.dependent,
    required this.week,
    this.gaps = const {},
  });

  final Dependent dependent;

  final SchoolWeek week;

  final Set<ContractReadinessField> gaps;

  bool get isReady => gaps.isEmpty && !week.isEmpty;

  @override
  List<Object?> get props => [dependent, week, gaps];
}

class QuoteStudents extends Equatable {
  const QuoteStudents({this.students = const [], this.clientGaps = const {}});

  final List<QuoteStudent> students;

  final Set<ContractReadinessField> clientGaps;

  QuoteStudent? studentWithToken(String dependentToken) {
    for (final student in students) {
      if (student.dependent.token == dependentToken) return student;
    }
    return null;
  }

  ServiceRequestDraft keepReadyStudents(ServiceRequestDraft draft) {
    final readyTokens = {
      for (final student in students)
        if (student.isReady) student.dependent.token,
    };
    return draft.withItems([
      for (final item in draft.items)
        if (readyTokens.contains(item.dependentToken)) item,
    ]);
  }

  @override
  List<Object?> get props => [students, clientGaps];
}

class QuoteRequestSetup extends Equatable {
  const QuoteRequestSetup({
    required this.driver,
    required this.students,
    required this.openRequests,
  });

  final DriverProfile driver;

  final QuoteStudents students;

  final List<ClientServiceRequest> openRequests;

  int get openCount => openRequests.length;

  bool get hasReachedOpenRequestsLimit => reachesOpenRequestsLimit(openCount);

  bool allowsSending(ServiceRequestDraft draft, {required DateTime today}) {
    return validateServiceRequestDraft(draft, today: today).isEmpty &&
        students.clientGaps.isEmpty &&
        !hasReachedOpenRequestsLimit &&
        driver.available;
  }

  QuoteRequestSetup copyWith({
    QuoteStudents? students,
    List<ClientServiceRequest>? openRequests,
  }) {
    return QuoteRequestSetup(
      driver: driver,
      students: students ?? this.students,
      openRequests: openRequests ?? this.openRequests,
    );
  }

  @override
  List<Object?> get props => [driver, students, openRequests];
}
