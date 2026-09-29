import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/vanep_card.dart';
import '../../../../core/ui/vanep_greeting_header.dart';
import '../../../../core/ui/vanep_home_top_bar.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/driver_home_cubit.dart';
import '../cubit/driver_home_state.dart';
import '../widgets/driver_location_sharing_tile.dart';
import '../widgets/driver_shift_badge.dart';

class DriverHomeTab extends StatelessWidget {
  const DriverHomeTab({
    required this.displayName,
    required this.onMenuTapped,
    required this.onNotificationsTapped,
    super.key,
  });

  final String displayName;
  final VoidCallback onMenuTapped;
  final VoidCallback onNotificationsTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DriverHomeCubit>();

    return SafeArea(
      bottom: false,
      child: BlocBuilder<DriverHomeCubit, DriverHomeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              VanepHomeTopBar(
                onMenuTapped: onMenuTapped,
                onNotificationsTapped: onNotificationsTapped,
              ),
              const SizedBox(height: 8),
              VanepGreetingHeader(
                displayName: displayName,
                subtitle: l10n.driverShiftStartsAt(state.shiftStartTime),
              ),
              const SizedBox(height: 14),
              DriverShiftBadge(onShift: state.onShift),
              const SizedBox(height: 20),
              const VanepCard(child: SizedBox(height: 56)),
              const SizedBox(height: 24),
              VanepPrimaryButton(
                label: state.onShift
                    ? l10n.driverEndRoute
                    : l10n.driverStartRoute,
                onPressed: state.onShift ? cubit.endRoute : cubit.startRoute,
              ),
              const SizedBox(height: 20),
              DriverLocationSharingTile(
                sharing: state.sharingLocation,
                onChanged: cubit.setLocationSharing,
              ),
            ],
          );
        },
      ),
    );
  }
}
