import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/photo_failure_label.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_state.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/formatters/driver_van_labels.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/widgets/driver_van_photos_editor.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/widgets/van_registration_form.dart';

class DriverVansSection extends StatelessWidget {
  const DriverVansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DriverVansCubit, DriverVansState>(
      listenWhen: (previous, current) =>
          current.notice != null && previous.notice != current.notice,
      listener: (context, state) =>
          presentDriverVansNotice(context, l10n, state),
      builder: (context, state) {
        return VanepCard(
          padding: const EdgeInsets.all(20),
          child: DriverVansSectionContent(state: state),
        );
      },
    );
  }
}

class DriverVansSectionContent extends StatelessWidget {
  const DriverVansSectionContent({required this.state, super.key});

  final DriverVansState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (state.status) {
      DriverVansStatus.loading => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: VanepColors.action),
        ),
      ),
      DriverVansStatus.loadFailed => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.driverVansLoadError, style: VanepTypography.cardSubtitle),
          TextButton(
            onPressed: context.read<DriverVansCubit>().loadVans,
            child: Text(l10n.driversRetryButton),
          ),
        ],
      ),
      DriverVansStatus.loaded when state.vans.isEmpty =>
        const VanRegistrationForm(),
      DriverVansStatus.loaded => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final van in state.vans) ...[
            if (van != state.vans.first) const SizedBox(height: 20),
            DriverVanPhotosEditor(van: van),
          ],
        ],
      ),
    };
  }
}

void presentDriverVansNotice(
  BuildContext context,
  AppLocalizations l10n,
  DriverVansState state,
) {
  switch (state.notice) {
    case VanRegisteredNotice():
      VanepFeedback.showInfo(context, l10n.driverVanRegistered);
    case VanRegistrationFailedNotice(:final failure):
      VanepFeedback.showError(context, driverVanFailureLabel(l10n, failure));
    case VanPhotoFailedNotice(:final failure):
      VanepFeedback.showError(context, photoFailureLabel(l10n, failure));
    case null:
      return;
  }
  context.read<DriverVansCubit>().clearNotice();
}
