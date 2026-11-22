import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_cubit.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_state.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/pages/client_vans_page.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_van_card.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_vans_empty_view.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_vans_skeleton.dart';

import '../../fixtures/client_vans_fixture.dart';

class MockClientVansCubit extends MockCubit<ClientVansState>
    implements ClientVansCubit {}

final _secondClientVan = ClientVan(
  token: 'link-van-test-02',
  status: 'PENDING',
  driver: const ClientVanDriver(
    token: 'driver-test-02',
    name: 'Mariana Costa',
    phone: '(11) 99999-1111',
    rating: 4.8,
  ),
  vehicle: const ClientVanVehicle(
    token: 'veh-test-02',
    brand: 'Renault',
    model: 'Master',
    manufactureYear: 2023,
    color: 'Prata',
    capacity: 15,
    plate: 'XYZ-9A88',
  ),
  contract: ClientVanContract(
    token: 'contract-test-02',
    status: 'PENDING',
    startsOn: DateTime(2026, 3, 1),
    endsOn: DateTime(2026, 12, 20),
    totalAmount: 3600.00,
    installments: 12,
    installmentAmount: 300.00,
    dueDay: 10,
  ),
  dependents: const [
    ClientVanDependent(
      token: 'dep-test-02',
      name: 'Pedro Silva',
      schoolName: 'Colégio Bandeirantes',
      pickupAddress: 'Av. Paulista, 500',
      shift: 'Tarde',
      pickupTime: '12:30',
      returnTime: '18:00',
      weekdays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'],
    ),
  ],
);

void main() {
  late MockClientVansCubit cubit;

  setUp(() {
    cubit = MockClientVansCubit();
    when(() => cubit.loadVans()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
  });

  Future<void> pumpPage(
    WidgetTester tester,
    ClientVansState state, {
    void Function()? onSearchTapped,
    void Function(ClientVan)? onVanTapped,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        theme: VanepTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: BlocProvider<ClientVansCubit>.value(
          value: cubit,
          child: ClientVansPage(
            onSearchTapped: onSearchTapped ?? () {},
            onVanTapped: onVanTapped,
          ),
        ),
      ),
    );
  }

  testWidgets('lists all available van cards first and opens detail on tap', (
    tester,
  ) async {
    ClientVan? tappedVan;
    var searchTapped = false;

    await pumpPage(
      tester,
      ClientVansState(
        status: ClientVansStatus.loaded,
        vans: [testClientVan, _secondClientVan],
      ),
      onSearchTapped: () => searchTapped = true,
      onVanTapped: (van) => tappedVan = van,
    );

    expect(find.text('Vans'), findsOneWidget);
    expect(find.byType(ClientVanCard), findsNWidgets(2));
    expect(find.text('Carlos Alberto Silva'), findsOneWidget);
    expect(find.text('Mercedes-Benz Sprinter 415 CDI'), findsOneWidget);
    expect(find.text('Mariana Costa'), findsOneWidget);
    expect(find.text('Renault Master'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Carlos Alberto Silva')).dy,
      lessThan(tester.getTopLeft(find.text('Mercedes-Benz Sprinter 415 CDI')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Mariana Costa')).dy,
      lessThan(tester.getTopLeft(find.text('Renault Master')).dy),
    );

    await tester.tap(find.text('Mariana Costa'));
    await tester.pump();
    expect(tappedVan, _secondClientVan);

    await tester.tap(find.text('Outra van'));
    await tester.pump();
    expect(searchTapped, isTrue);
  });

  testWidgets('shows empty view when loaded with no vans', (tester) async {
    var searchTapped = false;
    await pumpPage(
      tester,
      const ClientVansState(
        status: ClientVansStatus.loaded,
        vans: [],
      ),
      onSearchTapped: () => searchTapped = true,
    );

    expect(find.byType(ClientVansEmptyView), findsOneWidget);
    expect(find.text('Nenhuma van vinculada'), findsOneWidget);

    await tester.tap(find.text('Buscar vans escolares'));
    expect(searchTapped, isTrue);
  });

  testWidgets('shows skeleton while loading', (tester) async {
    await pumpPage(
      tester,
      const ClientVansState(status: ClientVansStatus.loading),
    );

    expect(find.byType(ClientVansSkeleton), findsOneWidget);
  });

  testWidgets('shows error view on failure', (tester) async {
    await pumpPage(
      tester,
      const ClientVansState(
        status: ClientVansStatus.loadFailed,
        failure: ClientVansFailure.network,
      ),
    );

    expect(find.byType(VanepErrorView), findsOneWidget);
    expect(find.text('Não foi possível carregar suas vans.'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    verify(() => cubit.loadVans()).called(1);
  });
}
