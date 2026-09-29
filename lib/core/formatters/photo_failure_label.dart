import '../../l10n/app_localizations.dart';
import '../media/photo_failure.dart';

String photoFailureLabel(AppLocalizations l10n, PhotoFailure failure) {
  return switch (failure) {
    PhotoFailure.permissionDenied => l10n.photoFailurePermissionDenied,
    PhotoFailure.tooLarge => l10n.photoFailureTooLarge,
    PhotoFailure.unsupportedType => l10n.photoFailureUnsupportedType,
    PhotoFailure.network => l10n.photoFailureNetwork,
    PhotoFailure.unexpected => l10n.photoFailureUnexpected,
  };
}
