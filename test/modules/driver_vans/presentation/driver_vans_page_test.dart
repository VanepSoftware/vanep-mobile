import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_state.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/pages/driver_vans_page.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/widgets/van_registration_form.dart';

import '../driver_vans_mocks.dart';

void main() {
  testWidgets('my vans opens the registration when there is no van yet', (
    tester,
  ) async {
    final cubit = MockDriverVansCubit();
    whenListen(
      cubit,
      const Stream<DriverVansState>.empty(),
      initialState: const DriverVansState(status: DriverVansStatus.loaded),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: BlocProvider<DriverVansCubit>.value(
          value: cubit,
          child: const DriverVansPage(),
        ),
      ),
    );

    expect(find.text('Minhas vans'), findsOneWidget);
    expect(find.byType(VanRegistrationForm), findsOneWidget);
  });
}
