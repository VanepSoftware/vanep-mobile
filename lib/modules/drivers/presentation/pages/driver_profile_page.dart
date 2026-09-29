import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/formatters/phone_formatter.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/driver_profile.dart';
import '../cubit/driver_profile_cubit.dart';
import '../cubit/driver_profile_state.dart';
import '../formatters/driver_profile_formatters.dart';
import '../widgets/driver_profile_sections.dart';
import '../widgets/drivers_home_body.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DriverProfileCubit, DriverProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final failure = state.failure;
        final onCover =
            profile != null && driverProfileCoverPhotoUrl(profile) != null;

        return Scaffold(
          backgroundColor: VanepColors.card,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: onCover ? VanepColors.card : null,
            systemOverlayStyle: onCover ? SystemUiOverlayStyle.light : null,
          ),
          body: switch (state.status) {
            DriverProfileStatus.loading => const Center(
              child: CircularProgressIndicator(color: VanepColors.action),
            ),
            DriverProfileStatus.error => SafeArea(
              child: DriversErrorView(
                message: failure == null
                    ? l10n.driverProfileLoadError
                    : driverProfileFailureLabel(l10n, failure),
                retryLabel: l10n.driversRetryButton,
                onRetry: context.read<DriverProfileCubit>().loadProfile,
              ),
            ),
            DriverProfileStatus.loaded when profile != null =>
              DriverProfileBody(profile: profile),
            DriverProfileStatus.loaded => const SizedBox.shrink(),
          },
          bottomNavigationBar: profile == null
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: VanepPrimaryButton(
                    label: l10n.driverProfileChatButton,
                    onPressed: () {},
                  ),
                ),
        );
      },
    );
  }
}

class DriverProfileBody extends StatelessWidget {
  const DriverProfileBody({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serviceAreas = formatServiceAreaList(profile.serviceAreas);
    final phone = profile.phone;
    final bio = profile.bio;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DriverProfileHeader(profile: profile),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: DriverProfileHighlights(profile: profile),
        ),
        const Divider(height: 1, color: VanepColors.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (serviceAreas.isNotEmpty)
                DriverProfileInfoRow(
                  icon: Icons.place_outlined,
                  text: serviceAreas,
                ),
              if (phone != null && phone.trim().isNotEmpty)
                DriverProfileInfoRow(
                  icon: Icons.phone_outlined,
                  text: formatProfilePhone(phone, phone),
                ),
              if (bio != null && bio.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.driverProfileAbout,
                  style: VanepTypography.sectionTitle,
                ),
                const SizedBox(height: 6),
                Text(bio, style: VanepTypography.body),
              ],
              const SizedBox(height: 20),
              if (profile.vehicles.isEmpty)
                Text(
                  l10n.driverProfileNoVan,
                  style: VanepTypography.cardSubtitle,
                )
              else
                for (final vehicle in profile.vehicles)
                  DriverProfileVehicleSection(vehicle: vehicle),
            ],
          ),
        ),
      ],
    );
  }
}
