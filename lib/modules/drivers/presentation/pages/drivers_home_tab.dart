import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_greeting_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/drivers_home_body.dart';
import '../widgets/drivers_search_field.dart';

class DriversHomeTab extends StatelessWidget {
  const DriversHomeTab({
    required this.displayName,
    required this.onSearchTapped,
    super.key,
  });

  final String displayName;

  final VoidCallback onSearchTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          VanepGreetingHeader(displayName: displayName),
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
          const DriversHomeBody(),
        ],
      ),
    );
  }
}
