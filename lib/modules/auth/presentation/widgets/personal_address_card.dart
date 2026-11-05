import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/formatters/personal_address_display.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_address_form_page.dart';

Future<void> openPersonalAddressFormPage(BuildContext context) async {
  final cubit = context.read<PersonalDataCubit>();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const PersonalAddressFormPage(),
      ),
    ),
  );
  cubit.discardAddressDraft();
}

Future<void> confirmClearPersonalAddress(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<PersonalDataCubit>();
  final confirmed = await showVanepConfirmDialog(
    context: context,
    title: l10n.personalAddressClearTitle,
    message: l10n.personalAddressClearMessage,
    confirmLabel: l10n.personalAddressClearConfirm,
    cancelLabel: l10n.profileSignOutCancel,
    isDestructive: true,
  );
  if (!confirmed) return;
  await cubit.clearAddress();
}

class PersonalAddressCard extends StatelessWidget {
  const PersonalAddressCard({required this.address, super.key});

  final PersonalAddress? address;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saved = address;

    return VanepAddressCard(
      title: l10n.personalAddressCardTitle,
      emptyLabel: l10n.personalAddressEmpty,
      registerLabel: l10n.personalAddressRegisterAction,
      menuTooltip: l10n.personalAddressCardMenuTooltip,
      editLabel: l10n.personalAddressEditAction,
      clearLabel: l10n.personalAddressClearAction,
      summary: saved == null ? null : personalAddressDisplayFields(saved),
      onRegister: () => openPersonalAddressFormPage(context),
      onEdit: () => openPersonalAddressFormPage(context),
      onClear: () => confirmClearPersonalAddress(context),
    );
  }
}
