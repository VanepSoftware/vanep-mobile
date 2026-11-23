import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/network/api_image_provider.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/presentation/formatters/driver_profile_formatters.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_ratings_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_van_photos_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_verification_sheet.dart';

class DriverProfileCoverCarousel extends StatefulWidget {
  const DriverProfileCoverCarousel({required this.profile, super.key});

  final DriverProfile profile;

  @override
  State<DriverProfileCoverCarousel> createState() =>
      _DriverProfileCoverCarouselState();
}

class _DriverProfileCoverCarouselState
    extends State<DriverProfileCoverCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photos = collectDriverVehiclePhotos(l10n, widget.profile);

    return GestureDetector(
      onTap: photos.isEmpty
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DriverVanPhotosPage(profile: widget.profile),
                ),
              ),
      child: SizedBox(
        height: 210,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photos.isEmpty)
              const DriverVanIllustration(showLabel: true)
            else
              PageView.builder(
                controller: _controller,
                itemCount: photos.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final entry = photos[index];
                  final image = apiImageFor(context, entry.url);
                  if (image == null) {
                    return const DriverVanIllustration(showLabel: true);
                  }
                  return Image(
                    image: image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const DriverVanIllustration(showLabel: true),
                  );
                },
              ),
            if (photos.isNotEmpty)
              Positioned(
                right: 16,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0B2038),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l10n.driverProfilePhotoCounter(_index + 1, photos.length),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DriverProfileIdentityBlock extends StatelessWidget {
  const DriverProfileIdentityBlock({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tone = vanepInitialAvatarColors(context.palette, profile.token);
    final rating = profile.rating;
    final experience = profile.experienceYears;
    final count = profile.ratingCount;

    return VanepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          VanepAvatar(
            photoUrl: profile.photoUrl,
            size: 56,
            initials: vanepInitialOf(profile.name),
            backgroundColor: tone.surface,
            foregroundColor: tone.text,
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
                        profile.name,
                        style: context.typography.cardTitle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (profile.verified) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified,
                        size: 18,
                        color: context.palette.action,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    if (rating != null) ...[
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: context.palette.warning,
                      ),
                      Text(
                        formatDriverRating(l10n, rating),
                        style: context.typography.ratingLabel.copyWith(
                          fontSize: 13.5,
                        ),
                      ),
                      if (count != null && count > 0)
                        Text(
                          '· ${l10n.driverProfileReviewsCount(count)}',
                          style: context.typography.cardSubtitle,
                        ),
                    ] else
                      Text(
                        l10n.findVanNewOnVanep,
                        style: context.typography.cardSubtitle,
                      ),
                  ],
                ),
                if (experience != null && experience > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.driverProfileExperience(experience),
                    style: context.typography.cardSubtitle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DriverProfileVacanciesCard extends StatelessWidget {
  const DriverProfileVacanciesCard({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = profile.basePrice;
    final vacancies = profile.shiftVacancies;

    final rows = <Widget>[
      if (vacancies.isNotEmpty)
        for (final vacancy in vacancies) _ShiftVacancyRow(vacancy: vacancy)
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: profile.available
                      ? context.palette.success
                      : context.palette.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                profile.available
                    ? l10n.findVanSpotsAvailable
                    : l10n.findVanSpotsFull,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: profile.available
                      ? context.palette.success
                      : context.palette.danger,
                ),
              ),
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: price != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.driverProfileStartingFromLabel,
                    style: context.typography.body.copyWith(
                      fontSize: 14,
                      color: context.palette.textSecondary,
                    ),
                  ),
                  Text(
                    formatMoney(l10n, (price * 100).round()),
                    style: context.typography.body.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ],
              )
            : Text(
                l10n.findVanPriceOnRequest,
                style: context.typography.cardSubtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ];

    return VanepSection(
      title: l10n.driverProfileVacanciesSectionTitle,
      child: _DividedCard(children: rows),
    );
  }
}

class _ShiftVacancyRow extends StatelessWidget {
  const _ShiftVacancyRow({required this.vacancy});

  final DriverShiftVacancy vacancy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spots = vacancy.spots;
    final String statusLabel;
    final Color statusColor;

