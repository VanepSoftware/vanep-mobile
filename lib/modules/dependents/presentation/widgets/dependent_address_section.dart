import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_postal_address_form.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/dependent_failure.dart';
import '../cubit/dependent_form_cubit.dart';
import '../cubit/dependent_form_state.dart';
import '../formatters/dependent_labels.dart';

class DependentAddressSection extends StatelessWidget {
  const DependentAddressSection({
    required this.state,
    required this.onCityTap,
    super.key,
  });

  final DependentFormState state;
  final VoidCallback onCityTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentFormCubit>();
    final cepFailure = state.cepFailure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.dependentFieldAddress,
                style: VanepTypography.cardTitle,
              ),
            ),
            if (!state.draft.address.isBlank)
              TextButton(
                onPressed: state.isSaving ? null : cubit.clearAddress,
                child: Text(
                  l10n.dependentFieldAddressRemove,
                  style: VanepTypography.cardSubtitle.copyWith(
                    color: VanepColors.action,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        VanepPostalAddressForm(
          draft: state.draft.address,
          ufOptions: [for (final option in state.catalogStates) option.uf],
          showErrors: state.showsAddressErrors,
          isLookingUpCep: state.isLookingUpCep,
          enabled: !state.isSaving,
          zipErrorText: cepFailure == null
              ? null
              : dependentCepFailureLabel(l10n, cepFailure),
          cityErrorText: state.failure is DependentCityNotFoundFailure
              ? l10n.dependentFailureCityNotFound
              : null,
          onZipChanged: cubit.updateZipCode,
          onStreetChanged: cubit.updateStreet,
          onNumberChanged: cubit.updateNumber,
          onComplementChanged: cubit.updateComplement,
          onNeighborhoodChanged: cubit.updateNeighborhood,
          onUfChanged: cubit.selectUf,
          onCityTap: onCityTap,
        ),
      ],
    );
  }
}
