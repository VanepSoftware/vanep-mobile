import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/home_page.dart';

import '../auth_fixtures.dart';
import 'auth_presentation_mocks.dart';

class _NamelessProfile implements UserProfile {
  const _NamelessProfile();
  @override
  String get token => 't';
  @override
  String? get name => null;
  @override
  String? get email => null;
}

Widget _harness(AuthCubit cubit, UserProfile profile) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: HomePage(profile: profile),
    ),
  );
}

void main() {
  late MockAuthCubit cubit;

  setUp(() => cubit = MockAuthCubit());

  testWidgets('greets the user and signs out on Sair', (tester) async {
    when(() => cubit.signOut()).thenAnswer((_) async {});

    await tester.pumpWidget(_harness(cubit, const FakeUserProfile()));

    expect(find.textContaining('Ana Motorista'), findsOneWidget);
    expect(find.textContaining('ana@vanep.com.br'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pump();
    verify(() => cubit.signOut()).called(1);
  });

  testWidgets('renders without an email when the profile has none', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(cubit, const _NamelessProfile()));

    expect(find.text('Sair'), findsOneWidget);
  });
}
