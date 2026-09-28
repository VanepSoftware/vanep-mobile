import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_cover_background.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_slot.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_profile_page.dart';

import '../drivers_fixtures.dart';
import 'drivers_presentation_mocks.dart';

class MockApiImageLoader extends Mock implements ApiImageLoader {}

Widget harness(DriverProfileCubit cubit, ApiImageLoader loader) {
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
        child: const DriverProfilePage(),
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

  testWidgets('shows a spinner while loading, without the chat button', (
    tester,
  ) async {
    seed(const DriverProfileState());

    await tester.pumpWidget(harness(cubit, loader));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Conversar com o motorista'), findsNothing);
  });

  testWidgets('shows who the driver is and where they work', (tester) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));

    expect(find.text('Carlos Souza'), findsOneWidget);
    expect(find.text('8 anos de experiência'), findsOneWidget);
    expect(find.text('4.8 / 5.0'), findsOneWidget);
    expect(find.text('Taguatinga, Ceilândia, Águas Claras'), findsOneWidget);
    expect(find.text('(61) 99999-0000'), findsOneWidget);
    expect(find.text('Levo criança há 8 anos.'), findsOneWidget);
  });

  testWidgets('shows each van with a slot for the front and side photos', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));

    expect(find.text('Sprinter 2021 · Mercedes-Benz'), findsOneWidget);
    expect(find.text('15 lugares · Branca'), findsOneWidget);
    expect(find.text('Fotos da van'), findsOneWidget);
    expect(find.byType(VanepPhotoSlot), findsNWidgets(2));
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
    expect(find.byType(VanepPhotoPlaceholder), findsNWidgets(2));
  });

  testWidgets('the first van photo also becomes the header background', (
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

    final cover = tester.widget<VanepCoverBackground>(
      find.byType(VanepCoverBackground),
    );
    expect(cover.photoUrl, '/api/vehicles/van-1/photo-front');
    expect(find.byType(VanepPhotoSlot), findsNWidgets(2));
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).foregroundColor,
      VanepColors.card,
    );
  });

  testWidgets('without van photos the header keeps its plain background', (
    tester,
  ) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));

    final cover = tester.widget<VanepCoverBackground>(
      find.byType(VanepCoverBackground),
    );
    expect(cover.photoUrl, isNull);
    expect(tester.widget<AppBar>(find.byType(AppBar)).foregroundColor, isNull);
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
    expect(find.text('Fotos da van'), findsNothing);
  });

  testWidgets('offers the chat button, which does nothing yet', (tester) async {
    seed(
      const DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    );

    await tester.pumpWidget(harness(cubit, loader));
    await tester.tap(find.text('Conversar com o motorista'));
    await tester.pump();

    expect(find.byType(DriverProfilePage), findsOneWidget);
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
