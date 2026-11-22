import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/formatters/document_submission_labels.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_confirm_page.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_submission_status_view.dart';

class DocumentSubmissionFlowPage extends StatelessWidget {
  const DocumentSubmissionFlowPage({
    required this.onBackToDocuments,
    required this.onOpenPending,
    required this.onOpenPdf,
    this.vehicleCaption,
    super.key,
  });

  final VoidCallback onBackToDocuments;
  final OpenPendingDocument onOpenPending;
  final OpenLocalFile onOpenPdf;
  final String? vehicleCaption;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DocumentSubmissionCubit>();
    return BlocConsumer<DocumentSubmissionCubit, DocumentSubmissionState>(
      listenWhen: (previous, current) =>
          current.leaveFlow != previous.leaveFlow ||
          (current.step == SubmissionStep.sent &&
              previous.step != SubmissionStep.sent),
      listener: (context, state) {
        final compliance = context.read<DriverComplianceCubit>();
        if (state.step == SubmissionStep.sent) {
          compliance.refresh();
          return;
        }
        if (!state.leaveFlow) return;
        final failure = state.failure;
        final message = failure == null
            ? null
            : submissionFailureMessage(l10n, failure);
        if (message != null) VanepFeedback.showInfo(context, message);
        compliance.refresh();
        cubit.clearMessages();
        Navigator.of(context).pop();
      },
      builder: (context, state) {
        return switch (state.step) {
          SubmissionStep.sending ||
          SubmissionStep.sent ||
          SubmissionStep.failed => DocumentSubmissionStatusView(
            state: state,
            vehicleCaption: vehicleCaption,
            onBackToDocuments: onBackToDocuments,
            onOpenPending: onOpenPending,
          ),
          _ => DocumentConfirmPage(
            vehicleCaption: vehicleCaption,
            onOpenPdf: onOpenPdf,
          ),
        };
      },
    );
  }
}
