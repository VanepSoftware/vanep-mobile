import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_submission_labels.dart';

Future<bool> showDocumentSourceSheet(
  BuildContext context,
  DocumentSubmissionCubit cubit,
) async {
  final picked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider<DocumentSubmissionCubit>.value(
      value: cubit,
      child: const DocumentSourceSheet(),
    ),
  );
  return picked ?? false;
}

class DocumentSourceSheet extends StatelessWidget {
  const DocumentSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DocumentSubmissionCubit>();
    final initialFile = cubit.state.file;
    return BlocConsumer<DocumentSubmissionCubit, DocumentSubmissionState>(
      listenWhen: (previous, current) =>
          current.file != null &&
          current.file != previous.file &&
          current.file != initialFile,
      listener: (context, state) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final failure = state.captureFailure;
        void pick(DocumentSource source) {
          if (!state.isCapturing) cubit.capture(source);
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  documentTypeLabel(l10n, state.type),
                  style: context.typography.pageTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.documentSourceTitle,
                  style: context.typography.cardSubtitle.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                DocumentSourceOption(
                  icon: Icons.document_scanner_outlined,
                  title: l10n.documentSourceScanner,
                  hint: l10n.documentSourceScannerHint,
                  badge: l10n.documentSourceRecommended,
                  onTap: () => pick(DocumentSource.scanner),
                ),
                const SizedBox(height: 10),
                DocumentSourceOption(
                  icon: Icons.photo_library_outlined,
                  title: l10n.documentSourceGallery,
                  hint: l10n.documentSourceGalleryHint,
                  onTap: () => pick(DocumentSource.gallery),
                ),
                const SizedBox(height: 10),
                DocumentSourceOption(
                  icon: Icons.picture_as_pdf_outlined,
                  title: l10n.documentSourcePdf,
                  hint: l10n.documentSourcePdfHint,
                  onTap: () => pick(DocumentSource.pdfFile),
                ),
                const SizedBox(height: 16),
                if (failure != null) ...[
                  Text(
                    captureFailureMessage(l10n, failure),
                    style: context.typography.cardSubtitle.copyWith(
                      color: context.palette.dangerText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.palette.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        size: 20,
                        color: context.palette.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.documentSourceTip,
                          style: context.typography.cardSubtitle.copyWith(
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DocumentSourceOption extends StatelessWidget {
  const DocumentSourceOption({
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
    this.badge,
    super.key,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final recommended = badge != null;
    return VanepCard(
      onTap: onTap,
      highlighted: recommended,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: recommended ? palette.actionSurface : palette.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: recommended ? palette.action : palette.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title, style: context.typography.cardTitle),
                    if (badge != null)
                      VanepChip(
                        label: badge!,
                        background: palette.actionSurface,
                        foreground: palette.action,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  hint,
                  style: context.typography.cardSubtitle.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
