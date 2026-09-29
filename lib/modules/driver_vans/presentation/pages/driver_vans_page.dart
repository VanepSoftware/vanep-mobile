import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/driver_vans_section.dart';

class DriverVansPage extends StatelessWidget {
  const DriverVansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: VanepColors.surface,
      appBar: AppBar(title: Text(l10n.driverVansMyVans)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: const [DriverVansSection()],
      ),
    );
  }
}
