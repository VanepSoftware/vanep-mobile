import 'package:intl/intl.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/summarize_documents.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';

String? professionalHeaderLine(
  AppLocalizations l10n,
  DriverProfileSummary summary,
) {
  final rating = summary.rating;
  final count = summary.ratingCount ?? 0;
  final years = summary.experienceYears ?? 0;
  final parts = [
    if (rating != null && count > 0)
      l10n.professionalDataRating(
        NumberFormat('0.0', l10n.localeName).format(rating),
        count,
      ),
    if (years > 0) l10n.professionalDataExperience(years),
  ];
  return switch (parts) {
    [] => null,
    [final only] => only,
    [final first, final second, ...] => l10n.professionalDataHeaderLine(
      first,
      second,
    ),
  };
}

String? documentsRowWarning(AppLocalizations l10n, DocumentsSummary? summary) {
  if (summary == null) return null;
  final nearestExpiry = summary.nearestExpiryDays;
  if (summary.pendingCount > 0) {
    return l10n.driverDocumentsVanPendingCount(summary.pendingCount);
  }
  return nearestExpiry == null
      ? null
      : l10n.documentStateExpiringSoon(nearestExpiry);
}
