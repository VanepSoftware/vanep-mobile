import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/ui/vanep_photo_slot.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_state.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/widgets/driver_vans_section.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/widgets/van_registration_form.dart';

import '../../../core/media/media_mocks.dart';
import '../driver_vans_fixtures.dart';
import '../driver_vans_mocks.dart';

Widget harness(DriverVansCubit cubit) {
  final loader = MockApiImageLoader();
  when(() => loader.loadBytes(any())).thenThrow(StateError('offline'));
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
      home: Scaffold(
        body: BlocProvider<DriverVansCubit>.value(
          value: cubit,
          child: const SingleChildScrollView(child: DriverVansSection()),
        ),
      ),
    ),
  );
}

void main() {
  late MockDriverVansCubit cubit;

  setUpAll(() {
    registerFallbackValue(frontOfTestVan);
    registerFallbackValue(PhotoSource.gallery);
    registerFallbackValue(VanField.plate);
  });

  setUp(() {
    cubit = MockDriverVansCubit();
    when(() => cubit.changePhoto(any(), any())).thenAnswer((_) async {});
    when(() => cubit.register()).thenAnswer((_) async {});
  });

  void seed(DriverVansState state, {Stream<DriverVansState>? stream}) {
    whenListen(
      cubit,
      stream ?? const Stream<DriverVansState>.empty(),
      initialState: state,
    );
  }

  testWidgets('a driver without a van gets the registration form', (
    tester,
  ) async {
    seed(const DriverVansState(status: DriverVansStatus.loaded));

    await tester.pumpWidget(harness(cubit));

    expect(find.byType(VanRegistrationForm), findsOneWidget);
    expect(find.text('Placa'), findsOneWidget);
    expect(find.text('Lugares'), findsOneWidget);
    expect(find.byType(VanepPhotoSlot), findsNothing);
  });

  testWidgets('the form sends each field and the register tap to the cubit', (
    tester,
  ) async {
    seed(const DriverVansState(status: DriverVansStatus.loaded));

    await tester.pumpWidget(harness(cubit));
    await tester.enterText(find.byType(TextField).first, 'abc1d23');
    await tester.ensureVisible(find.text('Cadastrar van'));
    await tester.tap(find.text('Cadastrar van'));

    verify(() => cubit.updateDraft(VanField.plate, 'ABC1D23')).called(1);
    verify(() => cubit.register()).called(1);
  });

  testWidgets('shows why a field was refused', (tester) async {
    seed(
      const DriverVansState(
        status: DriverVansStatus.loaded,
        fieldErrors: {VanField.plate: VanFieldError.invalid},
      ),
    );

    await tester.pumpWidget(harness(cubit));

    expect(find.text('Placa inválida. Ex.: ABC1D23'), findsOneWidget);
  });

  testWidgets('a driver with a van edits the front and side photos', (
    tester,
  ) async {
    seed(
      const DriverVansState(status: DriverVansStatus.loaded, vans: [testVan]),
    );

    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    expect(find.text('Sprinter 2021 · Mercedes-Benz'), findsOneWidget);
    expect(find.text('Frente'), findsOneWidget);
    expect(find.text('Lateral'), findsOneWidget);
    expect(find.byType(VanRegistrationForm), findsNothing);

    await tester.tap(find.text('Frente'));
    await tester.tap(find.byType(VanepPhotoSlot).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tirar foto'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.changePhoto(frontOfTestVan, PhotoSource.camera),
    ).called(1);
  });

  testWidgets('a notice is shown and then cleared', (tester) async {
    seed(
      const DriverVansState(status: DriverVansStatus.loaded, vans: [testVan]),
      stream: Stream.value(
        const DriverVansState(
          status: DriverVansStatus.loaded,
          vans: [testVan],
          notice: VanPhotoFailedNotice(PhotoFailure.permissionDenied),
        ),
      ),
    );

    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    expect(
      find.text('Permita o acesso às fotos nas configurações do celular.'),
      findsOneWidget,
    );
    verify(() => cubit.clearNotice()).called(1);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    seed(const DriverVansState(status: DriverVansStatus.loadFailed));
    when(() => cubit.loadVans()).thenAnswer((_) async {});

    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('Tentar novamente'));

    expect(find.text('Não foi possível carregar sua van.'), findsOneWidget);
    verify(() => cubit.loadVans()).called(1);
  });
}
