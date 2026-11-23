import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/network/api_image_provider.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/formatters/client_vans_labels.dart';

class ClientVanHeroCard extends StatelessWidget {
  const ClientVanHeroCard({
    required this.van,
    this.onTap,
    this.onChatTapped,
    this.onCallTapped,
    super.key,
  });

  final ClientVan van;
  final VoidCallback? onTap;
  final VoidCallback? onChatTapped;
  final VoidCallback? onCallTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = van.vehicle;
    final driver = van.driver;
    final statusLabel = van.isActive
        ? l10n.clientVansActiveContractBadge
        : l10n.clientVansPendingContractBadge;
    final statusColor = van.isActive
        ? context.palette.success
        : context.palette.warningText;
    final statusDotColor = van.isActive
        ? context.palette.success
        : context.palette.warning;
    final vehicleSubtitle = vehicle == null
        ? ''
        : clientVanVehicleSubtitle(l10n, vehicle);

    return Material(
      color: context.palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vehicle != null) ...[
              _VehiclePhotoBanner(
                vehicle: vehicle,
                statusLabel: statusLabel,
                statusColor: statusColor,
                statusDotColor: statusDotColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vehicle.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.typography.cardTitle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (vehicle.manufactureYear != null)
                                Text(
                                  ' · ${vehicle.manufactureYear}',
                                  style: context.typography.cardTitle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                            ],
                          ),
                          if (vehicleSubtitle.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              vehicleSubtitle,
                              style: context.typography.cardSubtitle.copyWith(
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (vehicle.plate != null && vehicle.plate!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      _LicensePlateBadge(plate: vehicle.plate!),
                    ],
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadgePill(
                    statusLabel: statusLabel,
                    statusColor: statusColor,
                    statusDotColor: statusDotColor,
                    background: context.palette.surface,
                  ),
                ),
              ),
            Divider(height: 1, thickness: 1, color: context.palette.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  VanepAvatar(
                    photoUrl: driver.photoUrl,
                    size: 42,
                    initials: initialsOf(driver.name),
                    backgroundColor: context.palette.avatarBlueSurface,
                    foregroundColor: context.palette.avatarBlueText,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.cardTitle.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              l10n.clientVansDriverRole,
                              style: context.typography.cardSubtitle.copyWith(
                                fontSize: 12.5,
                              ),
                            ),
                            if (driver.rating != null) ...[
                              Text(
                                ' · ',
                                style: context.typography.cardSubtitle.copyWith(
                                  fontSize: 12.5,
                                ),
                              ),
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: VanepColors.ratingStar,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatRating(l10n, driver.rating!),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: context.palette.textPrimary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onChatTapped != null) ...[
                    const SizedBox(width: 8),
                    _CircleActionIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      tooltip: l10n.clientVansChatDriver,
                      onTap: onChatTapped,
                    ),
                  ],
                  if (driver.phone != null && driver.phone!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _CircleActionIconButton(
                      icon: Icons.phone_outlined,
                      tooltip: l10n.clientVansCallDriver(driver.name),
                      onTap: onCallTapped ?? onTap,
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

  String _formatRating(AppLocalizations l10n, double rating) {
    final formatted = rating.toStringAsFixed(1);
    return l10n.localeName.startsWith('pt')
        ? formatted.replaceAll('.', ',')
        : formatted;
  }
}

class _VehiclePhotoBanner extends StatelessWidget {
  const _VehiclePhotoBanner({
    required this.vehicle,
    required this.statusLabel,
    required this.statusColor,
    required this.statusDotColor,
  });

  final ClientVanVehicle vehicle;
  final String statusLabel;
  final Color statusColor;
  final Color statusDotColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photo = vehicle.photoFrontUrl ?? vehicle.photoSideUrl;
    final image = apiImageFor(context, photo);

    return SizedBox(
      height: 156,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(context, l10n),
            )
          else
            _placeholder(context, l10n),
          Positioned(
            top: 12,
            left: 12,
            child: _StatusBadgePill(
              statusLabel: statusLabel,
              statusColor: statusColor,
              statusDotColor: statusDotColor,
              background: context.palette.card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context, AppLocalizations l10n) {
    return ColoredBox(
      color: context.palette.avatarBlueSurface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_bus_rounded,
              size: 44,
              color: context.palette.avatarBlueText,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.clientVansPhotoPlaceholder,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.palette.avatarBlueText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadgePill extends StatelessWidget {
  const _StatusBadgePill({
    required this.statusLabel,
    required this.statusColor,
    required this.statusDotColor,
    required this.background,
  });

  final String statusLabel;
  final Color statusColor;
  final Color statusDotColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusDotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LicensePlateBadge extends StatelessWidget {
  const _LicensePlateBadge({required this.plate});

  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.palette.textPrimary, width: 1.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 72,
            color: VanepColors.brandNavy,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              plate.toUpperCase(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: context.palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionIconButton extends StatelessWidget {
  const _CircleActionIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.palette.card,
        shape: CircleBorder(
          side: BorderSide(color: context.palette.inputBorder),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 18,
              color: context.palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
