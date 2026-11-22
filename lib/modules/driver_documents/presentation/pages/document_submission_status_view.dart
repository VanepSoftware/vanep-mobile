import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_groups.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_submission_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_source_sheet.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_status_card.dart';

typedef OpenPendingDocument = void Function(
  DocumentEntry entry,
  String? vehicleToken,
);

class DocumentSubmissionStatusView extends StatelessWidget {
  const DocumentSubmissionStatusView({
    required this.state,
    required this.vehicleCaption,
    required this.onBackToDocuments,
    required this.onOpenPending,
    super.key,
  });

  final DocumentSubmissionState state;
  final String? vehicleCaption;
  final VoidCallback onBackToDocuments;
  final OpenPendingDocument onOpenPending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: switch (state.step) {
          SubmissionStep.sent => DocumentSentView(
            onBackToDocuments: onBackToDocuments,
            onOpenPending: onOpenPending,
          ),
          SubmissionStep.failed => DocumentSendFailedView(
            failure: state.failure,
          ),
          _ => DocumentSendingView(
            state: state,
            vehicleCaption: vehicleCaption,
          ),
        },
      ),
    );
  }
}

class DocumentSendingView extends StatelessWidget {
  const DocumentSendingView({
    required this.state,
    required this.vehicleCaption,
    super.key,
  });

  final DocumentSubmissionState state;
  final String? vehicleCaption;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final percent = progressPercent(state.sentBytes, state.totalBytes);
    final documentName = documentTypeLabel(l10n, state.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(
            icon: Icons.cloud_upload_outlined,
            background: palette.actionSurface,
            foreground: palette.action,
          ),
          const SizedBox(height: 24),
          Text(l10n.documentSendingTitle, style: context.typography.pageTitle),
          const SizedBox(height: 6),
          Text(
            vehicleCaption == null
                ? documentName
                : l10n.documentSendingCaption(documentName, vehicleCaption!),
            style: context.typography.body.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: state.totalBytes == 0 ? null : percent / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: palette.action,
            backgroundColor: palette.divider,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.documentSendingProgress(
                    formatMegabytes(l10n, state.sentBytes),
                    formatMegabytes(l10n, state.totalBytes),
                  ),
                  style: context.typography.cardSubtitle.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
              Text(
                l10n.documentSendingPercent(percent),
                style: context.typography.cardSubtitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.documentSendingKeepOpen,
            style: context.typography.cardSubtitle.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentSentView extends StatelessWidget {
  const DocumentSentView({
    required this.onBackToDocuments,
    required this.onOpenPending,
    super.key,
  });

  final VoidCallback onBackToDocuments;
  final OpenPendingDocument onOpenPending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final compliance = context.watch<DriverComplianceCubit>().state.compliance;
    final stillMissing = compliance == null
        ? const <StillMissingEntry>[]
        : stillMissingEntries(l10n, compliance);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            children: [
              Center(
                child: StatusBadge(
                  icon: Icons.check,
                  background: palette.successSurface,
                  foreground: palette.success,
                  size: 112,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.documentSentTitle,
                textAlign: TextAlign.center,
                style: context.typography.pageTitle,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.documentSentMessage,
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              if (stillMissing.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  l10n.documentSentStillMissing,
                  style: context.typography.overline,
                ),
                const SizedBox(height: 10),
                for (final missing in stillMissing) ...[
                  DocumentStatusCard(
                    entry: missing.entry,
                    caption: missing.vehicleCaption,
                    onTap: () =>
                        onOpenPending(missing.entry, missing.vehicleToken),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: VanepSecondaryButton(
            label: l10n.documentSentBack,
            onPressed: onBackToDocuments,
          ),
        ),
      ],
    );
  }
}

class StillMissingEntry {
  const StillMissingEntry({
    required this.entry,
    this.vehicleToken,
    this.vehicleCaption,
  });

  final DocumentEntry entry;
  final String? vehicleToken;
  final String? vehicleCaption;
}

List<StillMissingEntry> stillMissingEntries(
  AppLocalizations l10n,
  DriverCompliance compliance,
) {
  return [
    for (final entry in groupDocuments(
      compliance.driverRequirements,
      compliance.asOf,
    ).pending)
      StillMissingEntry(entry: entry),
    for (final van in groupVehicleDocuments(
      compliance.vehicles,
      compliance.asOf,
    ))
      for (final entry in van.groups.pending)
        StillMissingEntry(
          entry: entry,
          vehicleToken: van.vehicle.token,
          vehicleCaption: l10n.vanStudentsCaption(
            van.vehicle.model,
            van.vehicle.plate,
          ),
        ),
  ];
}

class DocumentSendFailedView extends StatelessWidget {
  const DocumentSendFailedView({required this.failure, super.key});

  final DocumentSubmissionFailure? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final cubit = context.read<DocumentSubmissionCubit>();
    final known = failure;
    final message =
        (known == null ? null : submissionFailureMessage(l10n, known)) ??
        l10n.documentSendFailedMessage;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(
                  icon: Icons.cloud_off_outlined,
                  background: palette.dangerSurface,
                  foreground: palette.danger,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.documentSendFailedTitle,
                  style: context.typography.pageTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: context.typography.body.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VanepPrimaryButton(
                label: l10n.documentSendRetry,
                onPressed: cubit.submit,
              ),
              const SizedBox(height: 10),
              VanepSecondaryButton(
                label: l10n.documentSendChangeFile,
                onPressed: () => showDocumentSourceSheet(context, cubit),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 72,
    super.key,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.5, color: foreground),
    );
  }
}
