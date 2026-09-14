import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/places/place_autocomplete_controller.dart';
import '../../../../core/ui/vanep_place_autocomplete_field.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/dependent_address_draft.dart';
import '../../domain/value_objects/dependent_draft.dart';
import '../cubit/dependent_form_cubit.dart';
import '../cubit/dependent_form_state.dart';
import '../formatters/dependent_labels.dart';

class DependentAddressField extends StatelessWidget {
  const DependentAddressField({
    required this.state,
    required this.autocomplete,
    required this.numberController,
    required this.complementController,
    super.key,
  });

  final DependentFormState state;
  final PlaceAutocompleteController autocomplete;
  final TextEditingController numberController;
  final TextEditingController complementController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentFormCubit>();
    final address = state.draft.address;
    final errorText = dependentFieldErrorLabel(
      l10n,
      state.errorOf(DependentField.address),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dependentFieldAddress, style: VanepTypography.cardSubtitle),
        const SizedBox(height: 8),
        VanepPlaceAutocompleteField(
          controller: autocomplete,
          enabled: !state.isSaving,
          hint: l10n.dependentFieldAddressSearchHint,
          emptyLabel: l10n.placeAutocompleteNoResults,
          networkErrorLabel: l10n.placeAutocompleteNetworkError,
          keyErrorLabel: l10n.placeAutocompleteKeyError,
          retryLabel: l10n.placeAutocompleteRetry,
          onSelected: (selection) => cubit.choosePlace(
            placeId: selection.suggestion.placeId,
            sessionToken: selection.sessionToken,
            label: selection.suggestion.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        if (address == null)
          Text(
            l10n.dependentFieldAddressEmpty,
            style: VanepTypography.cardSubtitle,
          )
        else
          DependentAddressSummary(
            address: address,
            numberController: numberController,
            complementController: complementController,
            enabled: !state.isSaving,
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class DependentAddressSummary extends StatelessWidget {
  const DependentAddressSummary({
    required this.address,
    required this.numberController,
    required this.complementController,
    required this.enabled,
    super.key,
  });

  final DependentAddressDraft address;
  final TextEditingController numberController;
  final TextEditingController complementController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentFormCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(address.label, style: VanepTypography.cardTitle),
            ),
            IconButton(
              tooltip: l10n.dependentFieldAddressRemove,
              icon: const Icon(
                Icons.close,
                color: VanepColors.textSecondary,
              ),
              onPressed: enabled ? cubit.removeAddress : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
        VanepTextField(
          label: l10n.dependentFieldAddressNumber,
          controller: numberController,
          onChanged: cubit.changeAddressNumber,
          enabled: enabled,
          maxLength: maxAddressNumberLength,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        VanepTextField(
          label: l10n.dependentFieldAddressComplement,
          controller: complementController,
          onChanged: cubit.changeAddressComplement,
          enabled: enabled,
          maxLength: maxAddressComplementLength,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

const int maxAddressNumberLength = 16;

const int maxAddressComplementLength = 128;
