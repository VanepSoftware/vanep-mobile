import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_home_tab.dart';

import '../modules/driver/driver_home_fixture.dart';

void main() => runApp(const DriverHomePreview());

// TODO(VAN-66): This alternate entrypoint uses mocked test fixtures solely for
// device review. Use main.dart and the production repository for API evidence.
class DriverHomePreview extends StatefulWidget {
  const DriverHomePreview({super.key});
  @override
  State<DriverHomePreview> createState() => DriverHomePreviewState();
}

class DriverHomePreviewState extends State<DriverHomePreview> {
  HomePhase phase = HomePhase.beforeDeparture;
  bool english = false;
  bool blocked = false;
  bool outsideHours = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: VanepTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale(english ? 'en' : 'pt'),
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.driverHomePreviewTitle)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<HomePhase>(
                        isExpanded: true,
                        value: phase,
                        items: [
                          for (final item in HomePhase.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(item.name),
                            ),
                        ],
                        onChanged: (value) => setState(() => phase = value!),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => english = !english),
                      child: Text(english ? 'PT' : 'EN'),
                    ),
                  ],
                ),
              ),
              Wrap(
                children: [
                  FilterChip(
                    label: Text(l10n.driverHomeBlockedTitle),
                    selected: blocked,
                    onSelected: (value) => setState(() => blocked = value),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(l10n.driverHomeOutsideHours),
                    selected: outsideHours,
                    onSelected: (value) => setState(() => outsideHours = value),
                  ),
                ],
              ),
              Expanded(
                child: BlocProvider(
                  key: ValueKey((phase, blocked, outsideHours)),
                  create: (_) => DriverHomeCubit(
                    repository: DriverHomeFixtureRepository(
                      driverHomeFixture(
                        phase,
                        blockedInProgress: blocked,
                        outsideWorkingHours: outsideHours,
                      ),
                    ),
                  ),
                  child: DriverHomeTab(
                    displayName: 'Fabio Teixeira',
                    onMenuTapped: () {},
                    onNotificationsTapped: () {},
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
