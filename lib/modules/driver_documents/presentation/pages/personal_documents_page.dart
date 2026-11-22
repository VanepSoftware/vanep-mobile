import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_groups.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/compliance_state_view.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_status_card.dart';

class PersonalDocumentsPage extends StatelessWidget {
  const PersonalDocumentsPage({required this.onOpenDocument, super.key});

  final ValueChanged<DocumentEntry> onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(title: l10n.driverDocumentsPersonalTitle),
      body: ComplianceStateView(
        builder: (context, compliance) => PersonalDocumentsList(
          compliance: compliance,
          onOpenDocument: onOpenDocument,
        ),
      ),
    );
  }
}

class PersonalDocumentsList extends StatelessWidget {
  const PersonalDocumentsList({
    required this.compliance,
    required this.onOpenDocument,
    super.key,
  });

  final DriverCompliance compliance;
  final ValueChanged<DocumentEntry> onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = groupDocuments(
      compliance.driverRequirements,
      compliance.asOf,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        for (final (title, entries) in [
          (l10n.driverDocumentsPendingSection, groups.pending),
          (l10n.driverDocumentsSentSection, groups.sent),
          (l10n.driverDocumentsOptionalSection, groups.optional),
        ])
          if (entries.isNotEmpty) ...[
            DocumentEntriesSection(
              title: title,
              trailing: '${entries.length}',
              entries: entries,
              onOpen: onOpenDocument,
            ),
            const SizedBox(height: 12),
          ],
        DocumentsPrivacyNote(text: l10n.driverDocumentsPersonalPrivacy),
      ],
    );
  }
}
