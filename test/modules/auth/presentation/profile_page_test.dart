import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_data_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/profile_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/widgets/profile_header.dart';

import '../auth_fixtures.dart';
import 'auth_presentation_mocks.dart';

class ClientProfile implements UserProfile {
  const ClientProfile();

  @override
  String get token => 'client-token';

  @override
  String? get name => 'Alex Morgan';

  @override
  String? get email => 'alex.morgan@example.com';

  @override
  String? get phone => '11988887777';

  @override
  String? get document => '12345678901';

  @override
  String? get birthDate => '1990-05-15';

  @override
  Gender? get gender => Gender.male;

  @override
  UserType? get type => UserType.client;
}

Widget profileHarness(
  AuthCubit cubit,
  UserProfile profile, {
  String? photoUrl,
  double? rating,
  String? city,
  String? statusLabel,
  Color? statusColor,
}) {
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
      child: Scaffold(
        body: ProfilePage(
          profile: profile,
          photoUrl: photoUrl,
          rating: rating,
          city: city,
          statusLabel: statusLabel,
          statusColor: statusColor,
        ),
      ),
    ),
  );
}

void main() {
  late MockAuthCubit cubit;

  setUp(() => cubit = MockAuthCubit());

  testWidgets('shows light profile header and role menu for client', (
    tester,
  ) async {
    await tester.pumpWidget(profileHarness(cubit, const ClientProfile()));

    expect(find.text('Perfil'), findsWidgets);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('alex.morgan@example.com'), findsOneWidget);
    expect(find.text('Dados pessoais'), findsOneWidget);
    expect(find.text('Conta'), findsOneWidget);
    expect(find.text('Serviços'), findsOneWidget);
    expect(find.text('Endereços'), findsOneWidget);
    expect(find.text('Formas de pagamento'), findsOneWidget);
    expect(find.text('Gerenciar dependentes'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Preferências'), 200);
    expect(find.text('Preferências'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sair'), 200);
    expect(find.text('Sair'), findsOneWidget);
  });

  testWidgets('disabled menu items do not navigate', (tester) async {
    await tester.pumpWidget(profileHarness(cubit, const ClientProfile()));

    await tester.tap(find.text('Endereços'));
    await tester.pumpAndSettle();

    expect(find.byType(PersonalDataPage), findsNothing);
  });

  testWidgets('personal data shows formatted account fields', (tester) async {
    await tester.pumpWidget(profileHarness(cubit, const ClientProfile()));

    await tester.tap(find.text('Dados pessoais'));
    await tester.pumpAndSettle();

    expect(find.byType(PersonalDataPage), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsWidgets);
    expect(find.text('Telefone'), findsOneWidget);
    expect(find.text('(11) 98888-7777'), findsOneWidget);
    expect(find.text('Documento'), findsOneWidget);
    expect(find.text('123.456.789-01'), findsOneWidget);
    expect(find.text('Data de nascimento'), findsOneWidget);
    expect(find.text('15/05/1990'), findsOneWidget);
    expect(find.text('Gênero'), findsOneWidget);
    expect(find.text('Masculino'), findsOneWidget);
  });

  testWidgets('sign out asks for confirmation before signing out', (
    tester,
  ) async {
    when(() => cubit.signOut()).thenAnswer((_) async {});

    await tester.pumpWidget(profileHarness(cubit, const ClientProfile()));

    await tester.scrollUntilVisible(find.text('Sair'), 200);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.text('Sair da conta?'), findsOneWidget);
    expect(
      find.text(
        'Sua sessão neste aparelho será encerrada. Você pode entrar de novo quando quiser.',
      ),
      findsOneWidget,
    );
    verifyNever(() => cubit.signOut());

    await tester.tap(find.widgetWithText(TextButton, 'Sair'));
    await tester.pumpAndSettle();

    verify(() => cubit.signOut()).called(1);
  });

  testWidgets('cancelling sign out keeps the session', (tester) async {
    when(() => cubit.signOut()).thenAnswer((_) async {});

    await tester.pumpWidget(profileHarness(cubit, const FakeUserProfile()));

    await tester.scrollUntilVisible(find.text('Sair'), 200);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => cubit.signOut());
  });

  testWidgets('driver header shows rating and city under email', (tester) async {
    await tester.pumpWidget(
      profileHarness(
        cubit,
        const FakeUserProfile(),
        rating: 4.8,
        city: 'São Paulo',
      ),
    );

    expect(find.text('Ana Motorista'), findsOneWidget);
    expect(find.text('ana@vanep.com.br'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('assistant header shows status chip under email', (tester) async {
    await tester.pumpWidget(
      profileHarness(
        cubit,
        const FakeUserProfile(
          name: 'Assistente',
          email: 'assistente@vanep.com.br',
          type: UserType.assistant,
        ),
        statusLabel: 'Convite pendente',
        statusColor: VanepColors.ratingStar,
      ),
    );

    expect(find.text('Assistente'), findsOneWidget);
    expect(find.text('assistente@vanep.com.br'), findsOneWidget);
    expect(find.byType(ProfileAssistantStatusChip), findsOneWidget);
    expect(find.text('Convite pendente'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);

    final label = tester.widget<Text>(find.text('Convite pendente'));
    expect(label.style?.color, VanepColors.ratingStar);
  });

  testWidgets('client header shows rating when provided', (tester) async {
    await tester.pumpWidget(
      profileHarness(cubit, const ClientProfile(), rating: 4.5),
    );

    expect(find.text('4.5'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('client header does not show rating when omitted', (tester) async {
    await tester.pumpWidget(profileHarness(cubit, const ClientProfile()));

    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.text('4.5'), findsNothing);
  });
}