    if (vacancy.status != null && vacancy.status!.isNotEmpty) {
      statusLabel = vacancy.status!;
      statusColor = (spots ?? 1) <= 0
          ? context.palette.textPrimary
          : spots == 1
          ? context.palette.warning
          : context.palette.success;
    } else if (spots == null || spots <= 0) {
      statusLabel = l10n.driverProfileShiftFull;
      statusColor = context.palette.textPrimary;
    } else {
      statusLabel = l10n.driverProfileShiftVacancyAvailable(spots);
      statusColor = spots == 1
          ? context.palette.warning
          : context.palette.success;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              vacancy.shift,
              style: context.typography.body.copyWith(
                fontSize: 14,
                color: context.palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DriverProfileVansSection extends StatelessWidget {
  const DriverProfileVansSection({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicles = profile.vehicles;

    return VanepSection(
      title: l10n.driverProfileVansSectionTitle,
      child: vehicles.isEmpty
          ? VanepCard(
              child: Text(
                l10n.driverProfileNoVan,
                style: context.typography.cardSubtitle,
              ),
            )
          : _DividedCard(
              children: [
                for (final vehicle in vehicles)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DriverVanPhotosPage(profile: profile),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _VehicleThumbnail(vehicle: vehicle),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatVanModelYear(l10n, vehicle),
                                  style: context.typography.cardTitle.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatVanPublicSubtitle(l10n, vehicle),
                                  style: context.typography.cardSubtitle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: context.palette.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _VehicleThumbnail extends StatelessWidget {
  const _VehicleThumbnail({required this.vehicle});

  final DriverProfileVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final url = vehicle.photoFrontUrl ?? vehicle.photoSideUrl;
    final image = apiImageFor(context, url);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 42,
        child: image == null
            ? const DriverVanIllustration(showLabel: false)
            : Image(
                image: image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const DriverVanIllustration(showLabel: false),
              ),
      ),
    );
  }
}

class DriverProfileServiceSection extends StatelessWidget {
  const DriverProfileServiceSection({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final areas = formatServiceAreaList(profile.serviceAreas);
    final workStart = profile.workStartTime;
    final workEnd = profile.workEndTime;
    final workDays = profile.workDays;
    final waitMinutes = profile.waitToleranceMinutes;

    final rows = <({String label, String value})>[
      if (areas.isNotEmpty)
        (label: l10n.driverProfileServiceAreasLabel, value: areas),
      if (workStart != null && workEnd != null)
        (
          label: l10n.driverProfileWorkHoursLabel,
          value: workDays != null && workDays.isNotEmpty
              ? l10n.driverProfileWorkHoursValue(workStart, workEnd, workDays)
              : '$workStart às $workEnd',
        ),
      if (waitMinutes != null)
        (
          label: l10n.driverProfileWaitToleranceLabel,
          value: l10n.driverProfileWaitToleranceValue(waitMinutes),
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: VanepSection(
        title: l10n.driverProfileServiceSectionTitle,
        child: _DividedCard(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.label,
                      style: context.typography.body.copyWith(
                        fontSize: 14,
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.right,
                        style: context.typography.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.palette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DriverProfileVerifiedCard extends StatelessWidget {
  const DriverProfileVerifiedCard({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      onTap: () => DriverVerificationSheet.show(
        context,
        driverName: profile.name,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.palette.successSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user,
              size: 20,
              color: context.palette.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverProfileVerifiedCardTitle,
                  style: context.typography.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.driverProfileVerifiedCardSubtitle,
                  style: context.typography.cardSubtitle,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.palette.textMuted),
        ],
      ),
    );
  }
}

class DriverProfileRatingsSection extends StatelessWidget {
  const DriverProfileRatingsSection({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasDetail =
        profile.ratings.isNotEmpty || profile.ratingBreakdown.isNotEmpty;
    if (profile.rating == null && !hasDetail) {
      return const SizedBox.shrink();
    }

    final rating = profile.rating;
    final count = profile.ratingCount ?? profile.ratings.length;
    final previews = profile.ratings.take(2).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: VanepSection(
        title: l10n.driverProfileReviewsSectionTitle,
        actionLabel: hasDetail ? l10n.driverProfileSeeAllReviews : null,
        onAction: hasDetail
            ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DriverRatingsPage(profile: profile),
                  ),
                )
            : null,
        child: _DividedCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rating != null ? formatDriverRating(l10n, rating) : '—',
                    style: context.typography.pageTitle.copyWith(
                      fontSize: 28,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StarRatingRow(
                        filledCount: rating?.round() ?? 0,
                        size: 15,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        count > 0
                            ? l10n.driverProfileReviewsCount(count)
                            : l10n.findVanNewOnVanep,
                        style: context.typography.cardSubtitle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            for (final review in previews)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            review.authorName,
                            style: context.typography.sectionTitle.copyWith(
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        if (review.dateLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            review.dateLabel,
                            style: context.typography.cardSubtitle.copyWith(
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _StarRatingRow(filledCount: review.stars, size: 14),
                    if (review.comment.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        review.comment,
                        style: context.typography.body.copyWith(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DividedCard extends StatelessWidget {
  const _DividedCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return VanepCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, color: context.palette.divider),
          ],
        ],
      ),
    );
  }
}

class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow({required this.filledCount, required this.size});

  final int filledCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star_rounded,
          size: size,
          color: index < filledCount
              ? context.palette.warning
              : context.palette.divider,
        ),
      ),
    );
  }
}

class DriverVanIllustration extends StatelessWidget {
  const DriverVanIllustration({required this.showLabel, super.key});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontFamily =
        DefaultTextStyle.of(context).style.fontFamily ??
        Theme.of(context).textTheme.bodyMedium?.fontFamily;
    return CustomPaint(
      painter: _DriverVanIllustrationPainter(
        skyColor: isDark ? const Color(0xFF1C2A3A) : const Color(0xFFDDE6F0),
        groundColor: isDark ? const Color(0xFF152232) : const Color(0xFFCBD5E1),
        bodyColor: isDark ? const Color(0xFFE8EEF5) : const Color(0xFFFFFFFF),
        outlineColor: isDark ? const Color(0xFF475569) : const Color(0xFFB8C4D0),
        windowColor: isDark ? const Color(0xFF5D7FA0) : const Color(0xFF93B0C8),
        stripeColor: const Color(0xFFF5C518),
        wheelColor: const Color(0xFF1E293B),
        hubColor: const Color(0xFF94A3B8),
        signalColor: const Color(0xFFF59E0B),
        fontFamily: fontFamily,
        showLabel: showLabel,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _DriverVanIllustrationPainter extends CustomPainter {
  const _DriverVanIllustrationPainter({
    required this.skyColor,
    required this.groundColor,
    required this.bodyColor,
    required this.outlineColor,
    required this.windowColor,
    required this.stripeColor,
    required this.wheelColor,
    required this.hubColor,
    required this.signalColor,
    required this.fontFamily,
    required this.showLabel,
  });

  final Color skyColor;
  final Color groundColor;
  final Color bodyColor;
  final Color outlineColor;
  final Color windowColor;
  final Color stripeColor;
  final Color wheelColor;
  final Color hubColor;
  final Color signalColor;
  final String? fontFamily;
  final bool showLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h * 0.78;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, groundY),
      Paint()..color = skyColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, w, h - groundY),
      Paint()..color = groundColor,
    );

    final vanW = showLabel ? w * 0.70 : w * 0.78;
    final vanH = showLabel ? h * 0.43 : h * 0.60;
    final left = (w - vanW) / 2;
    final bottom = groundY - vanH * 0.06;
    final top = bottom - vanH;
    final right = left + vanW;

    final bodyPath = Path()
      ..moveTo(left + vanW * 0.04, top)
      ..lineTo(left + vanW * 0.73, top)
      ..quadraticBezierTo(
        left + vanW * 0.79,
        top,
        left + vanW * 0.83,
        top + vanH * 0.09,
      )
      ..lineTo(left + vanW * 0.96, top + vanH * 0.50)
      ..quadraticBezierTo(
        right,
        top + vanH * 0.56,
        right,
        top + vanH * 0.65,
      )
      ..lineTo(right, bottom - vanH * 0.08)
      ..quadraticBezierTo(right, bottom, right - vanW * 0.04, bottom)
      ..lineTo(left + vanW * 0.04, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - vanH * 0.08)
      ..lineTo(left, top + vanH * 0.08)
      ..quadraticBezierTo(left, top, left + vanW * 0.04, top)
      ..close();

    canvas.drawPath(bodyPath, Paint()..color = bodyColor);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = showLabel ? 1.2 : 0.8,
    );

    final winPaint = Paint()..color = windowColor;
    final winTop = top + vanH * 0.14;
    final winH = vanH * 0.31;
    final winRadius = Radius.circular(vanH * 0.04);

    for (var i = 0; i < 3; i++) {
      final winLeft = left + vanW * (0.06 + i * 0.19);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(winLeft, winTop, vanW * 0.155, winH),
          winRadius,
        ),
        winPaint,
      );
    }

    final windshield = Path()
      ..moveTo(left + vanW * 0.64, winTop)
      ..lineTo(left + vanW * 0.78, winTop)
      ..lineTo(left + vanW * 0.89, winTop + winH)
      ..lineTo(left + vanW * 0.64, winTop + winH)
      ..close();
    canvas.drawPath(windshield, winPaint);

    final stripeTop = top + vanH * 0.55;
    final stripeH = vanH * 0.14;
    canvas.drawRect(
      Rect.fromLTWH(left + 1, stripeTop, vanW - 2, stripeH),
      Paint()..color = stripeColor,
    );

    if (showLabel) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'ESCOLAR',
          style: TextStyle(
            fontFamily: fontFamily,
            color: wheelColor,
            fontSize: (stripeH * 0.62).clamp(7.0, 10.0),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          left + (vanW - tp.width) / 2,
          stripeTop + (stripeH - tp.height) / 2,
        ),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          right - vanW * 0.055,
          top + vanH * 0.67,
          vanW * 0.04,
          vanH * 0.11,
        ),
        Radius.circular(vanH * 0.02),
      ),
      Paint()..color = signalColor,
    );

    final wheelRadius = vanH * 0.16;
    final wheelY = bottom + vanH * 0.02;
    for (final centerX in [left + vanW * 0.21, left + vanW * 0.78]) {
      final center = Offset(centerX, wheelY);
      canvas.drawCircle(center, wheelRadius, Paint()..color = wheelColor);
      canvas.drawCircle(center, wheelRadius * 0.44, Paint()..color = hubColor);
    }
  }

  @override
  bool shouldRepaint(covariant _DriverVanIllustrationPainter oldDelegate) =>
      oldDelegate.skyColor != skyColor ||
      oldDelegate.groundColor != groundColor ||
      oldDelegate.fontFamily != fontFamily ||
      oldDelegate.showLabel != showLabel;
}
