import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/formatters/van_central_labels.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';

class VanSelector extends StatelessWidget {
  const VanSelector({
    required this.vans,
    required this.selectedVanToken,
    required this.onSelected,
    super.key,
  });

  final List<DriverVan> vans;
  final String? selectedVanToken;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.vanCentralChooseVan,
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final van in vans) ...[
              if (van != vans.first) const SizedBox(width: 8),
              VanSelectorPill(
                label: vanPillLabel(l10n, van),
                selected: van.token == selectedVanToken,
                onTap: () => onSelected(van.token),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VanSelectorPill extends StatelessWidget {
  const VanSelectorPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? VanepColors.brandNavy : VanepColors.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? VanepColors.brandNavy : VanepColors.inputBorder,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: VanepTypography.fieldLabel.copyWith(
                fontSize: 14,
                color: selected ? VanepColors.onBrand : VanepColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
