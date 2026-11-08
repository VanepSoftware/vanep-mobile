import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
            style: context.typography.cardSubtitle.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Switch(value: sharing, onChanged: onChanged),
      ],
    );
  }
}
