import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/pages/van_central_tab.dart';

import '../test/modules/driver_van_central/driver_van_central_fixtures.dart';
import '../test/modules/driver_van_central/driver_van_central_mocks.dart';

void main() {
  const empty = bool.fromEnvironment('VAN56_PREVIEW_EMPTY');
  final cubit = MockVanCentralCubit();
  whenListen(cubit, const Stream<VanCentralState>.empty(),
      initialState: empty ? const VanCentralState(status: VanCentralStatus.loaded) : const VanCentralState(
        status: VanCentralStatus.loaded,
        vans: [firstVan, secondVan],
        occupancy: testOccupancy,
        attendance: testAttendance,
        assistants: testAssistants,
        serviceAreas: testServiceAreas,
      ));
  when(() => cubit.refresh()).thenAnswer((_) async {});
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<VanCentralCubit>.value(
      value: cubit,
      child: Scaffold(body: VanCentralTab(
        onRegisterVan: () async {},
        onOpenVanDetails: () async {},
        onOpenServiceAreas: () async {},
        onOpenComingSoon: (_) async {},
      )),
    ),
  ));
}
