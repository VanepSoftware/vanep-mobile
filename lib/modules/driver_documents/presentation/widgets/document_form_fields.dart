import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/birth_date_input_formatter.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_field_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_submission_labels.dart';

class DocumentFileSummaryCard extends StatelessWidget {
  const DocumentFileSummaryCard({
    required this.file,
    required this.onChange,
    super.key,
  });

  final PickedDocument file;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final pages = file.pageCount;
    final size = formatMegabytes(l10n, file.sizeBytes);
    final format = documentFileFormatLabel(l10n, file.mimeType);
    final preview = file.pagePreviewPaths.isEmpty
        ? null
        : file.pagePreviewPaths.first;
    return VanepCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 68,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: palette.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: preview == null
                ? Icon(
                    Icons.picture_as_pdf_outlined,
                    color: palette.textSecondary,
                  )
                : Image.file(
                    File(preview),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Icon(
                      Icons.description_outlined,
                      color: palette.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pages == null ? file.fileName : l10n.documentDataScannedFile,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.cardTitle,
                ),
                const SizedBox(height: 3),
                Text(
                  pages == null
                      ? l10n.documentFileSummary(format, size)
                      : l10n.documentFileSummaryWithPages(format, pages, size),
                  style: context.typography.cardSubtitle.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text(l10n.documentDataChangeFile),
          ),
        ],
      ),
    );
  }
}

class DocumentDateField extends StatelessWidget {
  const DocumentDateField({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.errorText,
    this.helperText,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? errorText;
  final String? helperText;

  Future<void> pickDate(BuildContext context) async {
    final current = parseDocumentDateInput(controller.text);
    final initial = current == null
        ? firstDate
        : current.isBefore(firstDate)
        ? firstDate
        : current.isAfter(lastDate)
        ? lastDate
        : current;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    controller.text = formatDocumentDateInput(picked);
    onChanged(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final helper = helperText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepTextField(
          label: label,
          controller: controller,
          onChanged: onChanged,
          errorText: errorText,
          hintText: l10n.documentDateHint,
          keyboardType: TextInputType.number,
          inputFormatters: const [BirthDateInputFormatter()],
          suffix: IconButton(
            tooltip: label,
            icon: Icon(
              Icons.calendar_month_outlined,
              color: context.palette.textSecondary,
            ),
            onPressed: () => pickDate(context),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper,
            style: context.typography.cardSubtitle.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

final List<TextInputFormatter> cnhRegistrationFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(11),
];
