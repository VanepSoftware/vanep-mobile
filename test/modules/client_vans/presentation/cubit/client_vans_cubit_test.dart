import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_cubit.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_state.dart';

import '../../fixtures/client_vans_fixture.dart';
import '../../mocks/client_vans_mocks.dart';

void main() {
  late MockFindMyClientVans findMyClientVans;

  setUp(() {
    findMyClientVans = MockFindMyClientVans();
  });

  blocTest<ClientVansCubit, ClientVansState>(
    'loads vans successfully',
    build: () {
      when(() => findMyClientVans()).thenAnswer(
        (_) async => Ok([testClientVan]),
      );
      return ClientVansCubit(findMyClientVans: findMyClientVans);
    },
    act: (cubit) => cubit.loadVans(),
    expect: () => [
      const ClientVansState(status: ClientVansStatus.loading),
      ClientVansState(
        status: ClientVansStatus.loaded,
        vans: [testClientVan],
        selectedVanIndex: 0,
      ),
    ],
  );

  blocTest<ClientVansCubit, ClientVansState>(
    'emits loadFailed on error',
    build: () {
      when(() => findMyClientVans()).thenAnswer(
        (_) async => const Err(ClientVansFailure.network),
      );
      return ClientVansCubit(findMyClientVans: findMyClientVans);
    },
    act: (cubit) => cubit.loadVans(),
    expect: () => [
      const ClientVansState(status: ClientVansStatus.loading),
      const ClientVansState(
        status: ClientVansStatus.loadFailed,
        failure: ClientVansFailure.network,
      ),
    ],
  );
}
