import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_quote_request.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class QuoteRequestCubit extends Cubit<QuoteRequestState> {
  QuoteRequestCubit({
    required this.driverToken,
    required this.loadQuoteRequest,
    required this.loadQuoteStudents,
    required this.listServiceRequests,
    required this.sendServiceRequest,
    this.clock = DateTime.now,
  }) : super(const QuoteRequestState());

  final String driverToken;

  final LoadQuoteRequest loadQuoteRequest;

  final LoadQuoteStudents loadQuoteStudents;

  final ListClientServiceRequests listServiceRequests;

  final SendServiceRequest sendServiceRequest;

  final DateTime Function() clock;

  Future<void> load() async {
    emit(const QuoteRequestState(status: QuoteRequestStatus.loading));
    final result = await loadQuoteRequest(driverToken);
    if (isClosed) return;
    final now = clock();
    final today = DateTime(now.year, now.month, now.day);
    emit(
      result.fold(
        (_) => const QuoteRequestState(status: QuoteRequestStatus.loadFailed),
        (setup) => QuoteRequestState(
          status: QuoteRequestStatus.ready,
          setup: setup,
          draft: ServiceRequestDraft(
            driverToken: driverToken,
            desiredStartDate: today,
          ),
          today: today,
        ),
      ),
    );
  }

  void toggleStudent(String dependentToken) {
    final draft = state.draft;
    final student = state.studentWithToken(dependentToken);
    if (draft == null || student == null || !student.isReady) return;
    emit(
      state.copyWith(
        draft: draft.isSelected(dependentToken)
            ? draft.withoutStudent(dependentToken)
            : draft.withStudent(dependentToken, [
                for (final day in student.week.days) day.weekday,
              ]),
      ),
    );
  }

  void toggleLeg(String dependentToken, Weekday weekday, RouteLeg leg) {
    final draft = state.draft;
    if (draft == null) return;
    final item = draft.items.where(
      (item) => item.dependentToken == dependentToken,
    );
    if (item.isEmpty) return;
    emit(
      state.copyWith(
        draft: draft.withLeg(
          dependentToken,
          weekday,
          leg,
          enabled: !item.single.hasLeg(weekday, leg),
        ),
      ),
    );
  }

  void changeStartDate(DateTime date) {
    final draft = state.draft;
    if (draft == null) return;
    emit(state.copyWith(draft: draft.withDesiredStartDate(date)));
  }

  void changeNotes(String notes) {
    final draft = state.draft;
    if (draft == null) return;
    emit(state.copyWith(draft: draft.withNotes(notes)));
  }

  Future<void> refreshReadiness() async {
    final result = await loadQuoteStudents();
    final setup = state.setup;
    final draft = state.draft;
    final students = result.valueOrNull;
    if (isClosed || setup == null || draft == null || students == null) return;
    emit(
      state.copyWith(
        setup: setup.copyWith(students: students),
        draft: students.keepReadyStudents(draft),
      ),
    );
  }

  Future<void> send() async {
    final draft = state.draft;
    if (draft == null || !state.canSend) return;
    emit(state.copyWith(isSending: true));
    final result = await sendServiceRequest(draft);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(sentRequest: value));
      case Err(error: final NegotiationConflictFailure failure):
        await showExistingNegotiation(failure);
      case Err(:final error):
        emit(state.copyWith(failure: error));
    }
  }

  Future<void> showExistingNegotiation(NegotiationFailure failure) async {
    final result = await listServiceRequests(
      statuses: openServiceRequestStatuses,
    );
    final setup = state.setup;
    if (isClosed || setup == null) return;
    final openRequests = result.valueOrNull?.items ?? setup.openRequests;
    emit(
      state.copyWith(
        setup: setup.copyWith(openRequests: openRequests),
        failure: failure,
        existingNegotiation: findOpenRequestWithDriver(
          openRequests,
          driverToken,
        ),
      ),
    );
  }
}
