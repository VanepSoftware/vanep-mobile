import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/formatters/driver_search_failure_label.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_driver_card.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_empty_view.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_header.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_route_filter_card.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_sheets.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_skeleton.dart';

const loadMoreThresholdPixels = 240.0;

VoidCallback? selectDriverCallback(
  ValueChanged<String>? onDriverSelected,
  String driverToken,
) {
  if (onDriverSelected == null) return null;
  return () => onDriverSelected(driverToken);
}

class DriverSearchPage extends StatefulWidget {
  const DriverSearchPage({
    required this.autocomplete,
    this.onDriverSelected,
    this.onQuoteRequested,
    this.onInviteSubmitted,
    super.key,
  });

  final PlaceAutocompleteController autocomplete;

  final ValueChanged<String>? onDriverSelected;

  final ValueChanged<String>? onQuoteRequested;

  final ValueChanged<String>? onInviteSubmitted;

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
        scrollController.position.maxScrollExtent -
        scrollController.position.pixels;
    if (remaining > loadMoreThresholdPixels) return;
    context.read<DriverSearchCubit>().loadMore();
  }

  String? _formattedOrigin(AppLocalizations l10n, DriverSearchState state) {
    final label = state.effectiveOriginLabel;
    if (label == null) return null;
    if (state.defaultOriginText != null && label == state.defaultOriginText) {
      return l10n.findVanHomePrefix(label);
    }
    return label;
  }

  String? _formattedDestination(AppLocalizations l10n, DriverSearchState state) {
    final label = state.effectiveDestinationLabel;
    if (label == null) return null;
    if (state.defaultOriginText != null && label == state.defaultOriginText) {
      return l10n.findVanHomePrefix(label);
    }
    return label;
  }

  Future<void> _useRegisteredOrigin(
    BuildContext context,
    DriverSearchCubit cubit,
    DriverSearchState state,
  ) async {
    final defaultOrigin = state.defaultOriginText;
    if (defaultOrigin == null) return;
    final token = widget.autocomplete.handOverSelection();
    final result = await widget.autocomplete.datasource.findSuggestions(
      defaultOrigin,
      token,
    );
    if (!context.mounted) return;
    if (result case Ok(:final value) when value.isNotEmpty) {
      await cubit.searchFromRoute(
        isDestination: false,
        placeId: value.first.placeId,
        label: defaultOrigin,
        sessionToken: token,
      );
      return;
    }
    cubit.useProfileOrigin();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: BlocBuilder<DriverSearchCubit, DriverSearchState>(
          builder: (context, state) {
            final cubit = context.read<DriverSearchCubit>();
            final failure = state.failure;
            final visibleDrivers = state.displayedResults;

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                FindVanHeader(
                  showBackButton: canPop,
                  onInviteTapped: () => showFindVanInviteSheet(
                    context,
                    onInviteSubmitted: widget.onInviteSubmitted,
                  ),
                ),
                const SizedBox(height: 16),
                FindVanRouteFilterCard(
                  originLabel: _formattedOrigin(l10n, state),
                  destinationLabel: _formattedDestination(l10n, state),
                  onOriginTapped: () => showFindVanPlaceSheet(
                    context,
                    isDestination: false,
                    autocomplete: widget.autocomplete,
                    hasActiveSearch: state.hasActivePlaceSearch,
                    onClearSearch: cubit.clearSearch,
                    registeredOriginLabel:
                        state.originLabel != state.defaultOriginText
                        ? state.defaultOriginText
                        : null,
                    onUseRegisteredOrigin: () =>
                        _useRegisteredOrigin(context, cubit, state),
                    onSelected: (selection) => cubit.searchFromRoute(
                      isDestination: false,
                      placeId: selection.suggestion.placeId,
                      label: selection.suggestion.primaryText,
                      sessionToken: selection.sessionToken,
                    ),
                  ),
                  onDestinationTapped: () => showFindVanPlaceSheet(
                    context,
                    isDestination: true,
                    autocomplete: widget.autocomplete,
                    hasActiveSearch: state.hasActivePlaceSearch,
                    onClearSearch: cubit.clearSearch,
                    onSelected: (selection) => cubit.searchFromRoute(
                      isDestination: true,
                      placeId: selection.suggestion.placeId,
                      label: selection.suggestion.primaryText,
                      sessionToken: selection.sessionToken,
                    ),
                  ),
                  onSwapTapped: cubit.swapRoute,
                  dependents: state.dependents,
                  selectedDependentTokens: state.selectedDependentTokens,
                  onFiltersTapped: () =>
                      showFindVanFilterSheet(context, cubit: cubit),
                ),
                const SizedBox(height: 18),
                if (state.status == DriverSearchStatus.searching)
                  const FindVanSkeletonList(),
                if (failure != null && state.status == DriverSearchStatus.failed)
                  Text(
                    driverSearchFailureLabel(l10n, failure),
                    style: context.typography.cardSubtitle,
                  ),
                if (state.hasNoResults)
                  FindVanEmptyView(
                    onClearSearch: cubit.clearSearch,
                  ),
                if (visibleDrivers.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          l10n.findVanDriversCount(visibleDrivers.length),
                          style: context.typography.sectionTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        InkWell(
                          onTap: () => showFindVanSortSheet(
                            context,
                            current: state.sortOrder,
                            onSelected: cubit.setSortOrder,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    sortOrderLabel(l10n, state.sortOrder),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.action,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: context.palette.action,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                for (final driver in visibleDrivers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FindVanDriverCard(
                      driver: driver,
                      onTap: selectDriverCallback(
                        widget.onDriverSelected,
                        driver.token,
                      ),
                      onProfileTapped: selectDriverCallback(
                        widget.onDriverSelected,
                        driver.token,
                      ),
                      onQuoteRequested: driver.available
                          ? selectDriverCallback(
                              widget.onQuoteRequested,
                              driver.token,
                            )
                          : null,
                    ),
                  ),
                if (state.status == DriverSearchStatus.loadingMore)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: FindVanSkeletonList(count: 2),
                  ),
                if (failure != null &&
                    state.status == DriverSearchStatus.loadMoreFailed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          driverSearchFailureLabel(l10n, failure),
                          style: context.typography.cardSubtitle,
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
                if (visibleDrivers.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: context.palette.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.findVanPrivacyNotice,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
