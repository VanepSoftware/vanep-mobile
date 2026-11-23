import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';

class ComplianceStateView extends StatelessWidget {
  const ComplianceStateView({required this.builder, super.key});

  final Widget Function(BuildContext context, DriverCompliance compliance)
  builder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DriverComplianceCubit>();
    return BlocBuilder<DriverComplianceCubit, DriverComplianceState>(
      builder: (context, state) {
        final compliance = state.compliance;
        if (compliance != null) {
          return RefreshIndicator(
            color: context.palette.action,
            onRefresh: cubit.refresh,
            child: builder(context, compliance),
          );
        }
        if (state.failure != null) {
          return VanepErrorView(
            message: l10n.driverDocumentsLoadError,
            retryLabel: l10n.driverDocumentsRetry,
            onRetry: cubit.load,
          );
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: VanepSkeletonList(
            buildPlaceholder: (_) => const VanepCard(
              child: Row(
                children: [
                  Bone.square(size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone.text(words: 2, fontSize: 16),
                        SizedBox(height: 6),
                        Bone.text(width: 110, fontSize: 13),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
