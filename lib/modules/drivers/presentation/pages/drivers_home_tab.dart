import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/drivers_cubit.dart';
import '../widgets/client_greeting_header.dart';
import '../widgets/drivers_home_body.dart';
import '../widgets/drivers_search_field.dart';

class DriversHomeTab extends StatelessWidget {
  const DriversHomeTab({required this.displayName, super.key});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          ClientGreetingHeader(displayName: displayName),
          const SizedBox(height: 20),
          DriversSearchField(
            hint: l10n.driversSearchHint,
            onChanged: (query) => context.read<DriversCubit>().search(query),
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
