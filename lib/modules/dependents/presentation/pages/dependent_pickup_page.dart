import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_city_picker_sheet.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_map_placeholder.dart';
import 'package:vanep_mobile/core/ui/vanep_postal_address_form.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_editor_frame.dart';

Future<Dependent?> openDependentPickup(
  BuildContext context, {
  required Dependent dependent,
}) {
  return Navigator.of(context).push<Dependent>(
    MaterialPageRoute<Dependent>(
      builder: (_) => DependentPickupPage(dependent: dependent),
    ),
  );
}

class DependentPickupPage extends StatelessWidget {
  const DependentPickupPage({required this.dependent, super.key});

  final Dependent dependent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<DependentPickupCubit>(param1: dependent),
      child: DependentEditorFrame(
        title: l10n.dependentRowPickup,
        caption: dependentFirstName(dependent.name),
        body: const DependentPickupBody(),
        bottomBar:
            DependentEditorSaveBar<DependentPickupCubit, DependentPickupState>(
              label: l10n.dependentEditorSave,
              onSaved: (state) => Navigator.of(context).pop(state.saved),
            ),
      ),
    );
  }
}

class DependentPickupBody extends StatelessWidget {
  const DependentPickupBody({super.key});

  Future<void> openCityPicker(BuildContext context) async {
    final cubit = context.read<DependentPickupCubit>();
    await cubit.refreshCities(cubit.state.draft.address.uf);
    if (!context.mounted) return;
    await showVanepCityPickerSheet(
      context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const DependentPickupCityPicker(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentPickupCubit>();

    return BlocConsumer<DependentPickupCubit, DependentPickupState>(
      listenWhen: (previous, current) => current.failure != previous.failure,
      listener: (context, state) {
        final failure = state.failure;
        if (!shouldShowDependentFailureFeedback(failure)) return;
        VanepFeedback.showError(context, dependentFailureLabel(l10n, failure!));
      },
      builder: (context, state) {
        final cepFailure = state.cepFailure;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VanepMapPlaceholder(
              pinIcon: Icons.location_on,
              actionLabel: l10n.mapAdjustAction,
            ),
            const SizedBox(height: 20),
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
              onCityTap: () => openCityPicker(context),
            ),
          ],
        );
      },
    );
  }
}

class DependentPickupCityPicker extends StatelessWidget {
  const DependentPickupCityPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DependentPickupCubit>();

    return BlocBuilder<DependentPickupCubit, DependentPickupState>(
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
