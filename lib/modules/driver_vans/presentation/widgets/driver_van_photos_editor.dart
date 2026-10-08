import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_slot.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_source_sheet.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_side.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_target.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/formatters/driver_van_labels.dart';

class DriverVanPhotosEditor extends StatelessWidget {
  const DriverVanPhotosEditor({required this.van, super.key});

  final DriverVan van;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(driverVanTitle(l10n, van), style: VanepTypography.cardTitle),
        const SizedBox(height: 4),
        Text(
          '${van.plate} · ${l10n.driverProfileVanCapacity(van.capacity)} · ${van.color}',
          style: VanepTypography.cardSubtitle,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final side in VanPhotoSide.values) ...[
              if (side != VanPhotoSide.values.first) const SizedBox(width: 12),
              Expanded(
                child: DriverVanPhotoSlot(van: van, side: side),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class DriverVanPhotoSlot extends StatelessWidget {
  const DriverVanPhotoSlot({required this.van, required this.side, super.key});

  final DriverVan van;
  final VanPhotoSide side;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final target = VanPhotoTarget(vanToken: van.token, side: side);
    final isUploading = context.select<DriverVansCubit, bool>(
      (cubit) => cubit.state.isUploading(target),
    );

    return VanepPhotoSlot(
      photoUrl: vanPhotoUrlFor(van, side),
      label: vanPhotoSideLabel(l10n, side),
      placeholderIcon: Icons.airport_shuttle_outlined,
      isUploading: isUploading,
      onTap: () => pickAndChangeVanPhoto(context, l10n, target),
    );
  }
}

Future<void> pickAndChangeVanPhoto(
  BuildContext context,
  AppLocalizations l10n,
  VanPhotoTarget target,
) async {
  final cubit = context.read<DriverVansCubit>();
  final source = await showVanepPhotoSourceSheet(
    context,
    galleryLabel: l10n.photoSourceGallery,
    cameraLabel: l10n.photoSourceCamera,
  );
  if (source == null) return;
  await cubit.changePhoto(target, source);
}
