import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/van_day_cards.dart';

class LiveVanCard extends StatelessWidget {
  const LiveVanCard({
    required this.van,
    required this.live,
    required this.now,
    super.key,
  });

  final VanDay van;
  final LiveTrip live;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final present = van.presentRiders.map((rider) => rider.name).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: brandCardGradient,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius + 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LiveVanHeader(van: van, live: live, now: now),
            if (live.approaching) ...[
              const SizedBox(height: 12),
              const IllustrativeMap(),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.clientHomeEtaMinutes(live.etaMinutes),
              style: VanepTypography.wordmark.copyWith(
                fontSize: 40,
                color: VanepColors.onBrand,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.clientHomeEtaToYourStop(formatTimeOfDay(l10n, live.etaAt)),
              style: VanepTypography.body.copyWith(color: onBrandMuted),
            ),
            const SizedBox(height: 12),
            if (live.approaching)
              LiveRidersSummary(van: van, presentNames: present)
            else
              TripStageProgress(current: live.stage),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: VanepPrimaryButton(
                    label: l10n.clientHomeLiveMap,
                    onBrand: true,
                    onPressed: null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.clientHomeTalkTo(van.driverName),
                    icon: Icons.chat_bubble_outline,
                    onBrand: true,
                    onPressed: () => openUnavailableFeature(
                      context,
                      l10n.clientHomeTalkTo(van.driverName),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LiveVanHeader extends StatelessWidget {
  const LiveVanHeader({
    required this.van,
    required this.live,
    required this.now,
    super.key,
  });

  final VanDay van;
  final LiveTrip live;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final present = van.presentRiders;
    return Row(
      children: [
        const Icon(
          Icons.radio_button_checked,
          size: 16,
          color: VanepColors.brandSheen,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.clientHomeLiveLeg(formatLeg(l10n, live.leg)).toUpperCase(),
            style: VanepTypography.cardSubtitle.copyWith(
              color: VanepColors.brandSheen,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (live.approaching)
          Text(
            l10n.clientHomeUpdatedSecondsAgo(
              now.difference(live.updatedAt).inSeconds.clamp(0, 999),
            ),
            style: VanepTypography.cardSubtitle.copyWith(color: onBrandMuted),
          )
        else if (present.length == 1) ...[
          PersonAvatar(name: present.single.name, size: 24),
          const SizedBox(width: 6),
          Text(
            present.single.name,
            style: VanepTypography.ratingLabel.copyWith(
              color: VanepColors.onBrand,
            ),
          ),
        ],
      ],
    );
  }
}

class TripStageProgress extends StatelessWidget {
  const TripStageProgress({required this.current, super.key});

  final TripStage current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        for (final (index, stage) in TripStage.values.indexed) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: stage.index < current.index
                        ? 1
                        : stage == current
                        ? 0.6
                        : 0,
                    minHeight: 4,
                    color: VanepColors.brandSheen,
                    backgroundColor: onBrandFaint,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatStage(l10n, stage),
                  style: VanepTypography.cardSubtitle.copyWith(
                    fontSize: 12,
                    color: stage == current
                        ? VanepColors.onBrand
                        : onBrandMuted,
                    fontWeight: stage == current
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class LiveRidersSummary extends StatelessWidget {
  const LiveRidersSummary({
    required this.van,
    required this.presentNames,
    super.key,
  });

  final VanDay van;
  final List<String> presentNames;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final crew = van.live?.crewNames ?? const <String>[];
    final riderLine = [
      if (presentNames.isNotEmpty)
        l10n.clientHomeBoardsAtThisStop(
          presentNames.length,
          joinNames(l10n, presentNames),
        ),
      for (final rider in van.absentRiders)
        l10n.clientHomeNotGoingToday(rider.name),
    ].join(' · ');
    final textStyle = VanepTypography.cardSubtitle.copyWith(
      color: VanepColors.onBrand,
      fontSize: 14,
    );

    return Column(
      children: [
        Row(
          children: [
            AvatarStack(
              names: riderNames(van),
              dimmedNames: {for (final rider in van.absentRiders) rider.name},
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(riderLine, style: textStyle)),
          ],
        ),
        if (crew.isNotEmpty) ...[
          Divider(height: 24, color: onBrandFaint),
          Row(
            children: [
              AvatarStack(names: crew, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.clientHomeCrewOnBoard(joinNames(l10n, crew)),
                  style: textStyle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class IllustrativeMap extends StatelessWidget {
  const IllustrativeMap({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: onBrandFaint,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
      ),
      child: Stack(
        children: [
          const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HomeIconBubble(
                  icon: Icons.airport_shuttle,
                  background: VanepColors.onBrand,
                  foreground: VanepColors.brandNavy,
                  size: 32,
                ),
                SizedBox(width: 80),
                HomeIconBubble(
                  icon: Icons.home,
                  background: VanepColors.action,
                  foreground: VanepColors.onBrand,
                  size: 32,
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: VanepColors.brandNavyDeep,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.clientHomeIllustrativeMap,
                style: VanepTypography.cardSubtitle.copyWith(
                  color: VanepColors.onBrand,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
