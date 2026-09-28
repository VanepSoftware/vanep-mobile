import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/drivers_home_body.dart';
import '../widgets/drivers_search_field.dart';

class FindVansTab extends StatelessWidget {
  const FindVansTab({
    required this.onSearchTapped,
    this.onDriverSelected,
    super.key,
  });

  final VoidCallback onSearchTapped;

  final ValueChanged<String>? onDriverSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          Text(l10n.navVans, style: VanepTypography.pageTitle),
          const SizedBox(height: 20),
          DriversSearchField(
            hint: l10n.driverSearchHint,
            onTap: onSearchTapped,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.driversSuggestionsNearYou,
            style: VanepTypography.sectionTitle,
          ),
          const SizedBox(height: 12),
          DriversHomeBody(onDriverSelected: onDriverSelected),
        ],
      ),
    );
  }
}
