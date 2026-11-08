import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/formatters/phone_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/formatters/driver_profile_formatters.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_profile_sections.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({this.onQuoteRequested, super.key});

  final ValueChanged<String>? onQuoteRequested;

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
          backgroundColor: context.palette.card,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: onCover ? VanepColors.onBrand : null,
            systemOverlayStyle: onCover ? SystemUiOverlayStyle.light : null,
          ),
          body: switch (state.status) {
            DriverProfileStatus.loading => Center(
              child: CircularProgressIndicator(color: context.palette.action),
            ),
            DriverProfileStatus.error => SafeArea(
              child: VanepErrorView(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!profile.available) ...[
                        Text(
                          l10n.quoteRequestDriverUnavailable,
                          textAlign: TextAlign.center,
                          style: context.typography.cardSubtitle,
                        ),
                        const SizedBox(height: 8),
                      ],
                      VanepPrimaryButton(
                        label: l10n.driverRequestQuoteButton,
                        onPressed:
                            onQuoteRequested == null || !profile.available
                            ? null
                            : () => onQuoteRequested!(profile.token),
                      ),
                    ],
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
        Divider(height: 1, color: context.palette.divider),
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
                  style: context.typography.sectionTitle,
                ),
                const SizedBox(height: 6),
                Text(bio, style: context.typography.body),
              ],
              const SizedBox(height: 20),
              if (profile.vehicles.isEmpty)
                Text(
                  l10n.driverProfileNoVan,
                  style: context.typography.cardSubtitle,
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
