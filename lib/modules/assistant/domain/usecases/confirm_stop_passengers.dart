import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

NoShowReason defaultSkipReasonAt(AssistantRouteStop stop) =>
    stop.kind.isBoarding ? NoShowReason.notAtStop : NoShowReason.other;

StopConfirmation buildStopConfirmation({
  required String vanToken,
  required AssistantRouteSnapshot route,
  required AssistantRouteStop stop,
  required Set<String> selectedPassengerTokens,
  Map<String, NoShowReason> reasons = const {},
  Map<String, String> notes = const {},
}) {
  final pending = route.passengersToConfirmAt(stop);
  final skipped = {
    for (final passenger in pending)
      if (!selectedPassengerTokens.contains(passenger.token)) passenger.token,
  };
  return StopConfirmation(
    skipNotes: {
      for (final MapEntry(key: token, value: note) in notes.entries)
        if (skipped.contains(token) && note.trim().isNotEmpty)
          token: note.trim(),
    },
    vanToken: vanToken,
    stopToken: stop.token,
    confirmedPassengerTokens: [
      for (final passenger in pending)
        if (selectedPassengerTokens.contains(passenger.token)) passenger.token,
    ],
    skippedPassengers: {
      for (final passenger in pending)
        if (!selectedPassengerTokens.contains(passenger.token))
          passenger.token:
              reasons[passenger.token] ?? defaultSkipReasonAt(stop),
    },
  );
}

class ConfirmStopPassengers {
  const ConfirmStopPassengers(this.repository);

  final AssistantRouteRepository repository;

  Future<Result<AssistantFailure, AssistantRouteSnapshot>> call(
    StopConfirmation confirmation,
  ) {
    return repository.confirmStop(confirmation);
  }
}
