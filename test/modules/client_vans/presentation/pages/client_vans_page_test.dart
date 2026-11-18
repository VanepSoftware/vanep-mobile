import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_cubit.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_state.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/pages/client_vans_page.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_van_card.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_vans_empty_view.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_vans_skeleton.dart';

import '../../../auth/presentation/auth_test_harness.dart';
import '../../fixtures/client_vans_fixtures.dart';

class MockClientVansCubit extends MockCubit<ClientVansState>
    implements ClientVansCubit {}

void main() {
  late MockClientVansCubit cubit;

  setUp(() {
    cubit = MockClientVansCubit();
    when(() => cubit.loadVans()).thenAnswer((_) async {});
  });

  Future<void> pumpPage(
    WidgetTester tester,
    ClientVansState state, {
    void Function()? onSearchTapped,
    void Function(ClientVan)? onVanTapped,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      authTestApp(
        BlocProvider<ClientVansCubit>.value(
          value: cubit,
          child: ClientVansPage(
            onSearchTapped: onSearchTapped ?? () {},
            onVanTapped: onVanTapped,
          ),
        ),
      ),
    );
  }

  testWidgets('shows header and minimal van card when loaded with vans', (tester) async {
    ClientVan? tappedVan;
    await pumpPage(
      tester,
      ClientVansState(
        status: ClientVansStatus.loaded,
        vans: [testClientVan],
      ),
      onVanTapped: (van) => tappedVan = van,
    );

    expect(find.text('Minhas vans'), findsOneWidget);
    expect(find.text('Vans escolares vinculadas à sua conta'), findsOneWidget);
    expect(find.byType(ClientVanCard), findsOneWidget);
    expect(find.text('Mercedes-Benz Sprinter 415 CDI'), findsOneWidget);
    expect(find.text('Motorista: Carlos Alberto Silva'), findsOneWidget);
    expect(find.text('Lucas Silva'), findsOneWidget);

    await tester.tap(find.byType(ClientVanCard));
    expect(tappedVan, testClientVan);
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
