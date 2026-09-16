import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/auth_failure.dart';

String authFailureMessage(AppLocalizations l10n, AuthFailure failure) {
  return switch (failure) {
    InvalidCredentialsAuthFailure() => l10n.loginErrorInvalidCredentials,
    EmailNotVerifiedAuthFailure() => l10n.loginErrorEmailNotVerified,
    AccountLockedAuthFailure() => l10n.loginErrorAccountLocked,
    AccountDisabledAuthFailure() => l10n.loginErrorAccountDisabled,
    TooManyRequestsAuthFailure() => l10n.authErrorTooManyRequests,
    CancelledAuthFailure() => l10n.loginCancelled,
    GoogleSignInAuthFailure() ||
    RegistrationRequiredAuthFailure() => l10n.loginErrorGoogle,
    InvalidStateAuthFailure() ||
    NetworkAuthFailure() ||
    UnexpectedAuthFailure() => l10n.loginFailed,
  };
}
