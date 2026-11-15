import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_van_detail_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_van_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/leave_assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_detail_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_van_detail_page.dart';

import '../../mocks/assistant_mocks.dart';

Widget localizedApp(Widget home) {
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
    home: Scaffold(body: home),
  );
}

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

DateTime fixedClock() => DateTime(2026, 10, 14, 6);

void main() {
  group('van detail (VAN-69)', () {
    late MockAssistantVanDetailRepository repository;

    setUp(() => repository = MockAssistantVanDetailRepository());

    AssistantVanDetailCubit buildCubit() => AssistantVanDetailCubit(
      findVanDetail: FindAssistantVanDetail(repository),
      leaveAssistantVan: LeaveAssistantVan(repository),
    );

    test('the mock shows the first four stops of ten', () async {
      final detail = await const MockedAssistantVanDetailDataSource(
        clock: fixedClock,
      ).findVanDetail(mockedVanCarlosToken);

      expect(detail.stops, hasLength(8));
      expect(detail.previewStops, hasLength(4));
      expect(detail.studentsCount, 16);
    });

    blocTest<AssistantVanDetailCubit, AssistantVanDetailState>(
      'leaving ends in the left state',
      build: () {
        when(() => repository.findVanDetail('van')).thenAnswer(
          (_) async => Ok(
            await const MockedAssistantVanDetailDataSource(clock: fixedClock)
                .findVanDetail(mockedVanCarlosToken),
          ),
        );
        when(() => repository.leaveVan(mockedVanCarlosToken))
            .thenAnswer((_) async => const Ok(null));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadDetail('van');
        await cubit.leaveVan();
      },
      verify: (cubit) =>
          expect(cubit.state.status, AssistantVanDetailStatus.left),
    );

    blocTest<AssistantVanDetailCubit, AssistantVanDetailState>(
      'a failed load keeps the failure',
      build: () {
        when(() => repository.findVanDetail('van'))
            .thenAnswer((_) async => const Err(AssistantFailure.network));
        return buildCubit();
      },
      act: (cubit) => cubit.loadDetail('van'),
      expect: () => [
        const AssistantVanDetailState(),
        const AssistantVanDetailState(
          status: AssistantVanDetailStatus.loadFailed,
          failure: AssistantFailure.network,
        ),
      ],
    );

    Future<void> pumpDetail(WidgetTester tester) async {
      useTallScreen(tester);
      final detail = await const MockedAssistantVanDetailDataSource(
        clock: fixedClock,
      ).findVanDetail(mockedVanCarlosToken);
      when(() => repository.findVanDetail(mockedVanCarlosToken))
          .thenAnswer((_) async => Ok(detail));
      when(() => repository.leaveVan(mockedVanCarlosToken))
          .thenAnswer((_) async => const Ok(null));
      final cubit = buildCubit();
      await cubit.loadDetail(mockedVanCarlosToken);
      await tester.pumpWidget(
        localizedApp(
          BlocProvider<AssistantVanDetailCubit>.value(
            value: cubit,
            child: AssistantVanDetailBody(detail: detail, isLeaving: false),
          ),
        ),
      );
    }

    testWidgets('leaving asks first and confirms', (tester) async {
      await pumpDetail(tester);

      await tester.tap(find.text('Sair desta van'));
      await tester.pumpAndSettle();
      expect(find.text('Sair desta van?'), findsOneWidget);

      await tester.tap(find.text('Sair desta van').last);
      await tester.pumpAndSettle();

      verify(() => repository.leaveVan(mockedVanCarlosToken)).called(1);
    });

    testWidgets('staying sends nothing', (tester) async {
      await pumpDetail(tester);

      await tester.tap(find.text('Sair desta van'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ficar'));
      await tester.pumpAndSettle();

      verifyNever(() => repository.leaveVan(any()));
    });

    testWidgets('shows driver, capabilities, stops and leaving', (
      tester,
    ) async {
      useTallScreen(tester);
      final detail = await const MockedAssistantVanDetailDataSource(
        clock: fixedClock,
      ).findVanDetail(mockedVanCarlosToken);
      await tester.pumpWidget(
        localizedApp(
          BlocProvider<AssistantVanDetailCubit>(
            create: (_) => buildCubit(),
            child: AssistantVanDetailBody(detail: detail, isLeaving: false),
          ),
        ),
      );

      expect(find.text('Você está ativo'), findsOneWidget);
      expect(find.text('Carlos Mendes'), findsOneWidget);
      expect(find.text('O que você pode fazer aqui'), findsOneWidget);
      expect(find.text('Só Carlos muda a ordem das paradas'), findsOneWidget);
      expect(find.text('8 paradas no total'), findsOneWidget);
      expect(find.text('Sair desta van'), findsOneWidget);
    });
  });
}
