import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_submission_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_image_page.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_file_preview.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_source_sheet.dart';

typedef OpenLocalFile = Future<bool> Function(String path);

const double minPreviewHeight = 240;
const double belowPreviewReserve = 230;

double previewHeightFor(double available) {
  final height = available - belowPreviewReserve;
  return height < minPreviewHeight ? minPreviewHeight : height;
}

class DocumentConfirmPage extends StatelessWidget {
  const DocumentConfirmPage({
    required this.onOpenPdf,
    this.vehicleCaption,
    super.key,
  });

  final OpenLocalFile onOpenPdf;
  final String? vehicleCaption;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DocumentSubmissionCubit>();
    final state = context.watch<DocumentSubmissionCubit>().state;
    final file = state.file;
    final failure = state.failure;
    final failureMessage = failure == null
        ? null
        : submissionFailureMessage(l10n, failure);
    final title = documentTypeLabel(l10n, state.type);
    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(title: title, caption: vehicleCaption),
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          children: [
            if (file != null) ...[
              SizedBox(
                height: previewHeightFor(constraints.maxHeight),
                child: DocumentFilePreview(
                  key: ValueKey(file.path),
                  file: file,
                  onOpenPage: (page) =>
                      openPages(context, title, file.pagePreviewPaths, page),
                  onOpenPdf: () => openPdf(context, file),
                ),
              ),
              const SizedBox(height: 4),
              FileSummaryRow(
                file: file,
                onChange: () => showDocumentSourceSheet(context, cubit),
              ),
            ],
            const SizedBox(height: 12),
            const ConfirmChecklist(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failureMessage != null) ...[
                Text(
                  failureMessage,
                  style: context.typography.cardSubtitle.copyWith(
                    color: context.palette.dangerText,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              VanepPrimaryButton(
                label: l10n.documentConfirmSubmit,
                onPressed: file == null ? null : cubit.submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openPages(
    BuildContext context,
    String title,
    List<String> pages,
    int initialPage,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DocumentImagePage(
          title: title,
          images: [for (final page in pages) FileImage(File(page))],
          initialPage: initialPage,
        ),
      ),
    );
  }

  Future<void> openPdf(BuildContext context, PickedDocument file) async {
    final l10n = AppLocalizations.of(context)!;
    final opened = await onOpenPdf(file.path);
    if (!opened && context.mounted) {
      VanepFeedback.showError(context, l10n.documentFileOpenError);
    }
  }
}

class FileSummaryRow extends StatelessWidget {
  const FileSummaryRow({required this.file, required this.onChange, super.key});

  final PickedDocument file;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = file.pageCount;
    final format = documentFileFormatLabel(l10n, file.mimeType);
    final size = formatMegabytes(l10n, file.sizeBytes);
    return Row(
      children: [
        Expanded(
          child: Text(
            pages == null
                ? l10n.documentFileSummary(format, size)
                : l10n.documentFileSummaryWithPages(format, pages, size),
            style: context.typography.cardSubtitle.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onChange,
          icon: const Icon(Icons.sync, size: 18),
          label: Text(l10n.documentConfirmChangeFile),
        ),
      ],
    );
  }
}

class ConfirmChecklist extends StatelessWidget {
  const ConfirmChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.documentConfirmChecklistTitle,
          style: context.typography.sectionTitle,
        ),
        const SizedBox(height: 8),
        for (final item in [
          l10n.documentConfirmCheckReadable,
          l10n.documentConfirmCheckWhole,
          l10n.documentConfirmCheckBothSides,
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check, size: 18, color: palette.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: context.typography.cardSubtitle.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String documentFileFormatLabel(AppLocalizations l10n, String mimeType) {
  return switch (mimeType) {
    'application/pdf' => l10n.documentFormatPdf,
    'image/png' => l10n.documentFormatPng,
    'image/webp' => l10n.documentFormatWebp,
    _ => l10n.documentFormatJpg,
  };
}
