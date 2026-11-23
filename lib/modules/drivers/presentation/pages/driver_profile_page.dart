import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/formatters/driver_profile_formatters.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_profile_sections.dart';

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

        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: profile != null
              ? null
              : VanepAppBar(title: l10n.findVanProfileButton),
          bottomNavigationBar: profile == null
              ? null
              : _DriverProfileBottomBar(
                  available: profile.available,
                  onPressed: profile.available && onQuoteRequested != null
                      ? () => onQuoteRequested!(profile.token)
                      : null,
                ),
          body: switch ((profile, failure)) {
            (final profile?, _) => _DriverProfileBody(profile: profile),
            (null, final failure?) => VanepErrorView(
              message: driverProfileFailureLabel(l10n, failure),
              retryLabel: l10n.driversRetryButton,
              onRetry: context.read<DriverProfileCubit>().loadProfile,
            ),
            (null, null) => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _DriverProfileBody extends StatelessWidget {
  const _DriverProfileBody({required this.profile});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bio = profile.bio?.trim();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            DriverProfileCoverCarousel(profile: profile),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DriverProfileIdentityBlock(profile: profile),
                  if (bio != null && bio.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    VanepSection(
                      title: l10n.driverProfileBioSectionTitle,
                      child: VanepCard(
                        child: Text(
                          bio,
                          style: context.typography.body.copyWith(height: 1.45),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  DriverProfileVacanciesCard(profile: profile),
                  const SizedBox(height: 18),
                  DriverProfileVansSection(profile: profile),
                  const SizedBox(height: 18),
                  DriverProfileServiceSection(profile: profile),
                  if (profile.verified) ...[
                    const SizedBox(height: 18),
                    DriverProfileVerifiedCard(profile: profile),
                  ],
                  const SizedBox(height: 18),
                  DriverProfileRatingsSection(profile: profile),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 8,
          left: 12,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: BackButton(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _DriverProfileBottomBar extends StatelessWidget {
  const _DriverProfileBottomBar({
    required this.available,
    required this.onPressed,
  });

  final bool available;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: context.palette.card,
        border: Border(top: BorderSide(color: context.palette.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!available) ...[
              Text(
                l10n.quoteRequestDriverUnavailable,
                textAlign: TextAlign.center,
                style: context.typography.cardSubtitle,
              ),
              const SizedBox(height: 8),
            ],
            VanepPrimaryButton(
              label: l10n.driverProfileRequestQuoteButton,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
