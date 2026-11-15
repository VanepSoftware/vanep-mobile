import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

enum QuoteRequestStatus { initial, loading, ready, loadFailed }

class QuoteRequestState extends Equatable {
  const QuoteRequestState({
    this.status = QuoteRequestStatus.initial,
    this.setup,
    this.draft,
    this.today,
    this.isSending = false,
    this.failure,
    this.sentRequest,
    this.existingNegotiation,
  });

  final QuoteRequestStatus status;

  final QuoteRequestSetup? setup;

  final ServiceRequestDraft? draft;

  final DateTime? today;

  final bool isSending;

  final NegotiationFailure? failure;

  final ClientServiceRequest? sentRequest;

  final ClientServiceRequest? existingNegotiation;

  DriverProfile? get driver => setup?.driver;

  List<QuoteStudent> get students => setup?.students.students ?? const [];

  Set<ContractReadinessField> get clientGaps =>
      setup?.students.clientGaps ?? const {};

  int get openCount => setup?.openCount ?? 0;

  bool get hasReachedLimit => setup?.hasReachedOpenRequestsLimit ?? false;

  bool get canSend {
    final setup = this.setup;
    final draft = this.draft;
    final today = this.today;
    if (setup == null || draft == null || today == null || isSending) {
      return false;
    }
    return setup.allowsSending(draft, today: today);
  }

  QuoteStudent? studentWithToken(String dependentToken) =>
      setup?.students.studentWithToken(dependentToken);

  QuoteRequestState copyWith({
    QuoteRequestSetup? setup,
    ServiceRequestDraft? draft,
    bool? isSending,
    NegotiationFailure? failure,
    ClientServiceRequest? sentRequest,
    ClientServiceRequest? existingNegotiation,
  }) {
    return QuoteRequestState(
      status: status,
      setup: setup ?? this.setup,
      draft: draft ?? this.draft,
      today: today,
      isSending: isSending ?? false,
      failure: failure,
      sentRequest: sentRequest,
      existingNegotiation: existingNegotiation,
    );
  }

  @override
  List<Object?> get props => [
    status,
    setup,
    draft,
    today,
    isSending,
    failure,
    sentRequest,
    existingNegotiation,
  ];
}
