import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

class DocumentStatusStyle {
  const DocumentStatusStyle({
    required this.label,
    required this.icon,
    required this.color,
    this.detail,
    this.detailColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String? detail;
  final Color? detailColor;
}

String documentTypeLabel(AppLocalizations l10n, DocumentType type) {
  return switch (type) {
    DocumentType.driverLicense => l10n.documentTypeDriverLicense,
    DocumentType.schoolDriverCourse => l10n.documentTypeSchoolDriverCourse,
    DocumentType.criminalRecord => l10n.documentTypeCriminalRecord,
    DocumentType.municipalAuthorization =>
      l10n.documentTypeMunicipalAuthorization,
    DocumentType.vehicleRegistration => l10n.documentTypeVehicleRegistration,
    DocumentType.vehicleInspection => l10n.documentTypeVehicleInspection,
    DocumentType.schoolVehicleAuthorization =>
      l10n.documentTypeSchoolVehicleAuthorization,
  };
}

IconData documentTypeIcon(DocumentType type) {
  return switch (type) {
    DocumentType.driverLicense => Icons.badge_outlined,
    DocumentType.schoolDriverCourse => Icons.school_outlined,
    DocumentType.criminalRecord => Icons.gavel_outlined,
    DocumentType.municipalAuthorization => Icons.account_balance_outlined,
    DocumentType.vehicleRegistration => Icons.directions_car_outlined,
    DocumentType.vehicleInspection => Icons.fact_check_outlined,
    DocumentType.schoolVehicleAuthorization => Icons.verified_outlined,
  };
}

DocumentStatusStyle documentStatusStyleOf(
  AppLocalizations l10n,
  VanepPalette palette,
  DocumentDisplayState state,
) {
  return switch (state) {
    DocumentNotSent(:final isOptional) => DocumentStatusStyle(
      label: isOptional
          ? l10n.documentStateNotSentOptional
          : l10n.documentStateNotSent,
      icon: Icons.radio_button_unchecked,
      color: palette.textSecondary,
    ),
    DocumentRejected() => DocumentStatusStyle(
      label: l10n.documentStateRejected,
      icon: Icons.cancel,
      color: palette.dangerText,
    ),
    DocumentExpired() => DocumentStatusStyle(
      label: l10n.documentStateExpired,
      icon: Icons.event_busy,
      color: palette.dangerText,
    ),
    DocumentUnderReview() => DocumentStatusStyle(
      label: l10n.documentStateUnderReview,
      icon: Icons.schedule,
      color: palette.action,
    ),
    DocumentRenewalUnderReview() => DocumentStatusStyle(
      label: l10n.documentStateApproved,
      icon: Icons.check_circle,
      color: palette.success,
      detail: l10n.documentStateRenewalUnderReview,
      detailColor: palette.action,
    ),
    DocumentExpiringSoon(:final daysLeft) => DocumentStatusStyle(
      label: l10n.documentStateExpiringSoon(daysLeft),
      icon: Icons.error,
      color: palette.warningText,
    ),
    DocumentApproved() => DocumentStatusStyle(
      label: l10n.documentStateApproved,
      icon: Icons.check_circle,
      color: palette.success,
    ),
  };
}
