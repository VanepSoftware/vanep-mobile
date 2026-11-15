import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';

class DriverNegotiations extends Equatable {
  const DriverNegotiations({
    required this.requests,
    required this.loadedAt,
    required this.totalCount,
    this.page = 0,
    this.isLastPage = true,
  });

  factory DriverNegotiations.fromFirstPage(
    NegotiationPage<DriverServiceRequest> firstPage, {
    required DateTime loadedAt,
  }) {
    return DriverNegotiations(
      requests: firstPage.items,
      loadedAt: loadedAt,
      totalCount: firstPage.totalElements,
      isLastPage: firstPage.isLast,
    );
  }

  final List<DriverServiceRequest> requests;

  final DateTime loadedAt;

  final int totalCount;

  final int page;

  final bool isLastPage;

  List<DriverServiceRequest> get pending => [
    for (final request in requests)
      if (driverTurnOf(request).isDriversTurn) request,
  ];

  List<DriverServiceRequest> get awaiting => [
    for (final request in requests)
      if (driverTurnOf(request) == DriverTurn.waitingForFamily) request,
  ];

  bool get isEmpty => pending.isEmpty && awaiting.isEmpty;

  bool get hasMore => !isLastPage;

  DriverNegotiations withNextPage(
    NegotiationPage<DriverServiceRequest> nextPage, {
    required int page,
  }) {
    final knownTokens = {for (final request in requests) request.token};
    return DriverNegotiations(
      requests: [
        ...requests,
        for (final request in nextPage.items)
          if (!knownTokens.contains(request.token)) request,
      ],
      loadedAt: loadedAt,
      totalCount: nextPage.totalElements,
      page: page,
      isLastPage: nextPage.isLast,
    );
  }

  @override
  List<Object?> get props => [requests, loadedAt, totalCount, page, isLastPage];
}
