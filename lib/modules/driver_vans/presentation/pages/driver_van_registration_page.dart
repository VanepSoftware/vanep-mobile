import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_state.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/widgets/driver_vans_section.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/widgets/van_registration_form.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class DriverVanRegistrationPage extends StatelessWidget {
  const DriverVanRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<DriverVansCubit, DriverVansState>(
      listenWhen: (previous, current) =>
          current.notice != null && previous.notice != current.notice,
      listener: (context, state) {
        final registered = state.notice is VanRegisteredNotice;
        presentDriverVansNotice(context, l10n, state);
        if (registered) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: context.palette.surface,
        appBar: AppBar(title: Text(l10n.vanCentralRegisterAction)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: const [
            VanepCard(
              padding: EdgeInsets.all(20),
              child: VanRegistrationForm(),
            ),
          ],
        ),
      ),
    );
  }
}
