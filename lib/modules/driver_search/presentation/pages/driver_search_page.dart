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

const loadMoreThresholdPixels = 240.0;

class DriverSearchPage extends StatefulWidget {
  const DriverSearchPage({required this.autocomplete, super.key});

  final PlaceAutocompleteController autocomplete;

  @override
  State<DriverSearchPage> createState() => DriverSearchPageState();
}

class DriverSearchPageState extends State<DriverSearchPage> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(loadMoreWhenNearTheEnd);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(loadMoreWhenNearTheEnd)
      ..dispose();
    super.dispose();
  }

  void loadMoreWhenNearTheEnd() {
    if (!scrollController.hasClients) return;
    final remaining =
        scrollController.position.maxScrollExtent - scrollController.position.pixels;
    if (remaining > loadMoreThresholdPixels) return;
    context.read<DriverSearchCubit>().loadMore();
  }

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
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                VanepPlaceAutocompleteField(
                  controller: widget.autocomplete,
                  clearOnSelect: false,
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
                if (failure != null &&
                    state.status == DriverSearchStatus.failed)
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
                    child: DriverCard(
                      driver: driver,
                      coverage: driver.serviceAreas,
                    ),
                  ),
                if (state.status == DriverSearchStatus.loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (failure != null &&
                    state.status == DriverSearchStatus.loadMoreFailed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          driverSearchFailureLabel(l10n, failure),
                          style: VanepTypography.cardSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: cubit.retryLoadMore,
                          child: Text(l10n.driversRetryButton),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
