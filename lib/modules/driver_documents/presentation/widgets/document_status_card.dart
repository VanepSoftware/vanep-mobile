import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_groups.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';

class DocumentStatusCard extends StatelessWidget {
  const DocumentStatusCard({
    required this.entry,
    required this.onTap,
    super.key,
  });

  final DocumentEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final style = documentStatusStyleOf(l10n, palette, entry.state);
    final detail = style.detail;

    return VanepCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              documentTypeIcon(entry.requirement.type),
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentTypeLabel(l10n, entry.requirement.type),
                  style: context.typography.cardTitle,
                ),
                const SizedBox(height: 3),
                DocumentStatusLine(style: style),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: context.typography.cardSubtitle.copyWith(
                      color: style.detailColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: palette.textMuted),
        ],
      ),
    );
  }
}

class DocumentStatusLine extends StatelessWidget {
  const DocumentStatusLine({required this.style, super.key});

  final DocumentStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(style.icon, size: 16, color: style.color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            style.label,
            style: context.typography.cardSubtitle.copyWith(
              color: style.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class DocumentEntriesSection extends StatelessWidget {
  const DocumentEntriesSection({
    required this.title,
    required this.trailing,
    required this.entries,
    required this.onOpen,
    super.key,
  });

  final String title;
  final String trailing;
  final List<DocumentEntry> entries;
  final ValueChanged<DocumentEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: context.typography.sectionTitle),
            ),
            Text(
              trailing,
              style: context.typography.cardSubtitle.copyWith(
                color: context.palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final entry in entries) ...[
          DocumentStatusCard(entry: entry, onTap: () => onOpen(entry)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class DocumentsPrivacyNote extends StatelessWidget {
  const DocumentsPrivacyNote({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.typography.cardSubtitle.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
