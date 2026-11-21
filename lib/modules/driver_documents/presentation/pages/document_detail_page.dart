import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/document_submission.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_action.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/resolve_document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_file_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_detail_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/compliance_state_view.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_detail_sections.dart';

class DocumentDetailPage extends StatelessWidget {
  const DocumentDetailPage({
    required this.type,
    required this.onAction,
    this.vehicleToken,
    this.onOpenImage,
    super.key,
  });

  final DocumentType type;
  final String? vehicleToken;
  final void Function(DocumentAction action, RequirementStatus requirement)
  onAction;
  final ValueChanged<String>? onOpenImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fileCubit = context.read<DocumentFileCubit>();
    return BlocListener<DocumentFileCubit, DocumentFileState>(
      listenWhen: (previous, current) =>
          current.imageUrl != previous.imageUrl ||
          current.failed != previous.failed,
      listener: (context, state) {
        final imageUrl = state.imageUrl;
        if (imageUrl != null) onOpenImage?.call(imageUrl);
        if (state.failed) {
          VanepFeedback.showError(context, l10n.documentFileOpenError);
        }
        if (imageUrl != null || state.failed) fileCubit.clear();
      },
      child: BlocBuilder<DriverComplianceCubit, DriverComplianceState>(
        builder: (context, state) {
          final compliance = state.compliance;
          final requirement = compliance == null
              ? null
              : findRequirement(compliance, type, vehicleToken: vehicleToken);
          final displayState = requirement == null || compliance == null
              ? null
              : resolveDocumentDisplayState(requirement, compliance.asOf);
          final action = displayState == null
              ? null
              : documentActionFor(displayState);
          return Scaffold(
            backgroundColor: context.palette.surface,
            appBar: VanepAppBar(
              title: documentTypeLabel(l10n, type),
              caption: captionOf(l10n, compliance),
            ),
            body: ComplianceStateView(
              builder: (context, compliance) => requirement == null
                  ? DocumentNotFound(message: l10n.documentDetailNotFound)
                  : DocumentDetailContent(
                      requirement: requirement,
                      state: displayState!,
                      vehicle: vehicleToken == null
                          ? null
                          : findVehicle(compliance, vehicleToken!),
                      onOpenFile: (submission) {
                        final file = submission.file;
                        final url = submission.fileUrl;
                        if (file != null && url != null) {
                          fileCubit.open(url, file);
                        }
                      },
                    ),
            ),
            bottomNavigationBar: action == null || requirement == null
                ? null
                : DocumentActionBar(
                    action: action,
                    onPressed: () => onAction(action, requirement),
                  ),
          );
        },
      ),
    );
  }

  String? captionOf(AppLocalizations l10n, DriverCompliance? compliance) {
    final token = vehicleToken;
    if (token == null) return l10n.documentDetailPersonalCaption;
    final vehicle = compliance == null ? null : findVehicle(compliance, token);
    return vehicle == null
        ? null
        : l10n.vanStudentsCaption(vehicle.model, vehicle.plate);
  }
}

class DocumentDetailContent extends StatelessWidget {
  const DocumentDetailContent({
    required this.requirement,
    required this.state,
    required this.vehicle,
    required this.onOpenFile,
    super.key,
  });

  final RequirementStatus requirement;
  final DocumentDisplayState state;
  final VehicleCompliance? vehicle;
  final ValueChanged<DocumentSubmission> onOpenFile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = requirement.current;
    final pending = requirement.pending;
    final isRenewal = state is DocumentRenewalUnderReview;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        DocumentDetailStatusCard(requirement: requirement, state: state),
        if (current != null) ...[
          const SizedBox(height: 22),
          Text(
            l10n.documentDetailSentSection,
            style: context.typography.sectionTitle,
          ),
          const SizedBox(height: 10),
          SentSubmissionCard(
            submission: current,
            vehicle: vehicle,
            onOpenFile: onOpenFile,
            title: isRenewal ? l10n.documentDetailCurrentVersion : null,
          ),
          if (pending != null) ...[
            const SizedBox(height: 10),
            SentSubmissionCard(
              submission: pending,
              vehicle: vehicle,
              onOpenFile: onOpenFile,
              title: l10n.documentDetailNewVersion,
            ),
          ],
        ],
        const SizedBox(height: 22),
        Text(
          l10n.documentDetailAboutSection,
          style: context.typography.sectionTitle,
        ),
        const SizedBox(height: 10),
        AboutDocumentCard(type: requirement.type),
        if (state is DocumentRejected) ...[
          const SizedBox(height: 18),
          RejectedNote(text: l10n.documentDetailRejectedNote),
        ],
      ],
    );
  }
}

class DocumentActionBar extends StatelessWidget {
  const DocumentActionBar({
    required this.action,
    required this.onPressed,
    super.key,
  });

  final DocumentAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = documentActionLabel(AppLocalizations.of(context)!, action);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: action == DocumentAction.sendUpdated
            ? VanepSecondaryButton(
                label: label,
                icon: Icons.upload,
                onPressed: onPressed,
              )
            : VanepPrimaryButton(label: label, onPressed: onPressed),
      ),
    );
  }
}

class DocumentNotFound extends StatelessWidget {
  const DocumentNotFound({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.typography.body,
        ),
      ],
    );
  }
}
