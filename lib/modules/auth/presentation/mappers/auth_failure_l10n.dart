import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';

String authFailureMessage(AppLocalizations l10n, AuthFailure failure) {
  return switch (failure) {
    InvalidCredentialsAuthFailure() => l10n.loginErrorInvalidCredentials,
    EmailNotVerifiedAuthFailure() => l10n.loginErrorEmailNotVerified,
    AccountLockedAuthFailure() => l10n.loginErrorAccountLocked,
    AccountDisabledAuthFailure() => l10n.loginErrorAccountDisabled,
    TooManyRequestsAuthFailure() => l10n.authErrorTooManyRequests,
    GoogleSignInAuthFailure() ||
    RegistrationRequiredAuthFailure() => l10n.loginErrorGoogle,
    CancelledAuthFailure() ||
    NetworkAuthFailure() ||
    UnexpectedAuthFailure() => l10n.loginFailed,
  };
}
