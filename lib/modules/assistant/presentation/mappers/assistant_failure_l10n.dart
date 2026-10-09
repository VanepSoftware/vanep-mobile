import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/assistant_failure.dart';

String assistantFailureMessage(
  AppLocalizations l10n,
  AssistantFailure failure,
) {
  return switch (failure) {
    AssistantFailure.invalidInviteCode => l10n.assistantFailureInvalidCode,
    AssistantFailure.expiredInvite => l10n.assistantFailureExpired,
    AssistantFailure.alreadyUsedInvite => l10n.assistantFailureAlreadyUsed,
    AssistantFailure.revokedInvite => l10n.assistantFailureRevoked,
    AssistantFailure.invalidPersonalData =>
      l10n.assistantFailureInvalidPersonalData,
    AssistantFailure.unauthorized => l10n.assistantFailureUnauthorized,
    AssistantFailure.network => l10n.assistantFailureNetwork,
    AssistantFailure.unexpected => l10n.assistantFailureUnexpected,
  };
}
