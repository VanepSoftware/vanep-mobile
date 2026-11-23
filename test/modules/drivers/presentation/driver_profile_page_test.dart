import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_slot.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_profile_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_ratings_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_van_photos_page.dart';

import '../drivers_fixtures.dart';
import 'drivers_presentation_mocks.dart';

class MockApiImageLoader extends Mock implements ApiImageLoader {}

Widget harness(
  DriverProfileCubit cubit,
  ApiImageLoader loader, {
  ValueChanged<String>? onQuoteRequested,
}) {
  return RepositoryProvider<ApiImageLoader>.value(
    value: loader,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider<DriverProfileCubit>.value(
        value: cubit,
        child: DriverProfilePage(onQuoteRequested: onQuoteRequested),
      ),
    ),
  );
}

void main() {
  late MockDriverProfileCubit cubit;
  late MockApiImageLoader loader;

  setUp(() {
    cubit = MockDriverProfileCubit();
    loader = MockApiImageLoader();
    when(() => loader.loadBytes(any())).thenThrow(StateError('offline'));
  });

  void seed(DriverProfileState state) {
    whenListen(
      cubit,
      const Stream<DriverProfileState>.empty(),
      initialState: state,
    );
  }

  testWidgets('shows a spinner while loading, without the quote button', (
    tester,
  ) async {
    seed(const DriverProfileState());

    await tester.pumpWidget(harness(cubit, loader));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Pedir orçamento'), findsNothing);
  });

  testWidgets('shows public driver identity, bio, areas and hides phone', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));

    expect(find.text('Carlos Souza'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
    expect(find.text('8 anos de experiência'), findsOneWidget);
    expect(find.text('4,8'), findsWidgets);
    expect(find.text('Taguatinga, Ceilândia, Águas Claras'), findsOneWidget);
    expect(find.text('Levo criança há 8 anos.'), findsOneWidget);
    expect(find.text('(61) 99999-0000'), findsNothing);
  });

  testWidgets('lists vans without plates and opens photos screen on tap', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));

    expect(find.text('Sprinter · 2021'), findsOneWidget);
    expect(find.text('Branca · 15 lugares'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sprinter · 2021'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Sprinter · 2021'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sprinter · 2021'));
    await tester.pumpAndSettle();

    expect(find.byType(DriverVanPhotosPage), findsOneWidget);
    expect(find.text('Fotos'), findsOneWidget);
    expect(find.byType(VanepPhotoSlot), findsNWidgets(2));
    expect(find.text('Frente'), findsOneWidget);
    expect(find.text('Lateral'), findsOneWidget);
  });

  testWidgets('loads the van photo through the authenticated loader', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: DriverProfileDto(
          token: 'driver-1',
          name: 'Carlos Souza',
          vehicles: [
            DriverProfileVehicleDto(
              token: 'van-1',
              brand: 'Mercedes-Benz',
              model: 'Sprinter',
              manufactureYear: 2021,
              color: 'Branca',
              capacity: 15,
              photoFrontUrl: '/api/vehicles/van-1/photo-front',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));
    await tester.pump();

    verify(() => loader.loadBytes('/api/vehicles/van-1/photo-front')).called(1);
    expect(find.text('1 de 1'), findsOneWidget);
  });

  testWidgets('without van photos shows plain placeholder without counter pill', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));

    expect(find.text('1 de 1'), findsNothing);
    expect(find.byIcon(Icons.directions_bus_outlined), findsOneWidget);
  });

  testWidgets('verification card opens verified documents sheet', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));
    await tester.scrollUntilVisible(
      find.text('Verificado pela Vanep'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Verificado pela Vanep'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verificado pela Vanep'));
    await tester.pumpAndSettle();

    expect(find.text('CNH categoria D ou E'), findsOneWidget);
    expect(find.text('Curso de transporte escolar'), findsOneWidget);
    expect(find.text('Antecedentes criminais'), findsOneWidget);
    expect(find.text('Vistoria das vans'), findsOneWidget);
    expect(find.text('Autorização escolar das vans'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(find.text('CNH categoria D ou E'), findsNothing);
  });

  testWidgets('reviews section opens all ratings screen', (tester) async {
    seed(
      DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile.copyWith(
          rating: 4.9,
          ratingCount: 32,
          ratingBreakdown: const [
            DriverRatingBreakdownDto(stars: 5, count: 28),
            DriverRatingBreakdownDto(stars: 4, count: 4),
          ],
          ratings: const [
            DriverProfileRatingDto(
              authorName: 'Patrícia S.',
              dateLabel: 'há 2 semanas',
              stars: 5,
              comment: 'Muito pontual e atencioso.',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));
    await tester.scrollUntilVisible(
      find.text('Ver todas'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Ver todas'));
    await tester.pumpAndSettle();
    expect(find.text('Patrícia S.'), findsOneWidget);
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();

    expect(find.byType(DriverRatingsPage), findsOneWidget);
    expect(find.text('Muito pontual e atencioso.'), findsOneWidget);
  });

  testWidgets('says so when the driver has no van yet', (tester) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfileWithoutVan,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));

    expect(
      find.text('Este motorista ainda não cadastrou uma van.'),
      findsOneWidget,
    );
  });

  testWidgets('the quote button opens the quote request to this driver', (
    tester,
  ) async {
    seed(
      DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile.copyWith(available: true),
      ),
    );
    final requested = <String>[];

    await tester.pumpWidget(
      harness(cubit, loader, onQuoteRequested: requested.add),
    );
    await tester.tap(find.text('Pedir orçamento'));
    await tester.pump();

    expect(requested, [testDriverProfile.token]);
    expect(find.text('Conversar com o motorista'), findsNothing);
  });

  testWidgets('a driver not taking students cannot get a quote request', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );
    final requested = <String>[];

    await tester.pumpWidget(
      harness(cubit, loader, onQuoteRequested: requested.add),
    );
    await tester.tap(find.text('Pedir orçamento'));
    await tester.pump();

    expect(
      find.text('Este motorista não está aceitando novos alunos.'),
      findsOneWidget,
    );
    expect(requested, isEmpty);
  });

  testWidgets('a missing driver is explained and can be retried', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.error,
        failure: NotFoundDriverFailure(),
      ),
    );
    when(() => cubit.loadProfile()).thenAnswer((_) async {});

    await tester.pumpWidget(harness(cubit, loader));
    await tester.tap(find.text('Tentar novamente'));

    expect(
      find.text('Este motorista não está mais disponível.'),
      findsOneWidget,
    );
    verify(() => cubit.loadProfile()).called(1);
  });
}
