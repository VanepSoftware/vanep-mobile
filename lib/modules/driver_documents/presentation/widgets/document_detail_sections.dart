import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/document_submission.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_detail_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_status_card.dart';

class DocumentDetailStatusCard extends StatelessWidget {
  const DocumentDetailStatusCard({
    required this.requirement,
    required this.state,
    super.key,
  });

  final RequirementStatus requirement;
  final DocumentDisplayState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = documentStatusStyleOf(l10n, context.palette, state);
    final date = documentStateDate(l10n, state, requirement);
    final note = documentStateNote(l10n, state);
    final detail = style.detail;
    final rejected = state is DocumentRejected ? requirement.current : null;

    return VanepCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DocumentStatusLine(style: style)),
              if (date != null)
                Text(
                  date,
                  style: context.typography.cardSubtitle.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
            ],
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(
              detail,
              style: context.typography.cardSubtitle.copyWith(
                color: style.detailColor,
              ),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 10),
            Text(note, style: context.typography.body),
          ],
          if (rejected != null) ...[
            const SizedBox(height: 12),
            RejectionReasonBlock(submission: rejected),
          ],
        ],
      ),
    );
  }
}

class RejectionReasonBlock extends StatelessWidget {
  const RejectionReasonBlock({required this.submission, super.key});

  final DocumentSubmission submission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = submission.rejectionReason?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rejectionReasonLabel(l10n, submission.rejectionReasonCode),
          style: context.typography.cardTitle,
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(message, style: context.typography.body),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: context.palette.action,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.documentDetailVanepMessage,
                style: context.typography.cardSubtitle.copyWith(
                  color: context.palette.action,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class SentSubmissionCard extends StatelessWidget {
  const SentSubmissionCard({
    required this.submission,
    required this.vehicle,
    required this.onOpenFile,
    this.title,
    super.key,
  });

  final DocumentSubmission submission;
  final VehicleCompliance? vehicle;
  final ValueChanged<DocumentSubmission> onOpenFile;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heading = title;
    final number = submission.documentNumber;
    final category = submission.cnhCategory;
    final plate = vehicle?.plate;
    final expiresAt = submission.expiresAt;
    return VanepCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heading != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Text(heading, style: context.typography.cardTitle),
            ),
          if (submission.fileUrl != null)
            DetailRow(
              label: l10n.documentDetailFile,
              value:
                  submission.file?.originalName ??
                  l10n.documentDetailFileFallback,
              onTap: () => onOpenFile(submission),
            ),
          if (number != null)
            DetailRow(label: l10n.documentDetailNumber, value: number),
          if (category != null)
            DetailRow(label: l10n.documentDetailCategory, value: category),
          if (plate != null)
            DetailRow(label: l10n.documentDetailPlate, value: plate),
          if (expiresAt != null)
            DetailRow(
              label: l10n.documentDetailValidUntil,
              value: formatNumericDate(l10n, expiresAt),
            ),
          DetailRow(
            label: l10n.documentDetailSentOn,
            value: formatNumericDate(l10n, submission.createdAt.toLocal()),
          ),
        ],
      ),
    );
  }
}

class AboutDocumentCard extends StatelessWidget {
  const AboutDocumentCard({required this.type, super.key});

  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final validity = documentTypicalValidity(l10n, type);
    return VanepCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              documentAboutText(l10n, type),
              style: context.typography.body,
            ),
          ),
          DetailRow(
            label: l10n.documentDetailIssuer,
            value: documentIssuer(l10n, type),
          ),
          if (validity != null)
            DetailRow(label: l10n.documentDetailValidity, value: validity),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.label,
    required this.value,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final row = Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.typography.cardSubtitle.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.typography.cardSubtitle.copyWith(
                color: onTap == null ? palette.textPrimary : palette.action,
                fontWeight: onTap == null ? null : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

class RejectedNote extends StatelessWidget {
  const RejectedNote({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.actionSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: palette.action),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.typography.body)),
        ],
      ),
    );
  }
}
