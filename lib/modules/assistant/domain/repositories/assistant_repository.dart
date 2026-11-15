import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

abstract class AssistantRepository {
  Future<Result<AssistantFailure, AssistantInvite>> validateInvite(
    String codeOrToken,
  );

  Future<Result<AssistantFailure, void>> registerWithInvite({
    required String inviteToken,
    required String name,
    required String birthDate,
    required String email,
    required String cpf,
    required String password,
    bool acceptTerms = true,
  });

  Future<Result<AssistantFailure, List<AssistantVan>>> getLinkedVans();

  Future<Result<AssistantFailure, List<AssistantTripStop>>> getActiveTripRoute(
    String vanToken,
  );

  Future<Result<AssistantFailure, void>> updateChecklistStatus({
    required String vanToken,
    required List<String> studentTokens,
    required BoardingStatus status,
    required ConfirmationSource confirmedBy,
  });

  Future<Result<AssistantFailure, void>> recordNoShow({
    required String vanToken,
    required String studentToken,
    required NoShowReason reason,
    ConfirmationSource confirmedBy = ConfirmationSource.assistant,
  });
}
