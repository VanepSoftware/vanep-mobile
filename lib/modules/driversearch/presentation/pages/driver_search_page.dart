import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/places/place_autocomplete_controller.dart';
import '../../../../core/ui/vanep_place_autocomplete_field.dart';
import '../../../../core/ui/vanep_screen_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../drivers/presentation/widgets/driver_card.dart';
import '../cubit/driver_search_cubit.dart';
import '../cubit/driver_search_state.dart';
import '../formatters/driver_search_failure_label.dart';

class DriverSearchPage extends StatelessWidget {
  const DriverSearchPage({required this.autocomplete, super.key});

  final PlaceAutocompleteController autocomplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.driverSearchTitle),
        ),
        body: BlocBuilder<DriverSearchCubit, DriverSearchState>(
          builder: (context, state) {
            final cubit = context.read<DriverSearchCubit>();
            final failure = state.failure;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                VanepPlaceAutocompleteField(
                  controller: autocomplete,
                  hint: l10n.driverSearchHint,
                  emptyLabel: l10n.placeAutocompleteNoResults,
                  networkErrorLabel: l10n.placeAutocompleteNetworkError,
                  keyErrorLabel: l10n.placeAutocompleteKeyError,
                  retryLabel: l10n.placeAutocompleteRetry,
                  onSelected: (selection) => cubit.searchPlace(
                    selection.suggestion.placeId,
                    label: selection.suggestion.primaryText,
                    sessionToken: selection.sessionToken,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.status == DriverSearchStatus.searching)
                  const Center(child: CircularProgressIndicator()),
                if (failure != null)
                  Text(
                    driverSearchFailureLabel(l10n, failure),
                    style: VanepTypography.cardSubtitle,
                  ),
                if (state.hasNoResults)
                  Text(
                    l10n.driverSearchEmpty,
                    style: VanepTypography.cardSubtitle,
                  ),
                for (final driver in state.results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DriverCard(driver: driver),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
