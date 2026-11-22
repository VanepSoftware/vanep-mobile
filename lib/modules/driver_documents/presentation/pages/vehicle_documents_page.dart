import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_groups.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/compliance_state_view.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_status_card.dart';

typedef OpenVehicleDocument = void Function(
  DocumentEntry entry,
  VehicleCompliance vehicle,
);

class VehicleDocumentsPage extends StatelessWidget {
  const VehicleDocumentsPage({
    required this.onOpenDocument,
    required this.onRegisterVan,
    this.onlyVehicleToken,
    super.key,
  });

  final OpenVehicleDocument onOpenDocument;
  final VoidCallback onRegisterVan;
  final String? onlyVehicleToken;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(
        title: onlyVehicleToken == null
            ? l10n.driverDocumentsVansTitle
            : l10n.driverDocumentsVanTitle,
      ),
      body: ComplianceStateView(
        builder: (context, compliance) => VehicleDocumentsList(
          compliance: compliance,
          onlyVehicleToken: onlyVehicleToken,
          onOpenDocument: onOpenDocument,
          onRegisterVan: onRegisterVan,
        ),
      ),
    );
  }
}

class VehicleDocumentsList extends StatelessWidget {
  const VehicleDocumentsList({
    required this.compliance,
    required this.onlyVehicleToken,
    required this.onOpenDocument,
    required this.onRegisterVan,
    super.key,
  });

  final DriverCompliance compliance;
  final String? onlyVehicleToken;
  final OpenVehicleDocument onOpenDocument;
  final VoidCallback onRegisterVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vans = groupVehicleDocuments(
      compliance.vehicles,
      compliance.asOf,
      onlyVehicleToken: onlyVehicleToken,
    );
    if (vans.isEmpty) return NoVanDocuments(onRegisterVan: onRegisterVan);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        for (final van in vans) ...[
          DocumentEntriesSection(
            title: l10n.vanStudentsCaption(
              van.vehicle.model,
              van.vehicle.plate,
            ),
            trailing: van.isUpToDate
                ? l10n.driverDocumentsVanUpToDate
                : l10n.driverDocumentsVanPendingCount(van.pendingCount),
            entries: van.groups.all,
            onOpen: (entry) => onOpenDocument(entry, van.vehicle),
          ),
          const SizedBox(height: 12),
        ],
        DocumentsPrivacyNote(text: l10n.driverDocumentsVansPrivacy),
      ],
    );
  }
}

class NoVanDocuments extends StatelessWidget {
  const NoVanDocuments({required this.onRegisterVan, super.key});

  final VoidCallback onRegisterVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
      children: [
        Icon(
          Icons.airport_shuttle_outlined,
          size: 48,
          color: context.palette.textSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.driverDocumentsNoVanTitle,
          textAlign: TextAlign.center,
          style: context.typography.cardTitle,
        ),
        const SizedBox(height: 20),
        VanepPrimaryButton(
          label: l10n.driverDocumentsNoVanAction,
          onPressed: onRegisterVan,
        ),
      ],
    );
  }
}
