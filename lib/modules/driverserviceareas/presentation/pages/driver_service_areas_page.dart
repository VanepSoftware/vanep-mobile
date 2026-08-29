import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/places/place_autocomplete_controller.dart';
import '../../../../core/ui/vanep_glass_card.dart';
import '../../../../core/ui/vanep_place_autocomplete_field.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_screen_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/service_area_draft.dart';
import '../cubit/driver_service_areas_cubit.dart';
import '../cubit/driver_service_areas_state.dart';
import '../formatters/service_area_failure_label.dart';

class DriverServiceAreasPage extends StatelessWidget {
  const DriverServiceAreasPage({required this.autocomplete, super.key});

  final PlaceAutocompleteController autocomplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.serviceAreasTitle),
        ),
        body: BlocBuilder<DriverServiceAreasCubit, DriverServiceAreasState>(
          builder: (context, state) {
            final cubit = context.read<DriverServiceAreasCubit>();
            final failure = state.failure;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.serviceAreasSubtitle,
                    style: VanepTypography.cardSubtitle,
                  ),
                  const SizedBox(height: 16),
                  VanepPlaceAutocompleteField(
                    controller: autocomplete,
                    enabled: state.canAddMore,
                    hint: l10n.serviceAreasSearchHint,
                    emptyLabel: l10n.placeAutocompleteNoResults,
                    networkErrorLabel: l10n.placeAutocompleteNetworkError,
                    keyErrorLabel: l10n.placeAutocompleteKeyError,
                    retryLabel: l10n.placeAutocompleteRetry,
                    onSelected: (selection) => cubit.addDraft(
                      ServiceAreaDraft(
                        placeId: selection.suggestion.placeId,
                        label: selection.suggestion.primaryText,
                        sessionToken: selection.sessionToken,
                      ),
                    ),
                  ),
                  if (!state.canAddMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.serviceAreasMaxReached,
                        style: VanepTypography.cardSubtitle,
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (state.isEmpty)
                    Text(
                      l10n.serviceAreasEmpty,
                      style: VanepTypography.cardSubtitle,
                    ),
                  for (final draft in state.drafts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: VanepGlassCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft.label,
                                    style: VanepTypography.cardTitle,
                                  ),
                                  if (draft.looksCityWide)
                                    Text(
                                      l10n.serviceAreasCityWideHint,
                                      style: VanepTypography.cardSubtitle,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.serviceAreasRemove,
                              icon: const Icon(
                                Icons.close,
                                color: VanepColors.textSecondary,
                              ),
                              onPressed: () => cubit.removeDraft(draft.placeId),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (failure != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        serviceAreaFailureLabel(l10n, failure),
                        style: VanepTypography.cardSubtitle.copyWith(
                          color: VanepColors.textPrimary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  VanepPrimaryButton(
                    label: l10n.serviceAreasSave,
                    isLoading: state.status == DriverServiceAreasStatus.saving,
                    onPressed: state.isEmpty ? null : cubit.saveAreas,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
