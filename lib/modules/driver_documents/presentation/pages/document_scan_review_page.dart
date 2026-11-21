import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_submission_labels.dart';

class DocumentScanReviewView extends StatefulWidget {
  const DocumentScanReviewView({required this.file, super.key});

  final PickedDocument file;

  @override
  State<DocumentScanReviewView> createState() => DocumentScanReviewViewState();
}

class DocumentScanReviewViewState extends State<DocumentScanReviewView> {
  int selectedPage = 0;

  @override
  void didUpdateWidget(DocumentScanReviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file != widget.file) selectedPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DocumentSubmissionCubit>();
    final pages = widget.file.pagePreviewPaths;
    final state = context.watch<DocumentSubmissionCubit>().state;
    final failure = state.captureFailure;
    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(
        title: l10n.documentScanReviewTitle,
        caption: l10n.documentScanReviewCaption(
          documentTypeLabel(l10n, state.type),
          widget.file.pageCount ?? pages.length,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.palette.divider,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(16),
                child: pages.isEmpty
                    ? const SizedBox.shrink()
                    : Image.file(
                        File(pages[selectedPage]),
                        fit: BoxFit.contain,
                        semanticLabel: l10n.documentScanPageLabel(
                          selectedPage + 1,
                        ),
                        errorBuilder: missingPreview,
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var index = 0; index < pages.length; index++)
                          ScanPageThumbnail(
                            path: pages[index],
                            selected: index == selectedPage,
                            label: l10n.documentScanPageLabel(index + 1),
                            onTap: () => setState(() => selectedPage = index),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.documentScanPagePosition(selectedPage + 1, pages.length),
                  style: context.typography.cardSubtitle.copyWith(
                    color: context.palette.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (failure != null) ...[
              const SizedBox(height: 10),
              Text(
                captureFailureMessage(l10n, failure),
                style: context.typography.cardSubtitle.copyWith(
                  color: context.palette.dangerText,
                ),
              ),
            ],
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
              VanepSecondaryButton(
                label: l10n.documentScanAgain,
                icon: Icons.document_scanner_outlined,
                isLoading: state.isCapturing,
                onPressed: () => cubit.capture(DocumentSource.scanner),
              ),
              const SizedBox(height: 10),
              VanepPrimaryButton(
                label: l10n.documentScanContinue,
                onPressed: cubit.continueToData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanPageThumbnail extends StatelessWidget {
  const ScanPageThumbnail({
    required this.path,
    required this.selected,
    required this.label,
    required this.onTap,
    super.key,
  });

  final String path;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 64,
            height: 84,
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? palette.action : palette.cardBorder,
                width: selected ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: missingPreview,
            ),
          ),
        ),
      ),
    );
  }
}

Widget missingPreview(BuildContext context, Object error, StackTrace? stack) {
  return Center(
    child: Icon(
      Icons.description_outlined,
      color: context.palette.textSecondary,
    ),
  );
}
