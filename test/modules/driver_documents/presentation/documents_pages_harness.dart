import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';

class MockDriverComplianceCubit extends Mock implements DriverComplianceCubit {}

MockDriverComplianceCubit complianceCubitWith(DriverComplianceState state) {
  final cubit = MockDriverComplianceCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(cubit.load).thenAnswer((_) async {});
  when(cubit.refresh).thenAnswer((_) async {});
  when(cubit.close).thenAnswer((_) async {});
  return cubit;
}

Widget documentsHarness(DriverComplianceCubit cubit, Widget page) {
  return MaterialApp(
    theme: VanepTheme.light(),
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<DriverComplianceCubit>.value(value: cubit, child: page),
  );
}
