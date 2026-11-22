import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/resolve_document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';

class DocumentsSummary extends Equatable {
  const DocumentsSummary({required this.pendingCount, this.nearestExpiryDays});

  final int pendingCount;
  final int? nearestExpiryDays;

  @override
  List<Object?> get props => [pendingCount, nearestExpiryDays];
}

DocumentsSummary summarizeDocuments(
  Iterable<RequirementStatus> requirements,
  DateTime asOf,
) {
  final states = [
    for (final requirement in requirements)
      (requirement, resolveDocumentDisplayState(requirement, asOf)),
  ];
  final expiringDays = [
    for (final (_, state) in states)
      if (state is DocumentExpiringSoon) state.daysLeft,
  ];
  return DocumentsSummary(
    pendingCount: states
        .where((entry) => !entry.$1.optional && countsAsPending(entry.$2))
        .length,
    nearestExpiryDays: expiringDays.isEmpty
        ? null
        : expiringDays.reduce((left, right) => left < right ? left : right),
  );
}

bool countsAsPending(DocumentDisplayState state) {
  return switch (state) {
    DocumentNotSent() ||
    DocumentIncomplete() ||
    DocumentRejected() ||
    DocumentExpired() => true,
    _ => false,
  };
}
