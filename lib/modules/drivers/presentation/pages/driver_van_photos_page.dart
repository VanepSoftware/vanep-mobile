import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_slot.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/presentation/formatters/driver_profile_formatters.dart';

class DriverVanPhotosPage extends StatelessWidget {
  const DriverVanPhotosPage({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(
        title: l10n.driverProfilePhotosTitle,
        caption: profile.name,
      ),
      body: profile.vehicles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.driverProfilePhotosEmpty,
                  style: context.typography.cardSubtitle,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: profile.vehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final vehicle = profile.vehicles[index];
                return _VehiclePhotosCard(vehicle: vehicle);
              },
            ),
    );
  }
}

class _VehiclePhotosCard extends StatelessWidget {
  const _VehiclePhotosCard({required this.vehicle});

  final DriverProfileVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final capacityMeta = '${vehicle.color} · ${l10n.driverProfileVanCapacity(vehicle.capacity)}';

    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                formatVanModelYear(l10n, vehicle),
                style: context.typography.sectionTitle,
              ),
              Text(capacityMeta, style: context.typography.cardSubtitle),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VanepPhotoSlot(
                  photoUrl: vehicle.photoFrontUrl,
                  label: l10n.driverVanPhotoFront,
                  placeholderIcon: Icons.directions_bus_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VanepPhotoSlot(
                  photoUrl: vehicle.photoSideUrl,
                  label: l10n.driverVanPhotoSide,
                  placeholderIcon: Icons.directions_bus_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
