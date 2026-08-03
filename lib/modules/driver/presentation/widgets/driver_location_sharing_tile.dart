import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';

class DriverLocationSharingTile extends StatelessWidget {
  const DriverLocationSharingTile({
    required this.sharing,
    required this.onChanged,
    super.key,
  });

  final bool sharing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.driverShareLiveLocation,
            style: VanepTypography.cardSubtitle.copyWith(
              color: VanepColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: sharing,
          onChanged: onChanged,
          activeTrackColor: VanepColors.brand,
        ),
      ],
    );
  }
}
