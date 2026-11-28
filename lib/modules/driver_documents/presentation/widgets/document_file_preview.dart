import 'dart:io';

import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class DocumentFilePreview extends StatefulWidget {
  const DocumentFilePreview({
    required this.file,
    required this.onOpenPage,
    required this.onOpenPdf,
    super.key,
  });

  final PickedDocument file;
  final ValueChanged<int> onOpenPage;
  final VoidCallback onOpenPdf;

  @override
  State<DocumentFilePreview> createState() => DocumentFilePreviewState();
}

class DocumentFilePreviewState extends State<DocumentFilePreview> {
  final controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final pages = widget.file.pagePreviewPaths;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: palette.divider,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: pages.isEmpty
                ? PdfWithoutPreview(onOpen: widget.onOpenPdf)
                : PageView.builder(
                    controller: controller,
                    itemCount: pages.length,
                    onPageChanged: (page) => setState(() => currentPage = page),
                    itemBuilder: (context, index) => Semantics(
                      button: true,
                      label: l10n.documentScanPageLabel(index + 1),
                      hint: l10n.documentConfirmViewPage,
                      child: GestureDetector(
                        onTap: () => widget.onOpenPage(index),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.file(
                            File(pages[index]),
                            fit: BoxFit.contain,
                            errorBuilder: missingPreview,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        if (pages.length > 1) ...[
          const SizedBox(height: 8),
          Text(
            l10n.documentScanPagePosition(currentPage + 1, pages.length),
            textAlign: TextAlign.center,
            style: context.typography.cardSubtitle.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class PdfWithoutPreview extends StatelessWidget {
  const PdfWithoutPreview({required this.onOpen, super.key});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 64,
            color: context.palette.textSecondary,
          ),
          const SizedBox(height: 16),
          VanepSecondaryButton(
            label: l10n.documentConfirmOpenPdf,
            icon: Icons.open_in_new,
            onPressed: onOpen,
          ),
        ],
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
