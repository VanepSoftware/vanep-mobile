import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_menu_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/summarize_documents.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_professional_data/presentation/cubit/professional_data_cubit.dart';
import 'package:vanep_mobile/modules/driver_professional_data/presentation/formatters/professional_data_labels.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/driver_approval_status.dart';

class ProfessionalDataActions {
  const ProfessionalDataActions({
    required this.onOpenServiceAreas,
    required this.onOpenPersonalDocuments,
    required this.onOpenVanDocuments,
    required this.onOpenComingSoon,
  });

  final VoidCallback onOpenServiceAreas;
  final VoidCallback onOpenPersonalDocuments;
  final VoidCallback onOpenVanDocuments;
  final ValueChanged<String> onOpenComingSoon;
}

class ProfessionalDataPage extends StatelessWidget {
  const ProfessionalDataPage({required this.actions, super.key});

  final ProfessionalDataActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProfessionalDataCubit>();
    return BlocConsumer<ProfessionalDataCubit, ProfessionalDataState>(
      listenWhen: (previous, current) =>
          current.attendanceChangeFailed && !previous.attendanceChangeFailed,
      listener: (context, state) {
        VanepFeedback.showError(context, l10n.vanCentralAttendanceError);
        cubit.clearAttendanceFailure();
      },
      builder: (context, state) {
        final summary = state.summary;
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: VanepAppBar(title: l10n.profileProfessionalData),
          body: switch (state.status) {
            ProfessionalDataStatus.failed => VanepErrorView(
              message: l10n.professionalDataLoadError,
              retryLabel: l10n.professionalDataRetry,
              onRetry: cubit.load,
            ),
            ProfessionalDataStatus.ready when summary != null =>
              ProfessionalDataContent(
                summary: summary,
                state: state,
                actions: actions,
              ),
            _ => const ProfessionalDataSkeleton(),
          },
        );
      },
    );
  }
}

class ProfessionalDataContent extends StatelessWidget {
  const ProfessionalDataContent({
    required this.summary,
    required this.state,
    required this.actions,
    super.key,
  });

  final DriverProfileSummary summary;
  final ProfessionalDataState state;
  final ProfessionalDataActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProfessionalDataCubit>();
    final attendance = state.attendance;
    final compliance = context.watch<DriverComplianceCubit>().state.compliance;
    VanepMenuItem comingSoon(String label, IconData icon, {String? subtitle}) {
      return VanepMenuItem(
        label: label,
        icon: icon,
        subtitle: subtitle,
        onTap: () => actions.onOpenComingSoon(label),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        ProfessionalHeaderCard(
          summary: summary,
          onEdit: () => actions.onOpenComingSoon(l10n.professionalDataEdit),
          onPublicProfile: () =>
              actions.onOpenComingSoon(l10n.professionalDataPublicProfile),
        ),
        const SizedBox(height: 22),
        ProfessionalSection(
          title: l10n.professionalDataAttendanceSection,
          items: [
            VanepMenuItem(
              label: l10n.vanCentralServiceAreas,
              icon: Icons.map_outlined,
              onTap: actions.onOpenServiceAreas,
            ),
            comingSoon(l10n.professionalDataWorkHours, Icons.schedule),
            comingSoon(l10n.professionalDataWaitTime, Icons.timer_outlined),
            comingSoon(l10n.vanCentralBasePrice, Icons.sell_outlined),
            if (attendance != null)
              VanepMenuItem(
                label: l10n.vanCentralAccepting,
                icon: Icons.how_to_reg_outlined,
                onTap: state.isChangingAttendance
                    ? null
                    : () => cubit.setAcceptingStudents(
                        !attendance.acceptingStudents,
                      ),
                trailing: Switch(
                  value: attendance.acceptingStudents,
                  activeTrackColor: context.palette.action,
                  onChanged: state.isChangingAttendance
                      ? null
                      : cubit.setAcceptingStudents,
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        ProfessionalSection(
          title: l10n.professionalDataDocumentsSection,
          items: [
            VanepMenuItem(
              label: l10n.professionalDataPersonalDocuments,
              icon: Icons.badge_outlined,
              warningSubtitle: documentsRowWarning(
                l10n,
                personalSummaryOf(compliance),
              ),
              onTap: actions.onOpenPersonalDocuments,
            ),
            VanepMenuItem(
              label: l10n.professionalDataVanDocuments,
              icon: Icons.airport_shuttle_outlined,
              warningSubtitle: documentsRowWarning(
                l10n,
                vehiclesSummaryOf(compliance),
              ),
              onTap: actions.onOpenVanDocuments,
            ),
          ],
        ),
        const SizedBox(height: 22),
        ProfessionalSection(
          title: l10n.professionalDataCompanySection,
          items: [
            comingSoon(
              l10n.professionalDataCnpj,
              Icons.business_center_outlined,
              subtitle: l10n.documentStateOptional,
            ),
          ],
        ),
      ],
    );
  }
}

DocumentsSummary? personalSummaryOf(DriverCompliance? compliance) {
  if (compliance == null) return null;
  return summarizeDocuments(compliance.driverRequirements, compliance.asOf);
}

DocumentsSummary? vehiclesSummaryOf(DriverCompliance? compliance) {
  if (compliance == null || compliance.vehicles.isEmpty) return null;
  return summarizeDocuments([
    for (final vehicle in compliance.vehicles) ...vehicle.requirements,
  ], compliance.asOf);
}

class ProfessionalHeaderCard extends StatelessWidget {
  const ProfessionalHeaderCard({
    required this.summary,
    required this.onEdit,
    required this.onPublicProfile,
    super.key,
  });

  final DriverProfileSummary summary;
  final VoidCallback onEdit;
  final VoidCallback onPublicProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final name = summary.user?.name ?? '';
    final line = professionalHeaderLine(l10n, summary);
    final verified = summary.approvalStatus == DriverApprovalStatus.approved;
    return VanepCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              VanepAvatar(
                photoUrl: summary.photoUrl,
                size: 56,
                initials: initialsOf(name),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: context.typography.cardTitle,
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: palette.action,
                            semanticLabel: l10n.professionalDataVerified,
                          ),
                        ],
                      ],
                    ),
                    if (line != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        line,
                        style: context.typography.cardSubtitle.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.professionalDataEdit,
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: palette.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onPublicProfile,
            icon: const Icon(Icons.visibility_outlined),
            label: Text(l10n.professionalDataPublicProfile),
          ),
        ],
      ),
    );
  }
}

class ProfessionalSection extends StatelessWidget {
  const ProfessionalSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<VanepMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.typography.sectionTitle),
        const SizedBox(height: 10),
        VanepMenuCard(items: items),
      ],
    );
  }
}

class ProfessionalDataSkeleton extends StatelessWidget {
  const ProfessionalDataSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: VanepSkeletonList(
        count: 4,
        buildPlaceholder: (_) => const VanepCard(
          child: Row(
            children: [
              Bone.circle(size: 40),
              SizedBox(width: 12),
              Expanded(child: Bone.text(words: 3, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
