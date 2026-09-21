import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/ui/vanep_city_picker_sheet.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../core/ui/vanep_postal_address_form.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/personal_data_cubit.dart';
import '../cubit/personal_data_state.dart';
import '../mappers/personal_address_failure_l10n.dart';

class PersonalAddressFormPage extends StatefulWidget {
  const PersonalAddressFormPage({super.key});

  @override
  State<PersonalAddressFormPage> createState() =>
      _PersonalAddressFormPageState();
}

class _PersonalAddressFormPageState extends State<PersonalAddressFormPage> {
  bool _submitted = false;

  Future<void> handleSave() async {
    setState(() => _submitted = true);
    final cubit = context.read<PersonalDataCubit>();
    if (!cubit.state.isAddressSavable) return;
    await cubit.save();
  }

  Future<void> openCityPicker() async {
    final cubit = context.read<PersonalDataCubit>();
    final uf = cubit.state.addressDraft.uf;
    await cubit.refreshCities(uf);
    if (!mounted) return;
    await showVanepCityPickerSheet(
      context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const PersonalAddressCityPicker(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<PersonalDataCubit, PersonalDataState>(
      listenWhen: (previous, current) => previous.feedback != current.feedback,
      listener: (context, state) {
        final feedback = state.feedback;
        switch (feedback) {
          case PersonalDataAddressSaveFailureFeedback(:final failure):
            VanepFeedback.showError(
              context,
              personalAddressFailureMessage(l10n, failure),
            );
            context.read<PersonalDataCubit>().clearFeedback();
          case PersonalDataSaveSuccessFeedback():
            Navigator.of(context).maybePop();
          default:
            break;
        }
      },
      builder: (context, state) {
        final cubit = context.read<PersonalDataCubit>();
        final draft = state.addressDraft;
        final cepFailure = state.cepFailure;

        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: const VanepAppBar(),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              VanepPageHeader(
                title: state.address == null
                    ? l10n.personalAddressFormTitleNew
                    : l10n.personalAddressFormTitleEdit,
                subtitle: l10n.personalAddressFormSubtitle,
              ),
              VanepPostalAddressForm(
                draft: draft,
                ufOptions: [
                  for (final option in state.catalogStates) option.uf,
                ],
                showErrors: _submitted,
                isLookingUpCep: state.isLookingUpCep,
                enabled: !state.isSaving,
                zipErrorText: cepFailure == null
                    ? null
                    : cepFailureMessage(l10n, cepFailure),
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
              label: l10n.personalAddressSaveAction,
              isLoading: state.isSaving,
              onPressed: draft.isZipCodeUnknown ? null : handleSave,
            ),
          ),
        );
      },
    );
  }
}

class PersonalAddressCityPicker extends StatelessWidget {
  const PersonalAddressCityPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PersonalDataCubit>();

    return BlocBuilder<PersonalDataCubit, PersonalDataState>(
      builder: (context, state) {
        final failure = state.catalogFailure;
        return VanepCityPickerSheet(
          options: [
            for (final city in state.catalogCities)
              VanepCityOption(token: city.token, name: city.name),
          ],
          selectedToken: state.addressDraft.cityToken,
          errorText: failure == null
              ? null
              : ibgeLocationsFailureMessage(l10n, failure),
          onSearchChanged: (query) =>
              cubit.refreshCities(state.addressDraft.uf, search: query),
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
