import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/domain/postal_address_draft.dart';
import '../../../../core/ui/vanep_city_picker_sheet.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_postal_address_form.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/dependent_failure.dart';
import '../cubit/dependent_form_cubit.dart';
import '../cubit/dependent_form_state.dart';
import '../formatters/dependent_labels.dart';
import '../widgets/dependent_city_picker.dart';

Future<void> openDependentAddressFormPage(BuildContext context) {
  final cubit = context.read<DependentFormCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const DependentAddressFormPage(),
      ),
    ),
  );
}

class DependentAddressFormPage extends StatefulWidget {
  const DependentAddressFormPage({super.key});

  @override
  State<DependentAddressFormPage> createState() =>
      DependentAddressFormPageState();
}

class DependentAddressFormPageState extends State<DependentAddressFormPage> {
  late final PostalAddressDraft initial;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    initial = context.read<DependentFormCubit>().state.draft.address;
  }

  void confirm() {
    if (!context.read<DependentFormCubit>().confirmAddress()) return;
    confirmed = true;
    Navigator.of(context).pop();
  }

  void discardIfNotConfirmed(bool didPop, Object? result) {
    if (!didPop || confirmed) return;
    context.read<DependentFormCubit>().replaceAddress(initial);
  }

  Future<void> openCityPicker() async {
    final cubit = context.read<DependentFormCubit>();
    await cubit.refreshCities(cubit.state.draft.address.uf);
    if (!mounted) return;
    await showVanepCityPickerSheet(
      context,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const DependentCityPicker()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: discardIfNotConfirmed,
      child: BlocBuilder<DependentFormCubit, DependentFormState>(
        builder: (context, state) {
          final cubit = context.read<DependentFormCubit>();
          final cepFailure = state.cepFailure;

          return Scaffold(
            backgroundColor: VanepColors.card,
            appBar: const VanepAppBar(),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                VanepPageHeader(
                  title: initial.isBlank
                      ? l10n.dependentAddressFormTitleNew
                      : l10n.dependentAddressFormTitleEdit,
                  subtitle: l10n.dependentAddressFormSubtitle,
                ),
                VanepPostalAddressForm(
                  draft: state.draft.address,
                  ufOptions: [
                    for (final option in state.catalogStates) option.uf,
                  ],
                  showErrors: state.showsAddressErrors,
                  isLookingUpCep: state.isLookingUpCep,
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
                  onCityTap: openCityPicker,
                ),
              ],
            ),
            bottomNavigationBar: VanepBottomBar(
              child: VanepPrimaryButton(
                label: l10n.dependentAddressConfirmAction,
                onPressed: state.isAddressBlockingSave ? null : confirm,
              ),
            ),
          );
        },
      ),
    );
  }
}
