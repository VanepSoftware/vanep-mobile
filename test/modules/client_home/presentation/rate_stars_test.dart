import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_state.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/needs_you_section.dart';

import '../../../core/ui/localized_harness.dart';
import '../client_home_mocks.dart';

void main() {
  late MockClientHomeCubit cubit;

  setUp(() {
    cubit = MockClientHomeCubit();
    when(() => cubit.state).thenReturn(const ClientHomeState());
    when(() => cubit.rate(any(), any())).thenAnswer((_) async => true);
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      localizedHarness(
        BlocProvider<ClientHomeCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: RateStars(
              driverToken: 'drv-carlos',
              driverName: 'Carlos Souza',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('asks for confirmation before sending the stars', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('4 estrelas'));
    await tester.pumpAndSettle();

    expect(find.text('Avaliar Carlos?'), findsOneWidget);
    verifyNever(() => cubit.rate(any(), any()));

    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    verify(() => cubit.rate('drv-carlos', 4)).called(1);
    expect(find.text('Avaliação enviada. Obrigado!'), findsOneWidget);
  });

  testWidgets('sends nothing when the confirmation is dismissed', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byTooltip('1 estrela'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    verifyNever(() => cubit.rate(any(), any()));
  });

  testWidgets('tells the user when the rating could not be sent', (
    tester,
  ) async {
    when(() => cubit.rate(any(), any())).thenAnswer((_) async => false);
    await pump(tester);

    await tester.tap(find.byTooltip('5 estrelas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível enviar sua avaliação.'), findsOneWidget);
  });
}
