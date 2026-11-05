import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_city_picker_sheet.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';

class DependentCityPicker extends StatelessWidget {
  const DependentCityPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentFormCubit>();

    return BlocBuilder<DependentFormCubit, DependentFormState>(
      builder: (context, state) {
        final failure = state.catalogFailure;
        return VanepCityPickerSheet(
          options: [
            for (final city in state.catalogCities)
              VanepCityOption(token: city.token, name: city.name),
          ],
          selectedToken: state.draft.address.cityToken,
          errorText: failure == null
              ? null
              : dependentCatalogFailureLabel(l10n, failure),
          onSearchChanged: (query) =>
              cubit.refreshCities(state.draft.address.uf, search: query),
          onSelected: (option) {
            final city = state.catalogCities.firstWhere(
              (candidate) => candidate.token == option.token,
            );
            cubit.selectCity(city);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
